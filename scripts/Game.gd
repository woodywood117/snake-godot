extends Control

var window_size
const snake_scene = preload('res://Snake.tscn')
const apple_scene = preload('res://Apple.tscn')
var head
var apple
var heads_last_position : Vector2
var heads_last_direction : Vector2

func _ready():
	randomize()
	$GameOverLabel.hide()
	
	window_size = get_viewport().size

	head = snake_scene.instance()
	head.global_position = Vector2(512, 256)
	head.direction = Vector2(-1, 0)
	add_child(head)
	
	apple = apple_scene.instance()
	apple.position = Vector2(0,0)
	add_child(apple)
	move_apple()


func move_apple():
	var random_x = randi() % (int(window_size.x) / 32 - 1)
	var random_y = randi() % (int(window_size.y) / 32 - 1)
	var random_position = Vector2(random_x * 32, random_y * 32)
	while head.collides_with_self(random_position):
		random_x = randi() % (int(window_size.x) / 32 - 1)
		random_y = randi() % (int(window_size.y) / 32 - 1)
		random_position = Vector2(random_x * 32, random_y * 32)
	
	apple.position = random_position


func add_snake_piece(pos: Vector2, dir: Vector2):
	var tmp = snake_scene.instance()
	tmp.position = Vector2(pos.x, pos.y)
	tmp.direction = Vector2(dir.x, dir.y)
	if head.next == null:
		head.next = tmp
	else:
		tmp.next = head.next
		head.next = tmp
	
	add_child(tmp)


func _process(delta):
	if Input.is_action_pressed("move_left") && head.direction != Vector2(1, 0):
		head.direction = Vector2(-1, 0)
	if Input.is_action_pressed("move_right") && head.direction != Vector2(-1, 0):
		head.direction = Vector2(1, 0)
	if Input.is_action_pressed("move_up") && head.direction != Vector2(0, 1):
		head.direction = Vector2(0, -1)
	if Input.is_action_pressed("move_down") && head.direction != Vector2(0, -1):
		head.direction = Vector2(0, 1)


func _on_MovementTimer_timeout():
	heads_last_position = head.position
	heads_last_direction = head.direction
	head.move()
	
	if head.position == apple.position:
		add_snake_piece(heads_last_position, heads_last_direction)
		move_apple()
	elif head.next != null && head.next.collides_with_self(head.position):
		# game over
		set_process(false)
		$MovementTimer.stop()
		apple.queue_free()
		head.free_body()
		$GameOverLabel.show()
		$GameOverTimer.start()
		yield($GameOverTimer, "timeout")
		var main_menu_scene = load("res://MainMenu.tscn")
		get_tree().change_scene_to(main_menu_scene)
	else:
		var last_node = head
		var current_node = head.next
		var last_new_direction = last_node.direction
		while current_node != null:
			current_node.move()
			
			# set the direction of the last node after you've moved the current node
			var previous_last_direction = last_node.direction
			last_node.direction = last_new_direction
			last_new_direction = previous_last_direction
			
			# move to the next node in the chain
			last_node = current_node
			current_node = current_node.next
		
		# make sure to set the direction of the last node, missed because of
		# loop logic
		last_node.direction = last_new_direction
