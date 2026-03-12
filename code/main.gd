extends Node2D

@onready var cubes: Node2D = $Cubes
@onready var camera_2d: Camera2D = $Camera2D
@onready var player: Sprite2D = $Player
@onready var start_game_button: Button = $CanvasLayer/StartGame
@onready var restart_game: Button = $CanvasLayer/RestartGame
@onready var label_score: Label = $CanvasLayer/LabelScore

const cube_v_1_preload = preload("uid://casl0wkxjb27v")

var game_is_cuntinue = true
var game_is_started = false
var score = 0
var tiles_under_player = 0

var start_coordinates: Vector2 = Vector2(640, 360)

var dir_right = Vector2(76, -37).normalized()
var dir_left  = Vector2(-76, -37).normalized()

var move_dir = dir_right
var speed = 140
var max_speed = 600
var acceleration = 5

var grace_time = 0.2
var grace_timer = 0

var variant
var is_first_game


func _ready() -> void:
	is_first_game = true
	restart_game.visible = false
	init_spawn_cubes()


func _process(delta: float) -> void:
	if !game_is_started:
		return
	grace_timer -= delta
	if grace_timer <= 0 and tiles_under_player <= 0:
		end_game()
	if game_is_cuntinue:
		camera_2d.position = camera_2d.position.lerp(player.position, 3 * delta)

		speed = min(speed + acceleration * delta, max_speed)
		player.position += move_dir * speed * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if move_dir == dir_right:
			move_dir = dir_left
		else:
			move_dir = dir_right


func start_game() -> void:
	score = 0
	speed = 140
	tiles_under_player = 1
	grace_timer = grace_time
	variant = ["v1", "v2"].pick_random()
	restart_game.visible = false
	if !is_first_game:
		tiles_under_player = 0
		clear_cubes()
		init_spawn_cubes()
	is_first_game = false
	game_is_started = true
	player.position = Vector2(640, 260)
	camera_2d.position = player.position
	move_dir = dir_right


func init_spawn_cubes() -> void:
	var direction = 1
	var RIGHT = Vector2(76, -37)
	var LEFT = Vector2(-76, -37)
	var current_pos = start_coordinates
	var cube_v_1_original: Sprite2D = cube_v_1_preload.instantiate()
	cube_v_1_original.position = current_pos
	cube_v_1_original.variant = variant
	cubes.add_child(cube_v_1_original)
	for i in range(1,1163):
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

		cubes.add_child(cube)


func clear_cubes() -> void:
	var children = cubes.get_children()
	for child in children:
		child.queue_free()


func end_game() -> void:
	
	game_is_started = false
	restart_game.visible = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	if game_is_started:
		tiles_under_player += 1
		score += 1
		label_score.text = str(score)


func _on_area_2d_area_exited(area: Area2D) -> void:
	if game_is_started:
		tiles_under_player = max(tiles_under_player - 1, 0)


func _on_start_game_pressed() -> void:
	start_game_button.visible = false
	start_game()


func _on_restart_game_pressed() -> void:
	start_game()
