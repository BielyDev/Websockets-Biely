extends PanelContainer

onready var nickname: Label = $Margin/Info/Vbox/Nickname
onready var message: Label = $Margin/Info/Vbox/Message
onready var icon: TextureRect = $Margin/Info/Icon


func start(_nickname: String, _icon: String,_message: String) -> void:
	nickname.text = _nickname
	message.text = _message
	#print(_icon)
	
	if _icon != "":
		var image = Image.new()
		var imagetex = ImageTexture.new()
		
		image.load_png_from_buffer(Marshalls.base64_to_raw(_icon))
		#Marshalls.base64_to_raw()
		imagetex.create_from_image(image)
		icon.texture = imagetex
