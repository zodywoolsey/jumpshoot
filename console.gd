extends Control

@onready var input : LineEdit = $VSplitContainer/input
@onready var previous : ItemList = $VSplitContainer/previous

@onready var set_move_speed : RegEx = RegEx.new()

var previousIndex = -1
var isInputFocused = false

func _ready():
	input.connect("text_submitted", commandSubmitted)
	input.connect("focus_entered", inputFocused)
	input.connect("focus_exited", inputUnFocused)
	
	set_move_speed.compile("^(move_speed) = (\\d*.\\d*)$")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isInputFocused:
		if Input.is_action_just_pressed("ui_down") and previousIndex < previous.item_count:
			previousIndex += 1
			if previousIndex == previous.item_count:
				input.clear()
			else:
				input.text = previous.get_item_text(previousIndex)
		elif Input.is_action_just_pressed("ui_up"):
			if previousIndex > 0:
				previousIndex -= 1
				input.text = previous.get_item_text(previousIndex)
	if Input.is_action_just_pressed("consoleToggle"):
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		visible = !visible
		

func commandSubmitted(command:String):
	var player = get_tree().get_nodes_in_group("player")[0]
	if !command.trim_prefix(" ").trim_suffix(" ").is_empty():
		var com = command.split(' ')
		if com[0].to_lower() == "jump":
			player.jump()
		elif set_move_speed.search(command) is RegExMatch:
			player.SPEED = com[2].to_float()
		
		
		previous.add_item(command)
		previousIndex = previous.item_count
	input.clear()


func inputFocused():
	isInputFocused = true
func inputUnFocused():
	isInputFocused = false
