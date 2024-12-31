extends CharacterBody3D


## Speed used for ground movement
@export var SPEED : float = 5.0
## Multiplier for how fast the player is slowed while on the ground
@export var FLOOR_DAMP : float = .5
## Multiplier for how fast the player is slowed while in the air
@export var AIR_DAMP : float = .05
## Speed used for air movement
@export var AIR_SPEED : float = 5.0
## Veritcal velocity impulse for jumping while on the ground
@export var JUMP_VELOCITY : float = 5
## Multiplier used for jumping off the wall
@export var WALL_JUMP_VELOCITY : float = 6
## Default falling speed
@export var FALL_SPEED : float = 10
## Falling speed while attached to a wall
@export var WALL_FALL_SPEED : float = 1
## The amount of time that it takes to interpolate WALL_FALL_SPEED to FALL_SPEED
## while the player is touching a wall
## (timer gets reset when a player is not exclusively touching a wall)
@export var WALL_FALL_SPEED_TIMER : float = 1.0
## Mouse sensitivity
@export var MOUSE_SENSITIVITY : float = 20.0
## Camera motion mode (should the camera have the 'look through the legs' system)
## 0 is for normal camera, 1 is for leg vision camera
@export var CAMERAMOTIONMODE : int = 0
## Max number of jumps. [br]Initial leap off the ground counts as a jump[br]jumps are
## refreshed instantly upon touching the ground or a wall
@export var JUMPS : int = 10
## Amount of time (in seconds) that the player has after leaving the ground
## before their ground jump is exhausted (if they jumped to leave the ground
## the jump is exhausted anyway)
@export var JUMP_GRACE_PERIOD : float = 0.1
## Amount of time (in seconds) that the jump action will be buffered when the 
## player tries to jump. This allows the player to try to jump early and still
## perform a jump if jumping is allowed before the timer expires.
@export var JUMP_BUFFER : float = .2
## Velocity multiplier for boosting the player speed while in the air
@export var AIR_JUMP_BOOST : float = 1.1
## Limit for how fast the player can be moving before the [code]AIR_JUMP_BOOST[/code] no longer boost in the current direction
@export var MAX_AIR_JUMP_BOOST_SPEED : float = 10.0
## Velocity multiplier for boosting the player speed while on the wall
@export var WALL_JUMP_BOOST : float = 1.4
## Limit for how fast the player can be moving before the [code]WALL_JUMP_BOOST[/code] no longer boost in the current direction
@export var MAX_WALL_JUMP_BOOST_SPEED : float = 10.0
## Velocity multiplier for boosting the player speed while on the ground
@export var FLOOR_JUMP_BOOST : float = 1.2
## Limit for how fast the player can be moving before the [code]FLOOR_JUMP_BOOST[/code] no longer boost in the current direction
@export var MAX_FLOOR_JUMP_BOOST_SPEED : float = 20.0
var currentFallSpeed : float
@onready var camparent = $camparent
@onready var camera :Camera3D= %Camera3D
@onready var overlay :Control= $overlay
@onready var line_3d :Line3D= $Line3D
@onready var line_2d :Line2D= $Control/Line2D
@onready var stepupshapecast = $stepupshapecast
@onready var shootcast = $camparent/Camera3D/shootcast
@onready var player_collision_shape = $CollisionShape3D
@onready var headcollider: CollisionShape3D = $headcollider

var jumps : int = JUMPS
var crouched : bool = false
var jump_grace_period_timer : float = 0.0
var jump_buffer_timer : float = 0.0
var jumped : bool = false
var tryjump : bool = false
var walltime : float = 0.0

func _ready():
	shootcast.add_exception(self)
	currentFallSpeed = FALL_SPEED
	overlay.connect("gui_input", overlayInput)

func _process(delta):
	line_3d.target = (velocity * basis)
	line_2d.set_point_position(1,Vector2((velocity * basis).x,(velocity * basis).z)*20.0)
	if Input.is_action_just_pressed("inspectorsummon"):
		get_tree().get_first_node_in_group("sceneeditor").global_position = get_viewport().get_camera_3d().to_global(Vector3.FORWARD)
		get_tree().get_first_node_in_group("sceneeditor").look_at(get_viewport().get_camera_3d().global_position,Vector3.UP,true)

func _physics_process(delta):
	headcollider.global_position = camera.global_position
	# if the player touches the wall or the floor, reset number of jumps
	if is_on_wall() or stepupshapecast.is_colliding():
		if jumped:
			jumped = false
		if !jumped:
			jumps = JUMPS
		jump_grace_period_timer = 0.0
	if jump_grace_period_timer + delta > JUMP_GRACE_PERIOD and jumps == JUMPS:
		jumps -= 1
	jump_grace_period_timer += delta
	if JUMP_BUFFER > 0.0:
		jump_buffer_timer += delta
	if tryjump and jump_buffer_timer > JUMP_BUFFER:
		tryjump = false
	var input_dir := Vector2()
	var direction := Vector3()
	# if mouse is captured by the window...
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# get the direction vector from the directional inputs
		input_dir = Input.get_vector("left", "right", "forward", "backward")
		# translate the input directions to relative to what direction the player is facing
		direction = ((camera.global_basis * Vector3(input_dir.x, 0, input_dir.y))*Vector3(1.0,0.0,1.0)).normalized()
		# and the jump button was just pressed, then jump
		if tryjump:
			if JUMP_BUFFER == 0:
				tryjump = false
			jumped = true
			jump(direction)
		# and the escape button was just pressed, unlock the mouse
		if Input.is_action_just_pressed("esc"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# if player is not on the floor
	if not stepupshapecast.is_colliding() or Input.is_action_pressed("slide"):
		# if the player is touching a wall
		if is_on_wall():
			#velocity.x *= 1.0+delta
			#velocity.z *= 1.0+delta
			# if the player is trying to move away from the wall, then unsnap them from the wall
			if direction.dot(Vector3(get_wall_normal().x,0,get_wall_normal().z))<.9:
				# push the player toward the wall to snap them to the wall
				velocity.x += (get_wall_normal()*-100.0).x*delta
				velocity.z += (get_wall_normal()*-100.0).z*delta
			# set the gravity to the wall running fall speed
			if velocity.y < 0:
				currentFallSpeed = lerpf(WALL_FALL_SPEED, FALL_SPEED, clamp( remap(walltime,0.0,WALL_FALL_SPEED_TIMER, 0.0, 1.0), 0.0, 1.0 ))
		# otherwise, set the gravity to the normal falling speed
		else:
			currentFallSpeed = FALL_SPEED
		# add the appropriate gravity
		velocity.y -= currentFallSpeed * delta
	
	if direction:
		var flat_velocity := Vector2(velocity.x,velocity.z)
		if stepupshapecast.is_colliding() and !jumped and !Input.is_action_pressed("slide"):
			velocity.x += (direction.x * (SPEED)*10)*delta
			velocity.z += (direction.z * (SPEED)*10)*delta
		else:
			var veladd :Vector3 = (direction * (AIR_SPEED)*2.0)*delta
			var wallmod = 1.0
			if is_on_wall():
				wallmod = 2.0
			if (flat_velocity.length() < AIR_SPEED*wallmod) or Vector2((velocity+veladd).x,(velocity+veladd).z).length() < flat_velocity.length():
				velocity.x += veladd.x
				velocity.z += veladd.z
			else:
				#print('other air move')
				var tmp := flat_velocity.length()
				velocity.x += (direction.x * (AIR_SPEED)*2.0)*delta
				velocity.z += (direction.z * (AIR_SPEED)*2.0)*delta
				var velmod := Vector2(velocity.x,velocity.z).normalized()*tmp
				velocity.x = velmod.x
				velocity.z = velmod.y
	#else:
	if stepupshapecast.is_colliding() and !Input.is_action_pressed("slide"):
		velocity.x = lerpf(velocity.x,0.0,(FLOOR_DAMP*delta)*10)
		velocity.z = lerpf(velocity.z,0.0,(FLOOR_DAMP*delta)*10)
	else:
		velocity.x = lerpf(velocity.x,0.0,(AIR_DAMP*delta)*1)
		velocity.z = lerpf(velocity.z,0.0,(AIR_DAMP*delta)*1)
	
	# limit the fall speed while touching a wall to emulate wall running behavior
	if is_on_wall_only():
		if velocity.y < -currentFallSpeed: velocity.y = move_toward(velocity.y, -currentFallSpeed, SPEED)
		walltime += delta
	else:
		walltime = 0.0
	
	if Input.is_action_pressed("slide"):
		floor_stop_on_slope = false
	else:
		floor_stop_on_slope = true
	
	move_and_slide()


func _input(event):
	match CAMERAMOTIONMODE:
		0:
			if event is InputEventMouseMotion:
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					find_child("mouselabel").text = ("move by: " + str((-event.relative.x/10000.0)*MOUSE_SENSITIVITY) )
					find_child("mouselabel").text += "mouse sens: " + str(MOUSE_SENSITIVITY)
					if OS.get_name() == "Web":
						rotation.y += (-event.relative.x/10000.0)*(MOUSE_SENSITIVITY*4.0)
						camera.rotation.x += (-event.relative.y/10000.0)*(MOUSE_SENSITIVITY*4.0)
					rotation.y += (-event.relative.x/10000.0)*MOUSE_SENSITIVITY
					camera.rotation.x += (-event.relative.y/10000.0)*MOUSE_SENSITIVITY
		1:
			if event is InputEventMouseMotion:
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					# head tilting down, not looking up, not looking between legs
					if (camparent.rotation_degrees.x >= -170.0) and (camparent.rotation_degrees.x <= 0.0) and camera.rotation_degrees.x == 0.0:
						camparent.rotate(Vector3.RIGHT, (-event.relative.y/10000)*MOUSE_SENSITIVITY)
						camera.rotation.x = 0.0
						rotate(Vector3.UP, (-event.relative.x/10000)*MOUSE_SENSITIVITY)
					# head looking up 
					elif camera.rotation_degrees.x >= -45 and camera.rotation_degrees.x <= 90.0:
						camera.rotate(Vector3.RIGHT, (-event.relative.y/10000)*MOUSE_SENSITIVITY)
						rotate(Vector3.UP, (-event.relative.x/10000)*MOUSE_SENSITIVITY)
					# prevents head from going beyond a safe point while looking
					# between the legs
					if camera.rotation_degrees.x < -45:
						camera.rotation_degrees.x = -45
					# prevents head from looking too far up, which will lock the
					# camera because of the hard if statement logic here
					if camera.rotation_degrees.x > 90.0:
						camera.rotation_degrees.x = 90.0
					# allows the camera to look back up
					if camera.rotation_degrees.x > 0.0 and (camparent.rotation_degrees.x < -170.0):
						camera.rotation.x = 0.0
						camparent.rotation_degrees.x = -170.0
					if camera.rotation_degrees.x < 0.0 and (camparent.rotation_degrees.x > 0.0):
						camera.rotation.x = 0.0
						camparent.rotation_degrees.x = 0.0
	if event.is_action_pressed("jump"):
		tryjump = true
		jump_buffer_timer = 0.0

func overlayInput(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func jump(direction:Vector3):
	if jumps > 0:
		tryjump = false
		jumps -= 1
		if stepupshapecast.is_colliding():
			velocity.x *= (FLOOR_JUMP_BOOST)
			velocity.z *= (FLOOR_JUMP_BOOST)
			velocity += get_floor_normal()*JUMP_VELOCITY
		elif is_on_wall():
			velocity.x *= (WALL_JUMP_BOOST)
			velocity.z *= (WALL_JUMP_BOOST)
			velocity += get_wall_normal()*WALL_JUMP_VELOCITY
			velocity.y += JUMP_VELOCITY+(WALL_JUMP_VELOCITY/8)
		else:
			velocity.x *= (AIR_JUMP_BOOST)
			velocity.z *= (AIR_JUMP_BOOST)
			if velocity.y < 0.0:
				velocity.y = JUMP_VELOCITY
			else:
				velocity.y += JUMP_VELOCITY
