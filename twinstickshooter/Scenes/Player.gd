extends CharacterBody2D

signal health_depleted

var health = 100.0
const SPEED = 700.0  # Adjust as necessary
const BULLET_SCENE = preload("res://Scenes/Bullet.tscn")  # Adjust this path if necessary
const BURST_COUNT = 3 # Number or burst rounds

var burst_bullets_left = 0 #Keep track of how many bullets left in burst

@onready var hurt_box = $HurtBox

func _ready():
	pass

func _physics_process(_delta: float) -> void:
	var move_input := Vector2.ZERO  # Create a 2D vector for movement
	
	const DAMAGE_RATE = 10.0
	if hurt_box:
		var overlapping_mobs = hurt_box.get_overlapping_bodies()
		if overlapping_mobs.size() > 0:
			health -= DAMAGE_RATE * overlapping_mobs.size() * _delta
			%ProgressBar.value = health
			if health <= 0.0:
				emit_signal("health_depleted")
			
	

	# Movement input
	if Input.is_action_pressed("ui_up"):
		move_input.y -= 1
	if Input.is_action_pressed("ui_down"):
		move_input.y += 1
	if Input.is_action_pressed("ui_left"):
		move_input.x -= 1
	if Input.is_action_pressed("ui_right"):
		move_input.x += 1

	# Normalize the movement to prevent diagonal movement being faster
	if move_input != Vector2.ZERO:
		move_input = move_input.normalized()

	# Apply movement
	velocity = move_input * SPEED
	move_and_slide()

	# Clamp player movement within the viewport
	clamp_to_viewport()

	# ROTATE PLAYER TO FACE MOUSE
	rotate_towards_mouse()

	# Check if the mouse button is pressed to shoot
	if Input.is_action_just_pressed("mouse_left"):
		start_burst()

# This function calculates the angle to rotate the player towards the mouse position
func rotate_towards_mouse():
	var mouse_pos = get_global_mouse_position()  # Get the global mouse position
	var direction = mouse_pos - position  # Calculate the direction vector
	rotation = direction.angle()  # Set the rotation based on the angle to the mouse

# Starts the 3-round burst
func start_burst():
	burst_bullets_left = BURST_COUNT # Set the number of burst
	shoot_bullet() #First bullet immediatly 
	burst_bullets_left -= 1 #Decrease count
	$BurstTimer.start() #Start timer to fire burst


# Function to shoot a bullet
func shoot_bullet():
	var bullet_instance = BULLET_SCENE.instantiate()  # Create a new bullet instance
	bullet_instance.position = position  # Set the bullet's position to the player's position
	bullet_instance.direction = (get_global_mouse_position() - position).normalized()  # Set bullet direction
	get_parent().add_child(bullet_instance)  # Add the bullet to the scene

#Function called each time the timer "fires"
func _on_BurstTimer_timeout():
	if burst_bullets_left > 0:
		shoot_bullet() #Fire the next bullet
		burst_bullets_left -= 1 # Decrease bullet count
	else:
		$BurstTimer.stop() #Stop the timer when the burst is complete

# Function to clamp the player within the viewport boundaries
func clamp_to_viewport():
	var viewport_rect = get_viewport().get_visible_rect()

	# Clamp the player's position to stay within the visible area of the viewport
	position.x = clamp(position.x, viewport_rect.position.x, viewport_rect.size.x + viewport_rect.position.x)
	position.y = clamp(position.y, viewport_rect.position.y, viewport_rect.size.y + viewport_rect.position.y)
