class_name DialogueBox
extends PanelContainer

signal continued

@export var typing_effect: TypingEffect

enum DialogueBoxState {
	None,
	Typing,		
	Done
}

var state: DialogueBoxState = DialogueBoxState.None

func _ready() -> void:
	UILayer.continue_input.connect(
		func():
			Tracer.debug("Received dialogue enter, %s" % str(DialogueBoxState.keys()[state]))
			match state:
				DialogueBoxState.None:
					pass
				DialogueBoxState.Typing:
					typing_effect.skip()
				DialogueBoxState.Done:
					continued.emit()
					queue_free()
	)

func type(text: String) -> void:
	if has_node("Trackable"):
		$Trackable.mark_interacted()
	state = DialogueBoxState.Typing
	await typing_effect.type(text)
	state = DialogueBoxState.Done
