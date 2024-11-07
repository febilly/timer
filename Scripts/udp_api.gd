extends Node
class_name UdpApi

signal number_received(number: int)

var server := UDPServer.new()
var peers = []

func _ready():
	server.listen(58735, "127.0.0.1")  # 只能本机访问

func _process(delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		peers.append(peer)

	for peer in peers:
		process_peer(peer)

func process_peer(peer: PacketPeerUDP):
	if peer.get_available_packet_count() > 0:
		var packet := peer.get_packet()
		if packet.size() != 1:
			return
		
		var number = packet.decode_u8(0)
		# print("Received number: %s" % number)
		number_received.emit(number)