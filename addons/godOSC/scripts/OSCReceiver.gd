@icon("res://addons/godOSC/images/OSCReceiver.svg")
@tool
class_name OSCReceiver
extends Node
## Generic node for Receiving OSC messages. Must have an active OSCServer in the scene to work. 
## Make this node the child of a node you want to control with OSC. To add your own code, extend the 
## script attached to the OSCReceiver you create by right clicking and "extend script"

## The OSCServer to receive messages from
@export var target_server : OSCServer:
	set(new_server):
		if new_server != target_server:
			target_server = new_server
		update_configuration_warnings()

## The OSC address to receive
@export var osc_address := "/example"

## Get the parent of this node
@onready var parent = get_parent()

@export_category("Parent Control")

## How the OSCReceiver controls the parent node
@export_enum("Custom", "Position", "Scale") var parent_control_setting = 0

## For custom control, if true only runs the custom control code when a new message is received, otherwise runs the code continuosly. Note, this *must* be set to false to use interpolation in a custom message control. ie.:  using lerp() 
@export var on_message_received = true
## Applys a single incoming value to all axis.
@export var apply_to_all_axis := false

@export_group("Position")
## The amount of position offset applied to the incoming data
@export var position_offset := Vector3.ZERO

## Remaps incoming data for position. The first two vectors define the incoming bounds and the last two vectors define the range to map to.
@export var position_remap := [
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO
]

## Enables/disables position remapping
@export var enable_position_remap := false

@export_group("Scale")
## The amount of scale offset applied to the incoming data
@export var scale_offset := Vector3.ZERO

## Remaps incoming data for scale. The first two vectors define the incoming bounds and the last two vectors define the range to map to.
@export var scale_remap := [
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO
]

## Enables/disables scale remapping
@export var enable_scale_remap := false


@export_group("Interpolation")

## Applies linear interpolation between previous position/scale and incoming position/scale.
@export var interpolation := false

## The linear interpolation factor
@export var interpolation_factor := 0.5

var full_message = []
var incoming_values = []

var previous_value = []
func _ready() -> void:
	
	if Engine.is_editor_hint():
		return
		
	target_server.message_received.connect(received_message)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
# OSC messages are stored as a dictionary held in OSCServer variable incoming_messages, which uses a string for the
# key and an array to store the data. To access the data use the following format: 
# target_server.incoming_messages[osc_address][0]
func _process(delta):
	
	if Engine.is_editor_hint():
		return
	
	if incoming_values == [] or full_message[0] != osc_address:
		return
	
	if interpolation and !apply_to_all_axis:
		match parent_control_setting:
			0:
				if !on_message_received:
					_custom_control(full_message[0], full_message[1], full_message[2])
					pass
				else:
					pass
			1:
				if parent is Node2D or parent is Control:
					interpolated_position_control_2d(incoming_values[0], incoming_values[1])
				elif parent is Node3D:
					interpolated_position_control_3d(incoming_values)
			2:
				
				if parent is Node2D or parent is Control:
					interpolated_scale_control_2d(incoming_values[0], incoming_values[1])
				if parent is Node3D:
					interpolated_scale_control_3d(incoming_values)
	elif !apply_to_all_axis:
		match parent_control_setting:
			0:
				if !on_message_received:
					_custom_control(full_message[0], full_message[1], full_message[2])
					pass
				else:
					pass
			1:
				if parent is Node2D or parent is Control:
					non_interpolated_position_control_2d(incoming_values[0], incoming_values[1])
				if parent is Node3D:
					non_interpolated_position_control_3d(incoming_values)
			2:
				if parent is Node2D or parent is Control:
					non_interpolated_scale_control_2d(incoming_values[0], incoming_values[1])
				if parent is Node3D:
					non_interpolated_scale_control_3d(incoming_values)
	
	
	elif interpolation:
		match parent_control_setting:
			0:
				if !on_message_received:
					_custom_control(full_message[0], full_message[1], full_message[2])
					pass
				else:
					pass
			1:
				
				if parent is Node2D or parent is Control:
					interpolated_position_control_2d(incoming_values[0], incoming_values[0])
				if parent is Node3D:
					interpolated_position_control_3d([incoming_values[0], incoming_values[0], incoming_values[0]])
			2:
				
				if parent is Node2D or parent is Control:
					interpolated_scale_control_2d(incoming_values[0], incoming_values[0])
				if parent is Node3D:
					interpolated_scale_control_3d([incoming_values[0], incoming_values[0], incoming_values[0]])
	else:
		match parent_control_setting:
			0:
				if !on_message_received:
					_custom_control(full_message[0], full_message[1], full_message[2])
					pass
				else:
					pass
			1:
				if parent is Node2D or parent is Control:
					non_interpolated_position_control_2d(incoming_values[0], incoming_values[0])
				if parent is Node3D:
					non_interpolated_position_control_3d([incoming_values[0], incoming_values[0], incoming_values[0]])
			2:
				if parent is Node2D or parent is Control:
					non_interpolated_scale_control_2d(incoming_values[0], incoming_values[0])
				if parent is Node3D:
					non_interpolated_scale_control_3d([incoming_values[0], incoming_values[0], incoming_values[0]])
	
	
	
	previous_value = incoming_values
	
	pass



func _custom_control(address : String, vals : Array, time):
	
	
	pass


func received_message(address, vals, time):
	if not vals is Array:
		vals = [vals]
	full_message = [address, vals, time]
	if previous_value != vals:
		incoming_values = vals
		
	if parent_control_setting == 0 and on_message_received and address == osc_address:
		_custom_control(full_message[0], full_message[1], full_message[2])
		
	
	pass

func interpolated_position_control_2d(x, y):
	var x_val = x
	var y_val = y
	
	if enable_position_remap:
		x_val = remap(x_val,
		position_remap[0].x,
		position_remap[1].x,
		position_remap[2].x,
		position_remap[3].x
		)
		
		y_val = remap(y_val,
		position_remap[0].y,
		position_remap[1].y,
		position_remap[2].y,
		position_remap[3].y
		)
	
	parent.global_position = lerp(
		parent.global_position, 
		Vector2(x_val, y_val) + Vector2(position_offset.x, position_offset.y), 
		interpolation_factor
		)
	
	pass

func non_interpolated_position_control_2d(x, y):
	var x_val = x
	var y_val = y
	
	if enable_position_remap:
		x_val = remap(x_val,
		position_remap[0].x,
		position_remap[1].x,
		position_remap[2].x,
		position_remap[3].x
		)
		
		y_val = remap(y_val,
		position_remap[0].y,
		position_remap[1].y,
		position_remap[2].y,
		position_remap[3].y
		)

	parent.global_position = Vector2(
		x_val, 
		y_val) + Vector2(
			position_offset.x, 
			position_offset.y)
	


func interpolated_scale_control_2d(x, y):
	var x_val = x
	var y_val = y
	
	if enable_scale_remap:
		x_val = remap(x_val,
		scale_remap[0].x,
		scale_remap[1].x,
		scale_remap[2].x,
		scale_remap[3].x
		)
		
		y_val = remap(y_val,
		scale_remap[0].y,
		scale_remap[1].y,
		scale_remap[2].y,
		scale_remap[3].y
		)
	
	parent.scale = lerp(
		parent.scale, 
		Vector2(x_val, y_val) + Vector2(scale_offset.x, scale_offset.y), 
		interpolation_factor
		)
	
	pass

func non_interpolated_scale_control_2d(x, y):
	var x_val = x
	var y_val = y
	
	if enable_scale_remap:
		x_val = remap(x_val,
		scale_remap[0].x,
		scale_remap[1].x,
		scale_remap[2].x,
		scale_remap[3].x
		)
		
		y_val = remap(y_val,
		scale_remap[0].y,
		scale_remap[1].y,
		scale_remap[2].y,
		scale_remap[3].y
		)

	parent.scale = Vector2(
		x_val, 
		y_val) + Vector2(
			scale_offset.x, 
			scale_offset.y)



func interpolated_position_control_3d(vals):
	var x_val = vals[0]
	var y_val = vals[1]
	var z_val = vals[2]
	
	if enable_position_remap:
		x_val = remap(x_val,
		position_remap[0].x,
		position_remap[1].x,
		position_remap[2].x,
		position_remap[3].x
		)
		
		y_val = remap(y_val,
		position_remap[0].y,
		position_remap[1].y,
		position_remap[2].y,
		position_remap[3].y
		)
		
		z_val = remap(z_val,
		position_remap[0].z,
		position_remap[1].z,
		position_remap[2].z,
		position_remap[3].z
		)
		
	
	parent.global_position = lerp(
		parent.global_position, 
		Vector3(x_val, y_val, z_val) + position_offset, 
		interpolation_factor
		)
	
	pass

func non_interpolated_position_control_3d(vals):
	var x_val = vals[0]
	var y_val = vals[1]
	var z_val = vals[2]
	if enable_position_remap:
		x_val = remap(x_val,
		position_remap[0].x,
		position_remap[1].x,
		position_remap[2].x,
		position_remap[3].x
		)
		
		y_val = remap(y_val,
		position_remap[0].y,
		position_remap[1].y,
		position_remap[2].y,
		position_remap[3].y
		)
		
		z_val = remap(z_val,
		position_remap[0].z,
		position_remap[1].z,
		position_remap[2].z,
		position_remap[3].z
		)

	parent.global_position = Vector3(
		x_val, 
		y_val,
		z_val) + position_offset
	



func interpolated_scale_control_3d(vals):
	var x_val = vals[0]
	var y_val = vals[1]
	var z_val = vals[2]
	
	if enable_scale_remap:
		x_val = remap(x_val,
		scale_remap[0].x,
		scale_remap[1].x,
		scale_remap[2].x,
		scale_remap[3].x
		)
		
		y_val = remap(y_val,
		scale_remap[0].y,
		scale_remap[1].y,
		scale_remap[2].y,
		scale_remap[3].y
		)
		
		z_val = remap(z_val,
		scale_remap[0].z,
		scale_remap[1].z,
		scale_remap[2].z,
		scale_remap[3].z
		)
		
	
	parent.scale = lerp(
		parent.global_scale, 
		Vector3(x_val, y_val, z_val) + scale_offset, 
		interpolation_factor
		)
	
	pass

func non_interpolated_scale_control_3d(vals):
	var x_val = vals[0]
	var y_val = vals[1]
	var z_val = vals[2]
	if enable_scale_remap:
		x_val = remap(x_val,
		scale_remap[0].x,
		scale_remap[1].x,
		scale_remap[2].x,
		scale_remap[3].x
		)
		
		y_val = remap(y_val,
		scale_remap[0].y,
		scale_remap[1].y,
		scale_remap[2].y,
		scale_remap[3].y
		)
		
		z_val = remap(z_val,
		scale_remap[0].z,
		scale_remap[1].z,
		scale_remap[2].z,
		scale_remap[3].z
		)

	parent.scale = Vector3(
		x_val, 
		y_val,
		z_val) + scale_offset
	




func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	
	if !(target_server is OSCServer):
		warnings.append("OSCReceiver has no target_server set")
	
	return warnings
