extends CharacterBody3D

# Settings.
const WALK_SPEED: float = 5.0 # 5.0
const SPRINT_MULTIPLIER: float = 2.0 #2.0
const CROUCH_MULTIPLIER: float = 0.5
const TERMINAL_GRAVITATIONAL_VELOCITY := -53.0

const CROUCH_TRANSITION_SPEED: float = 0.1
const COLLIDER_REGULAR_HEIGHT: float = 1.8
const COLLIDER_CROUCH_HEIGHT: float = 0.9
const HEAD_CROUCH_HEIGHT := 0.9
const HEAD_STANDING_HEIGHT := 1.8

const MOUSE_SENSITIVITY: float = 0.002
const CAMERA_UPPER_CLAMP: float = 90.0 # These two are later converted to radians.
const CAMERA_LOWER_CLAMP: float = -90.0

const AIR_ACCELERATION: float = 10.0
const REGULAR_ACCELERATION: float = 20.0
const JUMP_POWER: float = 7.5
const GRAVITY: float = 45.0

# Camera.
var mouse_rotation := Vector3.ZERO
var camera_upper_clamp_rad: float # These two are the ones used to clamp the vertical look direction.
var camera_lower_clamp_rad: float # They get their values in radians in _ready().
var camera_position_offset: Vector3

# Movement.
var gravity_vector := Vector3()
var movement := Vector3() # Final movement direction and magnitude for one tick.
var horizontal_velocity := Vector3() # Horizontal velocity, determined by walk, crouch and sprint speeds.
var original_horizontal_velocity := Vector3() # Used for preserving momentum when transitioning between different movement states.
var direction := Vector3() # Input direction.
var way_facing # Used instead of basis.
var current_collider_height: float = 1.8 # Used for shrinking the collider when crouching.

# Movement states.
enum MovementStates {IN_AIR, ON_GROUND, SWIMMING, NO_CLIP}
var current_movement_state := MovementStates.IN_AIR

# Movement flags.
var is_grounded: bool = false
var can_jump: bool = false
var is_momentum_preserved: bool = false
var is_head_bonked: bool = false
var offset_velocity := Vector3.ZERO
var no_clip: bool = false

# Input flags.
var request_sprinting: bool = false
var request_crouching: bool = false
var request_jump: bool = false
var placing_block: bool = false
var breaking_block: bool = false
var max_block_change_delay: int = 10
var current_block_change_delay: int = max_block_change_delay

@onready var camera: Camera3D = $Camera3D
@onready var collider = $CollisionShape
@onready var test_mesh = $human
@onready var inventory = $Inventory
var block_outline: Node3D
var current_block_normal: Vector3 = Vector3.ZERO
var world: Node3D

func _enter_tree() -> void:
	#name = str(get_multiplayer_authority())
	
	set_multiplayer_authority(str(name).to_int())

func _ready():
	
	if not is_multiplayer_authority(): return
	camera.current = true
	
	# Convert these two to radians.
	camera_upper_clamp_rad = deg_to_rad(CAMERA_UPPER_CLAMP)
	camera_lower_clamp_rad = deg_to_rad(CAMERA_LOWER_CLAMP)
	
	# Camera position is calculated in global space,
	# so we get the offset from the actual body by doing this.
	camera_position_offset = camera.global_position - global_position
	
	# Keep the mouse positioned at screen centre.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	# Only look around if the mouse is invisible.
	if event is InputEventMouseMotion:
		var relative_mouse_motion: Vector2 = event.relative
		process_camera_rotation(relative_mouse_motion)
	
	# Which way we are going to move.
	direction = Vector3()
	
	# Forwards/backwards and left/right input and movement.
	# Direction is taken according to the camera y axis instead of the actual
	# body so that we don't get weird physics rotation stuff!
	direction += -global_transform.basis.x.rotated(Vector3(0, 1 ,0), camera.rotation.y) * (Input.get_action_strength("move_left") - Input.get_action_strength("move_right"))
	direction += -global_transform.basis.z.rotated(Vector3(0, 1, 0), camera.rotation.y) * (Input.get_action_strength("move_forwards") - Input.get_action_strength("move_backwards"))
	
	# Ensure we aren't faster when moving diagonally.
	direction = direction.normalized()
	
	# These requests influence check_movement_flags(), which determines
	# the outcome of process_movement().
	if Input.is_action_pressed("sprint"):
		request_sprinting = true
	else:
		request_sprinting = false
	
	if Input.is_action_pressed("crouch"):
		request_crouching = true
	else:
		request_crouching = false
	
	if Input.is_action_pressed("jump"):
		request_jump = true
	else:
		request_jump = false
	
	if Input.is_action_just_pressed("no_clip"):
		no_clip = !no_clip
	
	if Input.is_action_pressed("break_block"):
		breaking_block = true
	else:
		breaking_block = false
	
	if Input.is_action_pressed("place_block"):
		placing_block = true
	else:
		placing_block = false
	

func _process(delta):
	if not is_multiplayer_authority(): return
	
	process_mesh_transform()
	
	process_camera_position()
	process_camera_fov_change()
	
	set_block_outline()
		
	# cubic interpolation

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	check_movement_flags()
	handle_crouching()
	process_movement_state(delta)
	process_voxel_edits()
	
	test_mesh.rotation.y = camera.rotation.y

func process_voxel_edits() -> void:
	if !block_outline.visible:
		return
	
	
	current_block_change_delay -= 1
	if current_block_change_delay < 0:
		current_block_change_delay = 0
	if !current_block_change_delay < 1:
		return
	
	if placing_block:
		current_block_change_delay = max_block_change_delay
		var voxel_position: Vector3 = block_outline.position + (current_block_normal)
		
		if Vector3i(position) == Vector3i(voxel_position):
			return
		if Vector3i(position.x, position.y + 1, position.z) == Vector3i(voxel_position):
			return
		
		var chunk: Chunk = world.get_chunk_from_vector3(voxel_position)
		
		voxel_position.x -= chunk.position.x
		voxel_position.z -= chunk.position.z
		
		chunk.set_voxel(voxel_position, 4)
		chunk.update()
		# Convert the voxel position back into global space.
		var voxels_to_update: Array = chunk.get_surrounding_voxels(voxel_position.x + chunk.position.x, voxel_position.y, voxel_position.z + chunk.position.z)
		
		print(voxels_to_update)
		if voxels_to_update:
			for i in range(voxels_to_update.size()):
				#print(i)
				var chunk_to_update = world.get_chunk_from_vector3(voxels_to_update[i])
				print("updateing chunk:" + str(chunk_to_update))
				chunk_to_update.update()
	
	if breaking_block:
		current_block_change_delay = max_block_change_delay
		
		var voxel_position: Vector3 = block_outline.position
		var chunk: Chunk = world.get_chunk_from_vector3(voxel_position)
		
		voxel_position.x -= chunk.position.x
		voxel_position.z -= chunk.position.z
		
		#print(chunk)
		chunk.set_voxel(voxel_position, 0)
		chunk.get_surrounding_voxels(voxel_position.x, voxel_position.y, voxel_position.z)
		chunk.update()
		#chunk.mesh = chunk.create_mesh()
		#chunk.mesh.surface_set_material(0, material)

func set_block_outline() -> void:
	var space_state = get_world_3d().direct_space_state
	
	var start_position: Vector3 = camera.global_transform.origin
	var end_position: Vector3 = camera.global_transform.origin + camera.global_transform.basis.z * -5
	
	var ray_parameters := PhysicsRayQueryParameters3D.create(
			start_position,
			end_position,
			1)
	
	ray_parameters.exclude = [self]
	
	var collision = space_state.intersect_ray(ray_parameters)
	if collision:
		current_block_normal = collision["normal"]
		block_outline.position = Vector3i(collision["position"] - (current_block_normal / 2))
		
		block_outline.show()
	else:
		block_outline.hide()

func check_movement_flags() -> void:
	"""
	Checks the current movement situation of the player.
	"""
	collider.disabled = false # By default.
	
	if no_clip:
		collider.disabled = true
		current_movement_state = MovementStates.NO_CLIP
		return
	
	if is_on_floor():
		current_movement_state = MovementStates.ON_GROUND
		return
	else:
		current_movement_state = MovementStates.IN_AIR
		return
func process_movement_state(delta) -> void:
	match current_movement_state:
		MovementStates.ON_GROUND:
			ground_move(delta)
		MovementStates.IN_AIR:
			air_move(delta)
		MovementStates.SWIMMING:
			print("swim")
		MovementStates.NO_CLIP:
			no_clip_move(delta)
	
	rpc("remote_set_position", global_position, test_mesh.global_rotation)
	

@rpc("unreliable")
func remote_set_position(authority_position, authority_rotation):
	#print(authority_position)
	#get_tree().get_remote_sender_id()
	#get_remote_sender_id()
	global_position = authority_position
	test_mesh.global_rotation = authority_rotation

func no_clip_move(delta) -> void:
	if request_sprinting:
		horizontal_velocity = horizontal_velocity.lerp(
				direction * (WALK_SPEED * SPRINT_MULTIPLIER),
				REGULAR_ACCELERATION * delta)
	else:
		horizontal_velocity = horizontal_velocity.lerp(
				direction * WALK_SPEED,
				REGULAR_ACCELERATION * delta)
	
	# Flying.
	if request_crouching:
		movement.y = -7
	elif request_jump:
		movement.y = 7
	else:
		movement.y = 0.0
	# Movement vector calculated from horizontal direction and gravity.
	movement.z = horizontal_velocity.z + gravity_vector.z
	movement.x = horizontal_velocity.x + gravity_vector.x
	
	# Final velocity calculated from movement.
	set_velocity(movement)
	
	# Actually move the player.
	move_and_slide()

func ground_move(delta) -> void:
	# TODO: So we don't hop and slide along if holding down jump.
	#cancel_momentum()
	is_momentum_preserved = false
	offset_velocity = Vector3.ZERO
	
	
	# Change gravity direction so we stick to slopes if moving down them.
	# Also multiply gravity by some small value when on the ground so that we will still
	# stick to the ground, but won't immediately fall fast if we go off a slope.
	gravity_vector = -get_floor_normal() #* (GRAVITY * 0.1)
	
	if request_sprinting:
		horizontal_velocity = horizontal_velocity.lerp(
				direction * (WALK_SPEED * SPRINT_MULTIPLIER),
				REGULAR_ACCELERATION * delta) # TODO: is delta frame-independent?
	else:
		horizontal_velocity = horizontal_velocity.lerp(
				direction * WALK_SPEED,
				REGULAR_ACCELERATION * delta)
	if request_crouching:
		horizontal_velocity = horizontal_velocity * CROUCH_MULTIPLIER
	
	if request_jump:
		jump()
	
	# Movement vector calculated from horizontal direction and gravity.
	movement.z = horizontal_velocity.z + gravity_vector.z
	movement.x = horizontal_velocity.x + gravity_vector.x
	
	# Limit gravity vector by terminal velocity.
	if gravity_vector.y < TERMINAL_GRAVITATIONAL_VELOCITY:
		gravity_vector.y = TERMINAL_GRAVITATIONAL_VELOCITY
	else:
		movement.y = gravity_vector.y
	
	# Final velocity calculated from movement.
	set_velocity(movement)
	
	# Actually move the player.
	move_and_slide()

func air_move(delta) -> void:
	if is_on_ceiling():
		gravity_vector.y += -movement.y
	
	gravity_vector += Vector3.DOWN * GRAVITY * (delta / 2) # Fall to the ground.
	
	# Makes the player slow down or speed up, depending on what they hit.
	var fr_fr = get_real_velocity()
	horizontal_velocity.x = fr_fr.x
	horizontal_velocity.z = fr_fr.z
	
	# Get the velocity over ground from when we jumped / became airborne.
	if not is_momentum_preserved:
		original_horizontal_velocity = horizontal_velocity
		is_momentum_preserved = true
	
	offset_velocity = direction / 2
	
	horizontal_velocity = horizontal_velocity + offset_velocity
	
	if original_horizontal_velocity.length() <= WALK_SPEED:
		horizontal_velocity = clamp_vector(horizontal_velocity, WALK_SPEED)
	else:
		horizontal_velocity = clamp_vector(horizontal_velocity, original_horizontal_velocity.length())
	
	# Reduce or increase horizontal velocity in case we hit something.
	
	
	# Crouch sliding.
	
	# Movement vector calculated from horizontal direction and gravity.
	movement.z = horizontal_velocity.z + gravity_vector.z
	movement.x = horizontal_velocity.x + gravity_vector.x
	
	# Limit gravity vector by terminal velocity.
	if gravity_vector.y < TERMINAL_GRAVITATIONAL_VELOCITY:
		gravity_vector.y = TERMINAL_GRAVITATIONAL_VELOCITY
	else:
		movement.y = gravity_vector.y
	
	#if is_on_ceiling():
		#movement.y += gravity_vector.y
	
	# Final velocity calculated from movement.
	set_velocity(movement)
	
	# Actually move the player.
	move_and_slide()

func jump() -> void:
	"""Launches the player vertically."""
	gravity_vector = Vector3.UP * JUMP_POWER

func cancel_momentum() -> void:
	horizontal_velocity = Vector3.ZERO

func process_camera_rotation(relative_mouse_motion) -> void:
	# Horizontal mouse look.
	mouse_rotation.y -= relative_mouse_motion.x * MOUSE_SENSITIVITY
	# Vertical mouse look.
	mouse_rotation.x = clampf(mouse_rotation.x - (relative_mouse_motion.y * MOUSE_SENSITIVITY),
			camera_lower_clamp_rad,
			camera_upper_clamp_rad)
	
	# Rotate head independently of body.
	# This camera also determines the local direction of WASD.
	camera.rotation.x = mouse_rotation.x
	camera.rotation.y = mouse_rotation.y

func process_camera_position() -> void:
	# TODO: global and local target positions?
	
	#var camera_position = Vector3.ZERO
	
	#camera.global_position = camera_position.lerp(camera_target_position, delta)
	
	camera.global_position = global_position + camera_position_offset
	
#	if request_crouching:
#		camera.global_position = camera.global_position.lerp(Vector3(0, 1, 0), CROUCH_TRANSITION_SPEED)
#	else:
#		camera.global_position = camera.global_position.lerp(Vector3(0, 2, 0), CROUCH_TRANSITION_SPEED)
	
func process_camera_fov_change() -> void:
	pass
	# TODO look into tweens for this
	
	#var camera_fov_change = (velocity.length_squared() / 100)
	#camera.fov = camera.fov * camera_fov_change

func process_mesh_transform() -> void:
	test_mesh.rotation.y = camera.rotation.y + PI

func clamp_vector_with_offset(vector, clamp_origin, clamp_length):
	var offset = vector - clamp_origin
	var offset_length = offset.length()
	if offset_length <= clamp_length:
		return vector
	return clamp_origin + offset * (clamp_length / offset_length)

func handle_crouching() -> void:
	
	# Change colliders when crouching TODO explain
	# Head movement is 
	if request_crouching or is_head_bonked:
		current_collider_height -= CROUCH_TRANSITION_SPEED
		#head.translation = head.translation.linear_interpolate(Vector3(0, 1.25, 0), CROUCH_TRANSITION_SPEED)
	else:
		current_collider_height += CROUCH_TRANSITION_SPEED
		#head.translation = head.translation.linear_interpolate(Vector3(0, 1.8, 0), CROUCH_TRANSITION_SPEED)
	
	# Crouch and regular height determine the shortest and highest we can stand, respectively.
	current_collider_height = clamp(current_collider_height, COLLIDER_CROUCH_HEIGHT, COLLIDER_REGULAR_HEIGHT)
	
	collider.shape.size = Vector3(0.4, current_collider_height, 0.4)
	
# Used instead of clamp() so that the vector in question is limited
# to a circle instead of a square.
func clamp_vector(vector: Vector3, clamp_length: float) -> Vector3:
	if vector.length() <= clamp_length:
		return vector
	return vector * (clamp_length / vector.length())
