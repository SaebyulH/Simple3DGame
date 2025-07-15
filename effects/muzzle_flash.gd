extends Node3D
@onready var flash_particles: GPUParticles3D = $GPUParticles3D
@onready var flash_light: OmniLight3D = $OmniLight3D

func _ready():
	$OmniLight3D.hide()
	$GPUParticles3D.hide()

func fire_weapon():
	$OmniLight3D.show()
	$GPUParticles3D.show()
	flash_particles.restart()  # Emit one particle
	flash_light.visible = true
	flash_light.light_energy = 10.0

	# Turn off light after particle lifetime
	await get_tree().create_timer(flash_particles.lifetime).timeout
	$OmniLight3D.hide()
	$GPUParticles3D.hide()
