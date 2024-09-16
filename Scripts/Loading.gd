extends Control

onready var anima: AnimationPlayer = $Anima
onready var fps: Label = $Gui/Debug/vbox/Fps

var changed_scene: String setget setget_scene

func pass_scene() -> void:
	get_tree().change_scene(changed_scene)
	
	changed_scene = ""
	
	yield(get_tree(),"tree_changed")
	anima.play("Finished")

func setget_scene(value: String) -> void:
	anima.play("Pass")
	
	changed_scene = value

func _process(delta: float) -> void:
	fps.text = str("FPS: ",Engine.get_frames_per_second())



func open_image(_path: String,resolution: Vector2) -> Texture:
	var image = Image.new()
	var texture = ImageTexture.new()
	var cut
	var err = image.load(_path)
	
	if err != 15 and err != 12:
		
		if image.get_width() > image.get_height():
			cut = Rect2(
				Vector2((image.get_width()/2)-(image.get_height()/2),0),
				Vector2(image.get_height(),image.get_height())
			)
		else:
			cut = Rect2(
				Vector2(0,(image.get_height()/2)-(image.get_width()/2)),
				Vector2(image.get_width(),image.get_width())
			)
		
		
		var new_image = image.get_rect(cut)
		
		if new_image.get_width() > resolution.x:
			new_image.resize(resolution.x,resolution.y,Image.INTERPOLATE_CUBIC)
		
		texture.create_from_image(new_image)
		
		return texture
	
	return null
