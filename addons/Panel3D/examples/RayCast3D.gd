extends RayCast3D

var prevHover
var pressed := false

var clicked := false

func _process(delta):
	var cam = get_viewport().get_camera_3d()
	global_position = cam.global_position
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		target_position = (cam.project_local_ray_normal(get_viewport().get_mouse_position()))*10.0
	else:
		target_position = Vector3(0,0,-10)
	if Input.get_mouse_button_mask() == MOUSE_BUTTON_LEFT and !clicked:
		clicked = true
	if Input.get_mouse_button_mask() == 0:
		clicked = false

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				4:
					scrollup()
				5:
					scrolldown()

func _physics_process(delta):
	var tmpcol
	var point = (target_position)
	if prevHover:
		print("prevhover")
		tmpcol = prevHover
		if is_colliding():
			point = get_collision_point()
			if get_collider() != prevHover and !pressed:
				tmpcol = get_collider()
				prevHover = tmpcol
		else:
			if !pressed:
				print('clear prevhover')
				prevHover = null
	elif is_colliding():
		print('colliding and not prevhover')
		tmpcol = get_collider()
		point = get_collision_point()
		prevHover = tmpcol
	if is_instance_valid(tmpcol) and "laser_input" in tmpcol:
		if clicked:
			if !pressed:
				click(tmpcol,point)
			else:
				tmpcol.laser_input({
					'hovering': prevHover == tmpcol,
					'pressed': pressed,
					'position': point,
					'action': 'hover'
				})
		elif !clicked:
			if pressed:
				release(tmpcol,point)
			else:
				tmpcol.laser_input({
					'hovering': prevHover == tmpcol,
					'pressed': pressed,
					'position': point,
					'action': 'hover'
				})

func scrollup():
	if is_colliding():
		var tmpcol = get_collider()
		if tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": true,
				"action": "scrollup"
				})
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				"action": "scrollup"
				})

func scrolldown():
	if is_colliding():
		var tmpcol = get_collider()
		if tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": true,
				"action": "scrolldown"
				})
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				"action": "scrolldown"
				})

func click(target:PhysicsBody3D,point:Vector3):
	if target.has_method("laser_input"):
		target.laser_input({
			"position": point,
			"pressed": true,
			'action': 'click'
			})
		pressed = true

func release(target:PhysicsBody3D,point:Vector3):
	if target.has_method("laser_input"):
		target.laser_input({
			"position": point,
			"pressed": false,
			'action': 'click'
			})
		pressed = false
