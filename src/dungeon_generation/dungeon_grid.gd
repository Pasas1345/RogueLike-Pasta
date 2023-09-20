@tool
extends Node

class_name DungeonGrid

@export var tile_map: TileMap

func _init():
	add_to_group("dungeon_generator")

func _ready():
	if tile_map == null:
		print("no tilemap listed!")

	# Set player's spawnpoint in a random room.
	var spawn_room_pos = room_positions[randi() % room_positions.size() - 1]
	print(spawn_room_pos)
	await get_tree().process_frame
	main_game.player.set_global_position(spawn_room_pos)

@export var start: bool = false : set = set_start
func set_start(v: bool):
	start = v
	if start:
		generate_level()

@export_range(0,1) var hallway_survivalChance: float = 0.25
@export var border_size: int = 20 : set = set_border_size
func set_border_size(v: int):
	border_size = v
	if Engine.is_editor_hint():
		editor_visualize_border()

@export var room_count: int = 5
@export var room_margin: int = 1
@export var room_recursion: int = 15
@export var min_room_size: int = 2
@export var max_room_size: int = 4

var room_tiles: Array[PackedVector2Array] = []
var room_positions: PackedVector2Array = []

func editor_visualize_border():
	print("updating border")
	tile_map.clear()
	for i in range(0, border_size + 1):
		tile_map.set_cell(0, Vector2i(i, 0), 1, Vector2i.ZERO, 1)
		tile_map.set_cell(0, Vector2i(i, border_size), 1, Vector2i.ZERO, 1)
		tile_map.set_cell(0, Vector2i(border_size, i), 1, Vector2i.ZERO, 1)
		tile_map.set_cell(0, Vector2i(0, i), 1, Vector2i.ZERO, 1)

func generate_level():
	print("generating level...")
	room_tiles.clear()
	room_positions.clear()
	editor_visualize_border()
	for i in room_count:
		make_room(room_recursion)

	# Hallways
	var hallwayPositions: PackedVector2Array = []
	var del_graph: AStar2D = AStar2D.new()
	var mst_graph: AStar2D = AStar2D.new()

	for p in room_positions:
		hallwayPositions.append(p)
		del_graph.add_point(del_graph.get_available_point_id(), p)
		mst_graph.add_point(mst_graph.get_available_point_id(), p)

	var delaunay: Array = Array(Geometry2D.triangulate_delaunay(hallwayPositions))

	for i in delaunay.size() / 3:
		var p1: int = delaunay.pop_front()
		var p2: int = delaunay.pop_front()
		var p3: int = delaunay.pop_front()
		del_graph.connect_points(p1, p2)
		del_graph.connect_points(p2, p3)
		del_graph.connect_points(p1, p3)

	var visited_points: PackedInt32Array = []
	visited_points.append(randi() % room_positions.size())
	while visited_points.size() != mst_graph.get_point_count():
		var possible_connections: Array[PackedInt32Array] = []
		for vp in visited_points:
			for c in del_graph.get_point_connections(vp):
				if !visited_points.has(c):
					var con: PackedInt32Array = [vp, c]
					possible_connections.append(con)


		var connection: PackedInt32Array = possible_connections.pick_random()
		for pc in possible_connections:
			if hallwayPositions[pc[0]].distance_squared_to(hallwayPositions[pc[1]]) < hallwayPositions[connection[0]].distance_squared_to(hallwayPositions[connection[1]]):
				connection = pc

		visited_points.append(connection[1])
		mst_graph.connect_points(connection[0], connection[1])
		del_graph.disconnect_points(connection[0], connection[1])

	var hallway_graph: AStar2D = mst_graph

	for p in del_graph.get_point_ids():
		for c in del_graph.get_point_connections(p):
			if c > p:
				var bruhimdead: float = randf()
				if hallway_survivalChance > bruhimdead:
					hallway_graph.connect_points(p, c)

	make_hallway(hallway_graph)

func make_hallway(hallway_graph: AStar2D):
	var hallways: Array[PackedVector2Array] = []
	for p in hallway_graph.get_point_ids():
		for c in hallway_graph.get_point_connections(p):
			if c > p:
				var room_from: PackedVector2Array = room_tiles[p]
				var room_to: PackedVector2Array = room_tiles[c]
				var tile_from: Vector2 = room_from[0]
				var tile_to: Vector2 = room_to[0]
				
				for t in room_from:
					if t.distance_squared_to(room_positions[c]) < tile_from.distance_squared_to(room_positions[c]):
						tile_from = t
				for t in room_to:
					if t.distance_squared_to(room_positions[c]) < tile_to.distance_squared_to(room_positions[c]):
						tile_to = t

				var hallway: PackedVector2Array = [tile_from, tile_to]
				hallways.append(hallway)

				tile_map.set_cell(0, tile_from, 1, Vector2i.ZERO, 4)
				tile_map.set_cell(0, tile_to, 1, Vector2i.ZERO, 4)

	var astar: AStarGrid2D = AStarGrid2D.new()
	astar.size = Vector2i.ONE * border_size
	astar.update()
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN

	for t in tile_map.get_used_cells(0):
		astar.set_point_solid(t)
	
	for h in hallways:
		var pos_from: Vector2i = Vector2i(h[0])
		var pos_to: Vector2i = Vector2i(h[1])
		var hall: PackedVector2Array = astar.get_point_path(pos_from, pos_to)

		for t in hall:
			var pos: Vector2i = t
			if tile_map.get_cell_alternative_tile(0, pos) < 0:
				tile_map.set_cell(0, pos, 1, Vector2i.ZERO, 2)
				



func make_room(recursion: int):
	if !recursion > 0:
		return

	var width: int = (randi() % (max_room_size - min_room_size)) + min_room_size
	var height: int = (randi() % (max_room_size - min_room_size)) + min_room_size

	var start_pos: Vector2i = Vector2i.ZERO
	start_pos.x = randi() % (border_size - width + 1)
	start_pos.y = randi() % (border_size - height + 1)

	for h in range(-room_margin, height + room_margin):
		for w in range(-room_margin, width + room_margin):
			var pos: Vector2i = start_pos + Vector2i(w, h)
			if tile_map.get_cell_alternative_tile(0, pos) == 3:
				make_room(recursion - 1)
				return

	var room: PackedVector2Array = []
	for h in height:
		for w in width:
			var pos: Vector2i = start_pos + Vector2i(w, h)
			tile_map.set_cell(0, pos, 1, Vector2i.ZERO, 3)
			room.append(pos)

	room_tiles.append(room)
	var room_avg_x: float = start_pos.x + (float(width) / 2)
	var room_avg_y: float = start_pos.y + (float(height) / 2)
	var room_pos = Vector2(room_avg_x, room_avg_y)

	room_positions.append(room_pos)
