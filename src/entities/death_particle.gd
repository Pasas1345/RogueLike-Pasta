extends GPUParticles2D

var emitted = false

func _ready():
	emitting = true
	emitted = true

func _physics_process(_delta):
	if emitted && !emitting:
		queue_free()