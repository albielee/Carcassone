extends Camera


onready var raycast = $RayCast

var worldPoint := Vector3(-1, -1, -1)

var raycast_position = Vector3(0,0,0)
var raycast_tile_collider_id = 0
var raycast_hovering_tile = null
var rot = 0
var zoomDist = 20
onready var rotateAbout = Vector3(35.2, transform.origin.y, 35.2)

func _physics_process(delta):
	cursor_raycast()
	camera_movement(delta)

func camera_movement(delta):
	#moving the camera around a point
	var moveCam = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	if(moveCam):
		rot += moveCam*delta * 75
	var rotSpeed = 100
	transform.origin = Vector3(rotateAbout.x + sin(rot/rotSpeed)*zoomDist, rotateAbout.y, rotateAbout.z + cos(rot/rotSpeed)*zoomDist)
	look_at(Vector3(rotateAbout.x, 0, rotateAbout.z), Vector3(0,1,0))
	#Zoom in
	if(Input.is_action_just_released("scroll_up")):
		zoomDist -= 1
	#zoom out
	if(Input.is_action_just_released("scroll_down")):
		zoomDist += 1
		
	#move around
	var moveSpeed = 25
	var vertical = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")

	rotateAbout += Vector3(vertical * moveSpeed * sin(rot/rotSpeed), 0, vertical * moveSpeed * cos(rot/rotSpeed))*delta
		
	
func cursor_raycast():
	if (InputEventMouseMotion):
		var mouse_position = get_tree().root.get_mouse_position()
		var raycast_from = project_ray_origin(mouse_position)
		var raycast_to = project_ray_normal(mouse_position)*1000

		# You might need a collision mask to avoid objects like the player...
		var space_state = get_world().direct_space_state
		var raycast_result = space_state.intersect_ray(raycast_from, raycast_to,[self],1, true, true)
		if(raycast_result):
			raycast_position = raycast_result.position
			var raycast_collider_children = raycast_result.collider.get_children()
			for child in raycast_collider_children:
				if(child.is_class("CollisionShape")):
					var shape = child.get_shape().get_extents()
					var shapePos = child.global_transform.origin
					if(is_point_in_shape(raycast_position, shape, shapePos)):
						if(child.get_name().length() > 3):
							raycast_tile_collider_id = int(child.get_name()[2] + child.get_name()[3])
							#print(child.get_name())
						else:
							raycast_tile_collider_id = int(child.get_name()[2])
							#print(child.get_name())
						#print(raycast_tile_collider_id)
						raycast_hovering_tile = raycast_result.collider
						#print(raycast_tile_collider_id)

func is_point_in_shape(point, shape, shapePos):
	to_global(shape)
	var minX = shapePos.x - shape.x
	var minZ = shapePos.z - shape.z
	var maxX = shapePos.x + shape.x
	var maxZ = shapePos.z + shape.z
	#print(shapePos.x)
	#print(shapePos.z)
	#print(point)
	#print("GAAAAAAAAAAAAP")
	if(point.x > minX and point.x <= maxX):
		if(point.z > minZ and point.z <= maxZ):
			return true
	return false

func get_raycast_hovering_tile():
	return raycast_hovering_tile

func get_raycast_collider_id():
	return raycast_tile_collider_id

func get_raycast_pos():
	return raycast_position

func point() -> void:
	if (raycast.is_colliding()):
		worldPoint = raycast.get_collision_point()
		#print(worldPoint)
	else:
		worldPoint = Vector3(-1, -1, -1)		



#func _process(delta):
#	point()
	#If raycast collides with table
	#if raycast.is_colliding():
	#	var obj = raycast.get_collider()
	#	print(obj.get_name())
