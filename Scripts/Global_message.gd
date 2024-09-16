extends PanelContainer

onready var message: Label = $Margin/Message


func start(_message: String) -> void:
	message.text = _message
