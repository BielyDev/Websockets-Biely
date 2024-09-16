extends Control

signal connection_server()
signal connection_failed()
signal new_message(nickname,message)
signal global_new_message(message)

enum MODE {MESSAGE,REGISTER,GLOBAL,IS_CONNECTED}

var client: WebSocketClient = WebSocketClient.new()
var url: String = "http://br2.localto.net:8085"
var players: Array = []

var player = {
	"mode" : MODE.REGISTER,
	"id" : 0,
	"icon" : null,
	"nickname" : "new",
}



func _ready() -> void:
	OS.request_permissions()
	
	client.connect("data_received",self,"data_received")
	client.connect("peer_packet",self,"peer_packet")
	client.connect("peer_connected",self,"connection_succeeded")
	client.connect("connection_established",self,"connection_established")
	client.connect("connection_succeeded",self,"connection_succeeded")
	client.connect("connection_failed",self,"connection_failed")
	client.connect("connection_error",self,"connection_failed")
	client.connect("connection_closed",self,"connection_failed")
	
	set_process(false)
	
	randomize()
	
	player.id = randi()



func call_connection() -> void:
	var err = client.connect_to_url(url)
	
	if err == OK:
		print("conectando")
		set_process(true)
	else:
		print("erro ao conectar-se")
		set_process(false)

func connection_established(value) -> void:
	#emit_signal("connection")
	
	print(value)

func connection_succeeded() -> void:
	emit_signal("connection_server")
	
	print("connection")

func connection_failed() -> void:
	emit_signal("connection_failed")
	
	print("failed connection")

func peer_packet() -> void:
	print("peer_packet")

func data_received() -> void:
	var data = client.get_peer(1).get_packet()
	var data_utf = data.get_string_from_utf8()
	
	if data_utf == "OK":
		register()
		
		emit_signal("connection_server")
		
		return
	
	
	var json_data_utf = JSON.parse(data_utf).result
	
	if json_data_utf is Array:
		
		players = json_data_utf
		
		return
	
	
	if json_data_utf is Dictionary:
		
		if json_data_utf.mode == MODE.MESSAGE:
			var client
			
			for search_player in players:
				
				if search_player.id == json_data_utf.id:
					client = search_player
			
			
			emit_signal("new_message",client.nickname,client.icon,json_data_utf.msg)
		
		if json_data_utf.mode == MODE.REGISTER:
			players.append(json_data_utf)
		
		if json_data_utf.mode == MODE.GLOBAL:
			emit_signal("global_new_message",json_data_utf.msg)

func _process(_delta: float) -> void:
	client.poll()

func send(message: String) -> void:
	client.get_peer(1).put_packet(JSON.print({mode = MODE.MESSAGE,id = player.id,msg = message}).to_utf8())

func entered_chat() -> void:
	var message = str(player.nickname,", entrou no Chat!")
	
	client.get_peer(1).put_packet(JSON.print({mode = MODE.GLOBAL,msg = message}).to_utf8())

func register() -> void:
	print("------------")
	
	client.get_peer(1).put_packet(JSON.print(player).to_utf8())



