class_name Cube
extends Sprite2D

const CHAT_GPT_V_1 = preload("uid://dy1psoq55f228")
const CHAT_GPT_V_2 = preload("uid://bou4b8t1cichr")


var variant = "v1"


func _ready() -> void:
	if variant == "v1":
		texture = CHAT_GPT_V_1
	if variant == "v2":
		texture = CHAT_GPT_V_2
