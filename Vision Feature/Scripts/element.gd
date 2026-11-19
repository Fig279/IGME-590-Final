class_name Element

enum State{
	Neutral,
	Fire,
	Water,
	Ice,
	Lighting,
	Wind,
	Plant,
	Stone
}

@export var currentState: State

func _init() -> void:
	# Element is neutral by default
	currentState = State.Neutral
	
func get_color() -> Color:
	var alpha = 0.8
	# Make it return the color for neutral by default
	var returnColor = Color(Color.GRAY, alpha)
	
	# Fire is red
	if currentState == State.Fire:
		returnColor = Color(Color.RED, alpha)
	
	# Water is dodger blue
	if currentState == State.Water:
		returnColor = Color(Color.DODGER_BLUE, alpha)
	
	# Ice is light sky blue
	if currentState == State.Ice:
		returnColor = Color(Color.LIGHT_SKY_BLUE, alpha)
	
	# Lighting is purple
	if currentState == State.Lighting:
		returnColor = Color(Color.REBECCA_PURPLE, alpha)
	
	# Wind is sea green
	if currentState == State.Wind:
		returnColor = Color(Color.LIGHT_SEA_GREEN, alpha)
		
	# Plant is green
	if currentState == State.Plant:
		returnColor = Color(Color.FOREST_GREEN, alpha)
	
	# Stone is golden rod
	if currentState == State.Stone:
		returnColor = Color(Color.GOLDENROD, alpha)
	
	return returnColor
