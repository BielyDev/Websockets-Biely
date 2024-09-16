extends Button

onready var Tittle: Label = $Panel/Text

var parent: Node
var path: String

func _ready() -> void:
	Tittle.text = str(path.get_file())

func _pressed() -> void:
	parent.path[path.get_file()] = []
	
	parent.call_deferred("search_path",path,parent.path[path.get_file()],5)
	yield(parent,"path_full")
	
	parent.start()

