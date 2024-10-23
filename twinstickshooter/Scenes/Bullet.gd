extends Area2D  # Changed from CharacterBody2D to Area2D

var speed = 600.0  # Bullet speed
var direction = Vector2.ZERO  # The direction the bullet moves
var damage = 1  # Bullet damage

#func _ready():
	# Connect the body_entered signal to handle collision
	#connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	# Update bullet position based on direction and speed
	position += direction * speed * delta

	# Remove bullet if it goes off-screen
	if is_outside_viewport():
		queue_free()

# Function to handle collisions when the bullet collides with another body
func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
		queue_free()  # Destroy the bullet after impact

# Function to check if the bullet goes off-screen
func is_outside_viewport() -> bool:
	var viewport_rect = get_viewport().get_visible_rect()
	return not viewport_rect.has_point(position)
