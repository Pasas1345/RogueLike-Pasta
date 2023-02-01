extends Node

# Player Stats
var speed: = 200.0
var max_hp: = 100.0
var attack: = 10.0
var attack_speed: = 1.0
var defense: = 10.0
var ability_regen: = 1.0
var ability_strength: = 1.0

var UP_Regen: = 1.0
var UP_EnergyRestore: = 10.0
var inv_slots: = 4
var inventory = []
var item_strength = 1.0
var acceleration: = 3.0

# onready var _player = get_node("res://entities/Player.tscn")
var _player

func sync_player_to_global():
	_player = get_tree().get_nodes_in_group("player")[0]
	speed = _player.speed
	max_hp = _player.max_hp
	attack = _player.attack
	attack_speed = _player.attack_speed
	defense = _player.defense
	ability_regen = _player.ability_regen
	ability_strength = _player.ability_strength
	UP_Regen = _player.UP_Regen
	UP_EnergyRestore = _player.UP_EnergyRestore
	inv_slots = _player.inv_slots
	inventory = _player.inventory
	item_strength = _player.item_strength
	acceleration = _player.acceleration
	print("Synced Global Player Data!")
	
func sync_global_to_player():
	_player = get_tree().get_nodes_in_group("player")[0]
	_player.speed = speed
	_player.max_hp = max_hp
	_player.attack = attack
	_player.attack_speed = attack_speed
	_player.defense = defense
	_player.ability_regen = ability_regen
	_player.ability_strength = ability_strength
	_player.UP_Regen = UP_Regen
	_player.UP_EnergyRestore = UP_EnergyRestore
	_player.inv_slots = inv_slots
	_player.inventory = inventory
	_player.item_strength = item_strength
	_player.acceleration = acceleration
	print("Synced Player Data!")
	
