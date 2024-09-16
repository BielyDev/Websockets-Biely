extends PanelContainer

signal icon_selected(data)
signal path_full()
signal file_full()
signal filter_array()

onready var grid: HFlowContainer = $"%grid"
onready var reload: Button = $Vbox/Buttons/Reload

var reset: bool = false
var image_path: Array = []
var path: Dictionary = {}

var icon_button_scene: PackedScene = preload("res://Scenes/IconButton.tscn")
var path_button_scene: PackedScene = preload("res://Scenes/PathButton.tscn")

func _ready() -> void:
	_reset()


func _reset() -> void:
	
	for child in grid.get_children():
		child.queue_free()
	
	new_path_collecion(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	#yield(self,"path_full")
	new_path_collecion(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS))
	#yield(self,"path_full")
	new_path_collecion(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES))
	#yield(self,"path_full")
	
	if OS.get_name() == "Android":
		new_path_collecion(OS.get_system_dir(OS.SYSTEM_DIR_DCIM))


func start() -> void:
	
	for child in grid.get_children():
		child.queue_free()
	
	image_path = filter_array(image_path,"png")
	yield(self,"filter_array")
	
	call_deferred("create_button")


func new_path_collecion(_path: String) -> void:
	var now_path = search_one_image(_path)
	
	if now_path != "":
		var new_path = path_button_scene.instance()
		
		new_path.parent = self
		
		new_path.icon = Loading.open_image(now_path,Vector2(200,200))
		new_path.path = _path
		
		grid.add_child(new_path)
		
		button_animated(new_path)
	
	emit_signal("path_full")


func search_one_image(path: String) -> String:
	var dir: Directory = Directory.new()
	
	dir.open(path)
	dir.list_dir_begin(true,true)
	
	
	for i in range(50):
		var next_file = dir.get_next()
		
		if next_file.length() >= 3:
			var now_path: String = str(path,"/",next_file)
			
			if next_file.get_extension() == "png":
				emit_signal("file_full")
				
				return now_path
	
	emit_signal("file_full")
	return ""


func search_path(path: String,array_append: Array,limiter: int = -1) -> bool:
	var emit_full: bool = true
	var dir: Directory = Directory.new()
	
	array_append.append(path)
	
	dir.open(path)
	
	dir.list_dir_begin(true,true)
	
	for i in range(300):
		
		if limiter != -1:
			if array_append.size()-1 == limiter:
				dir.list_dir_end()
				
				array_append = filter_array(array_append)
				
				yield(self,"filter_array")
				emit_signal("path_full")
				
				return true
			if array_append.size() == 0:
				return false
		
		var next_file: String = dir.get_next()
		
		if next_file.length() >= 3:
			var now_path: String = str(path,"/",next_file)
			
			if next_file.get_extension() == "png" or "jpg":
				image_path.append(now_path)
			
			if dir.dir_exists(now_path):
				emit_full = false
				
				#array_append.append(now_path)
				search_path(now_path,array_append)
	
	dir.list_dir_end()
	
	if emit_full:
		array_append = filter_array(array_append)
		
		yield(self,"filter_array")
		
		emit_signal("path_full")
	
	return true


func create_button() -> void:
	
	for _path in image_path:
		
		yield(get_tree().create_timer(0.05),"timeout")
		
		if reset:
			reset = false
			break
		
		var new_icon = icon_button_scene.instance()
		
		print(_path)
		
		new_icon.parent = self
		new_icon.path_file = _path
		new_icon.modulate.a = 0
		
		grid.add_child(new_icon)
		
		button_animated(new_icon)
	
	reload.disabled = false


func button_animated(button: Button) -> void:
		button.rect_scale = Vector2(0,0)
		
		create_tween().tween_property(button,"rect_scale",Vector2(1,1),0.3).set_trans(Tween.TRANS_CUBIC)
		create_tween().tween_property(button,"modulate:a",1,0.2).set_trans(Tween.TRANS_LINEAR)


func filter_array(array: Array,file_extension: String = "") -> Array:
	var save_array = []
	
	for i in array:
		
		if not i in save_array:
			
			if file_extension == "":
				
				if i.get_file().get_extension() == file_extension:
					
					save_array.append(i)
			else:
				
				save_array.append(i)
	
	emit_signal("filter_array")
	
	return save_array


func _on_Back_pressed() -> void:
	reset = true
	hide()
	_reset()


func _on_Reload_pressed() -> void:
	reset = true
	_reset()
	#$Warning.queue_free()

