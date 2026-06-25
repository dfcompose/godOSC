@icon("res://addons/godOSC/images/OSCClient.svg")
class_name OSCClient
extends Node
## Client for sending Open Sound Control messages over UDP. Use one OSCClient per server you want to send to.

## The IP Address of the server to send to.
@export var ip_address = "127.0.0.1"
## The port to send to.
@export var port = 4646


var client = PacketPeerUDP.new()


func _ready():
	connect_socket(ip_address, port)
	
	if not client.is_socket_connected():
		push_warning("OSCClient did not successfully connect to host.")
	

## Connect to an OSC server. Can only send to one OSC server at a time.
func connect_socket(new_ip = "127.0.0.1", new_port = 4646):
	close_socket()
	client.connect_to_host(new_ip, new_port)

func close_socket():
	if client.is_socket_connected():
		client.close()

## Send an OSC message over UDP.
func prepare_message(osc_address : String, args : Array):
	var packet = PackedByteArray()
	
	packet.append_array(osc_address.to_ascii_buffer())
	
	packet.append(0)
	while fmod(packet.size(), 4):
		packet.append(0)
	
	packet.append(44)
	for arg in args:
		match typeof(arg):
			TYPE_BOOL:
				if arg:
					packet.append(84)
				else:
					packet.append(70)
			TYPE_INT:
				packet.append(105)
			TYPE_FLOAT:
				packet.append(102)
			TYPE_STRING:
				packet.append(115)
			TYPE_PACKED_BYTE_ARRAY:
				packet.append(98)
	
	packet.append(0)
	while fmod(packet.size(), 4):
		packet.append(0)
	
	for arg in args:
		var pack = PackedByteArray()
		match typeof(arg):
			TYPE_BOOL:
				if arg:
					pack.append_array([1])
					pack.reverse()
				else:
					pack.append_array([0])
					pack.reverse()
			TYPE_INT:
				pack.append_array([0, 0, 0, 0])
				pack.encode_s32(0, arg)
				pack.reverse()
			TYPE_FLOAT:
				pack.append_array([0, 0, 0, 0])
				pack.encode_float(0, arg)
				pack.reverse()
			TYPE_STRING:
				pack.append_array(arg.to_ascii_buffer())
				pack.append(0)
				while fmod(pack.size(), 4):
					pack.append(0)
			TYPE_PACKED_BYTE_ARRAY:
				pack.append_array(arg)
				while fmod(pack.size(), 4):
					pack.append(0)
		packet.append_array(pack)
	
	return packet

func send_message(osc_address : String, args : Array):
	if client.is_socket_connected():
		var packet = prepare_message(osc_address, args)
		client.put_packet(packet)
		
