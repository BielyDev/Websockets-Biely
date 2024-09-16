extends Control

onready var Nickname: LineEdit = $Nickname/Nickname
onready var Warning: Label = $Nickname/Warning
onready var Join: Button = $Join
onready var Icon: TextureButton = $Nickname/IconPanel/Icon
onready var Gallery: PanelContainer = $Gallery

var others_c = ["@","!","#","$","*",'"',"'",":","/","\\","?"]

var err = {
	scape = "Sem espaços vazios no nome!",
	others_c = "Sem caracteres especiais no nome!",
	minimum = "Seu apelido deve conter no minimo 4 letras.",
	done = "Entrando na rede...",
	join = "Conectado",
	failed_connection = "Conexão falhou...",
}

func _ready() -> void:
	
	Server.connect("connection_server",self,"connection")
	Server.connect("connection_failed",self,"failed_connection")

func _on_Join_pressed() -> void:
	if filter_nickname():
		done()

func _on_Nickname_text_changed(_new_text: String) -> void:
	Warning.text = ""



func filter_nickname() -> bool:
	Warning.modulate = Color.indianred
	
	if Nickname.text.length() < 3:
		Warning.text = err.minimum
		return false
	
	for caracteres in Nickname.text:
		if caracteres == " ":
			Warning.text = err.scape
			return false
		
		for i in others_c:
			if caracteres == i:
				Warning.text = err.others_c
				return false
	
	return true

func done() -> void:
	Warning.modulate = Color(0.55, 0.6, 0.7)
	Warning.text = err.done
	Nickname.editable = false
	Join.disabled = true
	Icon.disabled = true
	
	Server.player.nickname = Nickname.text
	Server.call_connection()

func connection() -> void:
	Warning.modulate = Color(0.55, 0.7, 0.6)
	Warning.text = err.join
	
	yield(get_tree().create_timer(1),"timeout")
	Loading.changed_scene = "res://Scenes/Chat.tscn"


func failed_connection() -> void:
	Warning.modulate = Color.indianred
	Warning.text = err.failed_connection
	
	Nickname.editable = true
	Join.disabled = false
	Icon.disabled = false


func _on_Icons_path_icon_selected(data) -> void:
	var image = Image.new()
	var imageTex = ImageTexture.new()
	
	image.load_png_from_buffer(data)
	imageTex.create_from_image(image)
	
	Icon.texture_normal = imageTex
	
	Server.player.icon = Marshalls.raw_to_base64(data)
	Gallery.hide()


func _on_Icon_pressed() -> void:
	Gallery.show()
