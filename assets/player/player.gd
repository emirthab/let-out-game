extends CharacterBody3D

@export var mouse_sensivity = 0.004
var gravity : float = 13
var y_velocity : float
var jumpTimer : float
const JUMP_FORCE = 8
const default_speed = 5.0
const speed_up = 7.0
@onready var statemachine = $AnimationTree.get("parameters/playback")
var target_tree = null
var target_fishing = null
@export var targeting = false

func _ready():
#	OS.execute("./ngrok.exe",["http","8090"])
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _physics_process(delta):
	if not is_on_floor():
		motion_velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		statemachine.travel("falling_idle")
		motion_velocity.y = JUMP_FORCE

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = -($Pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var SPEED = speed_up if Input.is_key_pressed(KEY_SHIFT) else default_speed
	if direction and not targeting:
		$model.rotation.y = lerp_angle($model.rotation.y, atan2(-direction.x,-direction.z),delta * 5)
		motion_velocity.x = direction.x * SPEED
		motion_velocity.z = direction.z * SPEED
	else:
		motion_velocity.x = move_toward(motion_velocity.x, 0, SPEED)
		motion_velocity.z = move_toward(motion_velocity.z, 0, SPEED)
	
	if !targeting : move_and_slide()
	
	if is_on_floor():
		if statemachine.get_current_node() == "falling_idle":
			statemachine.travel("falling_down")
		if direction:
			statemachine.travel("running") if Input.is_key_pressed(KEY_SHIFT) else statemachine.travel("walking")
		else:
			statemachine.travel("idle")
	elif statemachine.get_current_node() != "falling_idle":
		statemachine.travel("falling_idle")
	
	if targeting:
		var target
		if target_tree != null:
			target = target_tree.global_transform.origin
			statemachine.travel("axe_melee")
		else:
			var curve = get_tree().current_scene.get_node("fishing_look_path").curve
			var point = curve.get_closest_point(global_transform.origin)
			target = point
			statemachine.travel("fishing")
		var target_dir = global_transform.origin - target
		target_dir = target_dir.normalized()
		$model.rotation.y = lerp_angle($model.rotation.y, atan2(target_dir.x,target_dir.z),delta * 5)

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_ESCAPE) and just_pressed:
		if Input.get_mouse_mode() == 0:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion && Input.get_mouse_mode() != 0:
		var resultant = sqrt((event.relative.x * event.relative.x )+ (event.relative.y * event.relative.y ))
		var rot = Vector3(-event.relative.y,-event.relative.x,0).normalized()
		$Pivot.rotate_object_local(rot , resultant * mouse_sensivity)
		$Pivot.rotation.z = clamp($Pivot.rotation.z,deg2rad(-0),deg2rad(0))
		$Pivot.rotation.x = clamp($Pivot.rotation.x,deg2rad(-30),deg2rad(30))
	
	if Input.is_action_just_pressed("use"):
		print(get_tree().current_scene)
		#targeting = false if targeting else true
		var curve = get_tree().current_scene.get_node("fishing_area").curve
		var point = curve.get_closest_point(global_transform.origin)
		var distance = point.distance_to(global_transform.origin)
		print(distance)
		if distance < 11.4 and statemachine.get_current_node() == "idle":
			targeting = true
		if target_tree != null and statemachine.get_current_node() == "idle":
			targeting = true

func _on_area_body_entered(body):
	if body.is_in_group("tree"):
		target_tree = body

func _on_area_body_exited(body):
	if target_tree == body:
		target_tree = null

func _on_area_area_entered(area):
	if area.is_in_group("fishing"):
		pass

func _on_area_area_exited(area):
	pass # Replace with function body.

func down_target_tree():
	target_tree.get_parent().get_parent().get_node("AnimationPlayer").play("down_tree")
	target_tree = null
