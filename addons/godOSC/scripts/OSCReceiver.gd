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

@export_group("Parent Control")

## How the OSCReceiver controls the parent node
@export_enum("Custom", "Position", "Scale") var parent_control_setting = 0

## For custom control, if true only runs the custom control code when a new message is received, otherwise runs the code continuosly. Note, this *must* be set to false to use interpolation in a custom message control. ie.:  using lerp() 
@export var on_message_received = true
## Applys a single incoming value to all axis.
@export var apply_to_all_axis := false

## The amount of position offset applied to the incoming data
@export var position_offset := Vector3.ZERO

## The amount of scale offset applied to the incoming data
@export var scale_offset := Vector3.ZERO

## Applies linear interpolation between previous position/scale and incoming position/scale.
@export var interpolation := false

## The linear interpolation factor
@export var interpolation_factor := 0.5

var full_message = []
var incoming_values = []

var previous_value = []
func _ready() -> void:
	
	target_server.message_received.connect(received_message)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
# OSC messages are stored as a dictionary held in OSCServer variable incoming_messages, which uses a string for the
# key and an array to store the data. To access the data use the following format: 
# target_server.incoming_messages[osc_address][0]
func _process(delta):
	
	
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
					parent.global_position = lerp(parent.global_position, Vector2(incoming_values[0], incoming_values[1]) + Vector2(position_offset.x, position_offset.y), interpolation_factor)
				if parent is Node3D:
					parent.global_position = lerp(parent.global_position, Vector3(incoming_values[0], incoming_values[1], incoming_values[2]) + position_offset, interpolation_factor)
			2:
				
				if parent is Node2D or parent is Control:
					parent.scale = lerp(parent.scale, Vector2(incoming_values[0], incoming_values[1]) + Vector2(scale_offset.x, scale_offset.y), interpolation_factor)
				if parent is Node3D:
					parent.scale = lerp(parent.scale, Vector3(incoming_values[0], incoming_values[1], incoming_values[2]) + scale_offset, interpolation_factor)
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
					parent.global_position = Vector2(incoming_values[0], incoming_values[0]) + Vector2(position_offset.x, position_offset.y)
				if parent is Node3D:
					parent.global_position = Vector3(incoming_values[0], incoming_values[1], incoming_values[2]) + position_offset
			2:
				if parent is Node2D or parent is Control:
					parent.scale = Vector2(incoming_values[0], incoming_values[1]) + Vector2(scale_offset.x, scale_offset.y)
				if parent is Node3D:
					parent.scale = Vector3(incoming_values[0], incoming_values[1], incoming_values[2]) + scale_offset
	
	
	if interpolation:
		match parent_control_setting:
			0:
				if !on_message_received:
					_custom_control(full_message[0], full_message[1], full_message[2])
					pass
				else:
					pass
			1:
				
				if parent is Node2D or parent is Control:
					parent.global_position = lerp(parent.global_position, Vector2(incoming_values[0], incoming_values[0]) + Vector2(position_offset.x, position_offset.y), interpolation_factor)
				if parent is Node3D:
					parent.global_position = lerp(parent.global_position, Vector3(incoming_values[0], incoming_values[0], incoming_values[0]) + position_offset, interpolation_factor)
			2:
				
				if parent is Node2D or parent is Control:
					parent.scale = lerp(parent.scale, Vector2(incoming_values[0], incoming_values[0]) + Vector2(scale_offset.x, scale_offset.y), interpolation_factor)
				if parent is Node3D:
					parent.scale = lerp(parent.scale, Vector3(incoming_values[0], incoming_values[0], incoming_values[0]) + scale_offset, interpolation_factor)
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
					parent.global_position = Vector2(incoming_values[0], incoming_values[0]) + Vector2(position_offset.x, position_offset.y)
				if parent is Node3D:
					parent.global_position = Vector3(incoming_values[0], incoming_values[0], incoming_values[2]) + position_offset
			2:
				if parent is Node2D or parent is Control:
					parent.scale = Vector2(incoming_values[0], incoming_values[0]) + Vector2(scale_offset.x, scale_offset.y)
				if parent is Node3D:
					parent.scale = Vector3(incoming_values[0], incoming_values[0], incoming_values[0]) + scale_offset
	
	
	
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


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	
	if !(target_server is OSCServer):
		warnings.append("OSCReceiver has no target_server set")
	
	return warnings
