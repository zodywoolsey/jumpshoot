extends CharacterBody3D


@export var SPEED : float = 5.0
@export var AIR_SPEED : float = 5.0
@export var MAX_SPEED_MULT : float = 2
@export var JUMP_VELOCITY : float = 5
@export var WALL_JUMP_VELOCITY : float = 6
@export var FALL_SPEED : float = 10
@export var WALL_FALL_SPEED : float = 1
@export var MOUSE_SENSITIVITY : float = 10
var currentFallSpeed
@onready var camera = $Camera3D
@onready var overlay = $overlay

var mouseMotion : Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	currentFallSpeed = FALL_SPEED
	overlay.connect("gui_input", overlayInput)

func _physics_process(delta):
	var input_dir = Vector2()
	if not is_on_floor():
		velocity.y -= currentFallSpeed * delta
	
	if is_on_wall_only() and velocity.y < 0:
		currentFallSpeed = WALL_FALL_SPEED
	else:
		currentFallSpeed = FALL_SPEED
	
	
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate(Vector3.UP, (-mouseMotion.x/10000)*MOUSE_SENSITIVITY)
		camera.rotate(Vector3.RIGHT, (-mouseMotion.y/10000)*MOUSE_SENSITIVITY)
		if Input.is_action_just_pressed("jump"):
			jump()
			
		if Input.is_action_just_pressed("esc"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	if direction:
		if is_on_floor():
			velocity.x = move_toward(velocity.x,direction.x * SPEED, SPEED)
			velocity.z = move_toward(velocity.z,direction.z * SPEED, SPEED)
		else:
			velocity.x = move_toward(velocity.x,direction.x * AIR_SPEED, AIR_SPEED/8)
			velocity.z = move_toward(velocity.z,direction.z * AIR_SPEED, AIR_SPEED/8)
	else:
		if is_on_floor():
			velocity.x *= 1/MAX_SPEED_MULT
			velocity.z *= 1/MAX_SPEED_MULT
		else:
			velocity.x *= .99
			velocity.z *= .99
	
	if velocity.x > SPEED*MAX_SPEED_MULT: velocity.x = move_toward(velocity.x, SPEED*MAX_SPEED_MULT, SPEED)
	if velocity.y > SPEED*MAX_SPEED_MULT: velocity.y = move_toward(velocity.y, SPEED*MAX_SPEED_MULT, SPEED)
	if velocity.z > SPEED*MAX_SPEED_MULT: velocity.z = move_toward(velocity.z, SPEED*MAX_SPEED_MULT, SPEED)
	if velocity.x < -SPEED*MAX_SPEED_MULT: velocity.x = move_toward(velocity.x, -SPEED*MAX_SPEED_MULT, SPEED)
	if velocity.y < -currentFallSpeed: velocity.y = move_toward(velocity.y, -currentFallSpeed, SPEED)
	if velocity.z < -SPEED*MAX_SPEED_MULT: velocity.z = move_toward(velocity.z, -SPEED*MAX_SPEED_MULT, SPEED)
	
	move_and_slide()
	mouseMotion = Vector2()


func _input(event):
	if event is InputEventMouseMotion:
		mouseMotion = event.relative

func overlayInput(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func jump():
	if is_on_floor():
		velocity.y += JUMP_VELOCITY
	elif is_on_wall():
		velocity += get_wall_normal()*WALL_JUMP_VELOCITY
		velocity.y += JUMP_VELOCITY+(WALL_JUMP_VELOCITY/8)
