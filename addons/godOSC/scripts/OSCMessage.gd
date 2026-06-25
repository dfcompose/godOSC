@icon("res://addons/godOSC/images/OSCMessage.svg")
@tool
class_name OSCMessage
extends Node
## Convenience class for organizing an OSC message. Used with an OSCClient. To add your own code, extend the script attached to the OSCReceiver you create by right clicking and "extend script"

## The client to send the OSC message with
@export var target_client : OSCClient:
	set(new_client):
		if new_client != target_client:
			target_client = new_client
		update_configuration_warnings()

## The OSC address to send to
@export var osc_address := "/example"

## Allow the OSCMessage to send messages using the OSCClient.
@export var enabled := true

@export_group("Message Handling")
## Use if not connected to an HSlider, VSlider, or ProgressBar. Otherwise the message contents will be the value of the slider/progress bar.
@export_enum("Position", "Scale", "Position and Scale", "Custom") var message_contents = 0
## When a new message should be sent
@export_enum("Value Changed", "Continuous", "Timer", "Custom") var send_message_on = 0
## The rate at which messages are sent in "Timer" mode
@export var message_timer_rate = 1.0


## Signal emitted when a message is sent
signal message_sent(time)

## The parent node this OSCMessage node is attached to
@onready var parent = get_parent()


var current_value = 0
var previous_value = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	if send_message_on == 2:
		var timer = Timer.new()
		timer.timeout.connect(using_timer)
		timer.wait_time = message_timer_rate
		timer.start()
	#
	#if !(target_client is OSCClient):
		#print_rich("[color=yellow][b]OSCMessage has no target client. Consider designating one.[/b][/color]")
		#push_warning("OSCMessage has no target client. Consider designating one.")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	get_parent_value()
	
	match send_message_on:
		0:
			if current_value != previous_value:
				send_message(current_value)
				
		1:
			send_message(current_value)
			
		3:
			_custom_message_handling()
	
	previous_value = current_value
	
	pass


func send_message(value):
	
	if value is Array and enabled:
		target_client.send_message(osc_address, value)
	elif enabled:
		target_client.send_message(osc_address, [value])
		
	
	message_sent.emit(Time.get_unix_time_from_system())


func get_parent_value():
	
	
	if message_contents == 3:
		
		send_message(_custom_message_contents())
		
		return
	
	if parent is HSlider or parent is VSlider or parent is ProgressBar:
		current_value = parent.value
		
		return
	elif parent is Node2D or parent is TextureRect or parent is ColorRect or parent is Panel:
		if message_contents == 0:
			current_value = [parent.global_position.x, parent.global_position.y]
		elif message_contents == 1:
			current_value = [parent.scale.x, parent.scale.y]
		elif message_contents == 2:
			current_value = [parent.global_position.x, parent.global_position.y, parent.scale.x, parent.scale.y]
		return
	elif parent is Node3D:
		if message_contents == 0:
			current_value = [parent.global_position.x, parent.global_position.y, parent.global_position.z]
		elif message_contents == 1:
			current_value = [parent.scale.x, parent.scale.y, parent.scale.z]
		elif message_contents == 2: 
			[parent.global_position.x, parent.global_position.y, parent.global_position.z, parent.scale.x, parent.scale.y, parent.scale.z]
		
		return
	
	


## Overwrite this method with your custom message handling
func _custom_message_handling():
	
	pass

## Overwrite this method with your custom message contents. This method must return a value
func _custom_message_contents() -> Variant:
	var value = 0
	
	return value
	pass

func using_timer():
	send_message(current_value)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	
	if !(target_client is OSCClient):
		warnings.append("OSCMessage's target_client is not set.")
	
	return warnings
