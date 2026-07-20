#meta-name: OSCMessage Default
# meta-description: Base template for a OSCMessage script
# meta-default: true

extends _BASE_


## Code to be ran when Send Message On is set to custom
func _custom_message_handling():
	
	pass

## Code to be ran when Message Contents is set to custom. This must return a value
func _custom_message_contents() -> Variant:
	var value = 0
	
	return value
	pass
