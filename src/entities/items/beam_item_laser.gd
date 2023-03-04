extends RayCast2D

var is_casting = false : set = set_is_casting

func _ready():
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO

func _physics_process(_delta):
	var cast_point = target_position
	force_raycast_update()

	$ImpactParticle.emitting = is_colliding()

	if is_colliding():
		cast_point = to_local(get_collision_point())
		$ImpactParticle.global_rotation = get_collision_normal().angle()
		$ImpactParticle.position = cast_point

		if get_collider().has_method("change_health"):
			get_collider().change_health(-(get_parent().get_parent().item_strength * 2.5))

	$Line2D.points[1] = cast_point
	$BeamParticle.position = cast_point * 0.5
	$BeamParticle.process_material.emission_box_extents.x = cast_point.length() * 0.5


func set_is_casting(cast):
	is_casting = cast

	$BeamParticle.emitting = is_casting
	$CastingParticle.emitting = is_casting
	if is_casting:
		appear()
	else:
		$ImpactParticle.emitting = false
		disappear()

	set_physics_process(is_casting)


func appear():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property($Line2D, "width", 10.0, 0.1)
	
func disappear():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property($Line2D, "width", 0.0, 0.075)
