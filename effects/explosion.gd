extends Node3D
@onready var flash_particles: GPUParticles3D = $GPUParticles3D
@onready var flash_light: OmniLight3D = $OmniLight3D
@export var parent: Node

signal explosion_finished

func _ready():
	$OmniLight3D.hide()
	$GPUParticles3D.hide()

func explode():
	global_rotation = Vector3.ZERO
	$OmniLight3D.show()
	$GPUParticles3D.show()
	flash_particles.restart()  # Emit one particle
	flash_light.visible = true
	flash_light.light_energy = 10.0

	# Turn off light after particle lifetime
	if get_tree():
		await get_tree().create_timer(flash_particles.lifetime).timeout
		$OmniLight3D.hide()
		$GPUParticles3D.hide()
		emit_signal("explosion_finished")
