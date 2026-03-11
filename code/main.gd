extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var player: Sprite2D = $Player
@onready var timer: Timer = $Timer

const cube_v_1_preload = preload("uid://casl0wkxjb27v")

var game_is_cuntinue = true
# для движения враво по x + 71, по y - 37
# для движения влево по x - 76, по y - 34

var start_coordinates: Vector2 = Vector2(640, 360)

var dir_right = Vector2(76, -37).normalized()
var dir_left  = Vector2(-76, -37).normalized()

var move_dir = dir_right
var speed = 140

var variant = "v2"

func _ready() -> void:
	init_spawn_cubes()


func _process(delta: float) -> void:
	if game_is_cuntinue:
		camera_2d.position.y -= 70 * delta
		player.position += move_dir * speed * delta
	else:
		player.position.y += 100 * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if move_dir == dir_right:
			move_dir = dir_left
		else:
			move_dir = dir_right


func init_spawn_cubes() -> void:
	var direction = 1
	var RIGHT = Vector2(76, -37)
	var LEFT = Vector2(-76, -37)
	var current_pos = start_coordinates
	var cube_v_1_original: Sprite2D = cube_v_1_preload.instantiate()
	cube_v_1_original.position = current_pos
	cube_v_1_original.variant = variant
	add_child(cube_v_1_original)
	for i in range(1,63):
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
	timer.stop()


func _on_area_2d_area_exited(area: Area2D) -> void:
	timer.start()


func _on_timer_timeout() -> void:
	game_is_cuntinue = false
