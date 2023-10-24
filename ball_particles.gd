extends GPUParticles2D

var was_emitting := false

func _process(dt: float) -> void:
	if not emitting and was_emitting:
		# Is this inefficient? Should we reuse these objects. Not for now.
		queue_free()
	was_emitting = emitting

func configure(position_: Vector2, color: Color, radius: float) -> void:
	position = position_
	var material := process_material as ParticleProcessMaterial
	material.emission_sphere_radius = radius
	color.v = minf(1., color.v * 1.5)
	material.color = color
	amount = radius * 2
	emitting = true
	was_emitting = true
