extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var player: Sprite2D = $Player
@onready var start_game_button: Button = $CanvasLayer/StartGame
@onready var label_score: Label = $CanvasLayer/LabelScore

const cube_v_1_preload = preload("uid://casl0wkxjb27v")

var game_is_cuntinue = true
var game_is_started = false
var score = 0
var tiles_under_player = 0
# для движения враво по x + 71, по y - 37
# для движения влево по x - 76, по y - 34

var start_coordinates: Vector2 = Vector2(640, 360)

var dir_right = Vector2(76, -37).normalized()
var dir_left  = Vector2(-76, -37).normalized()

var move_dir = dir_right
var speed = 140
var max_speed = 600
var acceleration = 5

var variant

func _ready() -> void:
	start_game()


func _process(delta: float) -> void:
	if tiles_under_player <= 0:
		game_is_cuntinue = false
	if game_is_started:
		if game_is_cuntinue:
			camera_2d.position = camera_2d.position.lerp(player.position, 3 * delta)
			
			speed = min(speed + acceleration * delta, max_speed)
			player.position += move_dir * speed * delta
		else:
			player.position.y += 100 * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if move_dir == dir_right:
			move_dir = dir_left
		else:
			move_dir = dir_right


func start_game() -> void:
	score = 0
	variant = ["v1", "v2"].pick_random()
	init_spawn_cubes()


func init_spawn_cubes() -> void:
	var direction = 1
	var RIGHT = Vector2(76, -37)
	var LEFT = Vector2(-76, -37)
	var current_pos = start_coordinates
	var cube_v_1_original: Sprite2D = cube_v_1_preload.instantiate()
	cube_v_1_original.position = current_pos
	cube_v_1_original.variant = variant
	add_child(cube_v_1_original)
	for i in range(1,163):
		var cube: Cube = cube_v_1_preload.instantiate()
		cube.variant = variant
		if direction == 1:
			if current_pos.x > 1000:
				current_pos += LEFT
			else:
				current_pos += RIGHT       
		else:
			if current_pos.x < 280:
				current_pos += RIGHT
			else:
				current_pos += LEFT
		
		cube.position = current_pos
		
		if randi_range(1,3) == 1:
			direction *= -1
		
		cube.z_index = -i

		add_child(cube)


func _on_area_2d_area_entered(area: Area2D) -> void:
	tiles_under_player += 1
	score += 1
	label_score.text = str(score)


func _on_area_2d_area_exited(area: Area2D) -> void:
	tiles_under_player -= 1


func _on_start_game_pressed() -> void:
	game_is_started = true
	start_game_button.visible = false
