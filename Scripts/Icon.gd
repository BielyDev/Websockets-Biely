extends Button

var parent: Node
var path_file: String


func _pressed() -> void:
	var image = icon.get_data().save_png_to_buffer()
	
	parent.emit_signal("icon_selected",image)

func loading_image() -> void:
	var imagetex = Loading.open_image(path_file,Vector2(100,100))
	
	if imagetex == null:
		icon = imagetex
