extends Node2D

@onready var cubes: Node2D = $Cubes
@onready var camera_2d: Camera2D = $Camera2D
@onready var player: Sprite2D = $Player
@onready var start_game_button: Button = $CanvasLayer/StartGame
@onready var label_score: Label = $CanvasLayer/LabelScore
@onready var label_last_score: Label = $CanvasLayer/GameOverPanel/MarginContainer/VBoxContainer/LabelLastScore
@onready var label_record_score: Label = $CanvasLayer/GameOverPanel/MarginContainer/VBoxContainer/LabelRecordScore
@onready var game_over_panel: Panel = $CanvasLayer/GameOverPanel


const cube_v_1_preload = preload("uid://casl0wkxjb27v")

var game_is_cuntinue = true
var game_is_started = false
var score = 0
var record_score = 0
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
	game_over_panel.visible = false
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
	get_data()
	score = 0
	speed = 140
	tiles_under_player = 0
	grace_timer = grace_time
	variant = ["v1", "v2"].pick_random()
	game_over_panel.visible = false
	if !is_first_game:
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
	for i in range(1,2163):
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
	save_data()
	game_is_started = false
	label_last_score.text = tr("KEY_SCORE") + ": " + str(score)

	label_record_score.text = tr("KEY_RECORD") + ": " + str(record_score)
	game_over_panel.visible = true


func _on_area_2d_area_entered(_area: Area2D) -> void:
	if game_is_started:
		tiles_under_player += 1
		score += 1
		if record_score < score:
			record_score = score
		label_score.text = str(score)


func _on_area_2d_area_exited(_area: Area2D) -> void:
	if game_is_started:
		tiles_under_player = max(tiles_under_player - 1, 0)


func _on_start_game_pressed() -> void:
	start_game_button.visible = false
	start_game()


func _on_restart_game_pressed() -> void:
	start_game()


func save_data() -> void:
	if Bridge.storage.is_supported("platform_internal"):
		if Bridge.storage.is_available("platform_internal"):
			Bridge.storage.set(["record_score"], [record_score], Callable(self, "_on_storage_set_completed"))


func get_data() -> void:
	if Bridge.storage.is_supported("platform_internal"):
		if Bridge.storage.is_available("platform_internal"):
			Bridge.storage.get(["record_score"], Callable(self, "_on_storage_get_completed"))


func _on_storage_get_completed(success, data) -> void:
	if success:
		if data[0] != null: record_score = data[0]
		else:
			record_score = 0
	else:
		record_score = 0


func _on_storage_set_completed(success) -> void:
	if success:
		print("Данные успешно сохранены")
	else:
		print("Ошибка сохранения")
