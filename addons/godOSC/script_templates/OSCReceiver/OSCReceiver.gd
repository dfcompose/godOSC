#meta-name: OSCReceiver Default
# meta-description: Base template for an OSCReceiver script
# meta-default: true

extends _BASE_


## Code to be ran when Parent Control is set to custom.
func _custom_control(address : String, vals : Array, time):
	
	if vals != []:
		#put your code here. This if statement prevents your code from being ran if you receive an empty message

	pass
