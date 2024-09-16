extends Control

var new_message: PackedScene = preload("res://Scenes/Message.tscn")
var new_global_message: PackedScene = preload("res://Scenes/Global_message.tscn")
var tw: Tween = Tween.new()

onready var message_text: LineEdit = $Ui/Vbox/Hbox/Message
onready var message_box: VBoxContainer = $Ui/Vbox/Chat/Scroll/message
onready var virtual_keyboard: LineEdit = $Virtual/Virtual_keyboard
onready var virtual: HBoxContainer = $Virtual
onready var scroll: ScrollContainer = $Ui/Vbox/Chat/Scroll

func _ready() -> void:
	add_child(tw)
	
	yield(get_tree(),"idle_frame")
	
	Server.entered_chat()
	Server.connect("new_message",self,"message")
	Server.connect("global_new_message",self,"global_message")

func _on_Send_pressed() -> void:
	Server.send(message_text.text)
	message_text.text = ""
	virtual_keyboard.text = ""


func message(_nickname: String, _icon, _message: String) -> void:
	var local = new_message.instance()
	local.modulate.a = 0
	message_box.add_child(local)
	
	local.rect_pivot_offset.x = local.rect_size.x/2
	local.rect_pivot_offset.y = local.rect_size.y/2
	tw.interpolate_property(local,"rect_scale",Vector2(0,0),Vector2(1,1),0.5,Tween.TRANS_BACK)
	tw.start()
	tw.interpolate_property(local,"modulate:a",0,1,0.5,Tween.TRANS_CUBIC)
	tw.start()
	
	if _icon == null:
		_icon = ""
	
	local.start(_nickname, _icon, _message)
	
	yield(get_tree(),"idle_frame")
	scroll.set_deferred("scroll_vertical", 999999)

func global_message(_message: String) -> void:
	var global = new_global_message.instance()
	
	global.modulate.a = 0
	message_box.add_child(global)
	
	global.rect_pivot_offset.x = global.rect_size.x/2
	global.rect_pivot_offset.y = global.rect_size.y/2
	tw.interpolate_property(global,"rect_scale",Vector2(0,0),Vector2(1,1),0.5,Tween.TRANS_BACK)
	tw.start()
	tw.interpolate_property(global,"modulate:a",0,1,0.5,Tween.TRANS_BACK)
	tw.start()
	
	global.start(_message)
	
	yield(get_tree(),"idle_frame")
	scroll.set_deferred("scroll_vertical", 999999)

var virtual_focus: bool = false

func _on_Message_focus_entered() -> void:
	if OS.get_name() == "Android":
		virtual.show()

func _on_Message_focus_exited() -> void:
	yield(get_tree().create_timer(0.1),"timeout")
	
	if virtual_focus == false:
		virtual.hide()


func _on_Message_text_changed(new_text: String) -> void:
	virtual_keyboard.text = new_text


func _on_Virtual_keyboard_text_changed(new_text: String) -> void:
	message_text.text = new_text


func _on_Virtual_keyboard_focus_entered() -> void:
	virtual_focus = true
func _on_Virtual_keyboard_focus_exited() -> void:
	virtual_focus = false
