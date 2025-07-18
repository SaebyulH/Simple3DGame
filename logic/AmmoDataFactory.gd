extends Node
class_name AmmoDataFactory

static func create_default_ammo(count := 6) -> AmmoData:
	var ammo = AmmoData.new()
	ammo.display_name = "Default Ammo"
	ammo.mass = 0
	ammo.value = 0
	ammo.count = count
	return ammo

# In ItemFactory.gd
static func create_revolver_ammo(count := 6) -> AmmoData:
	var ammo = AmmoData.new()
	ammo.display_name = "Revolver Ammo"
	ammo.mass = 0.1
	ammo.value = 1
	ammo.count = count
	return ammo

static func create_rifle_ammo(count := 6) -> AmmoData:
	var ammo = AmmoData.new()
	ammo.display_name = "Rifle Ammo"
	ammo.mass = 0.1
	ammo.value = 1
	ammo.count = count
	return ammo

static func create_grenade_ammo(count := 6) -> AmmoData:
	var ammo = AmmoData.new()
	ammo.display_name = "Grenade Ammo"
	ammo.mass = 0.1
	ammo.value = 1
	ammo.count = count
	return ammo
