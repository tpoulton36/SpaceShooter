extends CharacterBody2D

var health = 3

@onready var Player = get_node("/root/Main/Player")


func _physics_process(_delta):
	var direction = global_position.direction_to(Player.global_position)
	velocity = direction * 200.0
	move_and_slide()
	
	get_node("Slime").play_walk()
	


func take_damage():
	health -= 1
	$Slime.play_hurt()
	
	if health == 0:
		queue_free()
		
		const SMOKE_EXPLOSION = preload("res://Scenes/smoke_explosion/smoke_explosion.tscn")	
		var smoke = SMOKE_EXPLOSION.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
