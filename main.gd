extends Node2D

enum State { IDLE, ANGRY, JUMPSCARE }
var current_state = State.IDLE
var is_game_over = false

# --- THAY ĐỔI THÔNG SỐ TẠI ĐÂY ---
var current_annoyance: float = 0.0    
var max_annoyance: float = 6.0      # Giảm ngưỡng từ 10 xuống 6 (dễ cắn hơn)
var cool_down_speed: float = 1.5     # Mèo nguôi giận chậm hơn (giữ mặt quạu lâu hơn)

@onready var cat_button = $CatButton
@onready var particles = get_node_or_null("CatButton/HairParticles")

var tex_idle = preload("res://assets/cat_idle.png")
var tex_angry = preload("res://assets/cat_angry.png")
var tex_jumpscare = preload("res://assets/cat_jumpscare.png")

func _ready():
	var comb_img = preload("res://assets/comb.png")
	Input.set_custom_mouse_cursor(comb_img)
	
	var screen_size = get_viewport_rect().size
	get_viewport().warp_mouse(screen_size / 2)
	
	reset_game()

func reset_game():
	is_game_over = false
	current_state = State.IDLE
	current_annoyance = 0.0 
	cat_button.texture_normal = tex_idle

func _process(delta):
	if is_game_over: return
	
	if current_annoyance > 0.0:
		current_annoyance -= cool_down_speed * delta
		if current_annoyance < 0.0: current_annoyance = 0.0
	
	# --- CHỈNH LẠI NGƯỠNG HIỂN THỊ ẢNH ---
	if current_annoyance >= 3.0: # Chỉ cần 3 điểm là hiện mặt quạu (rất nhanh)
		if current_state != State.ANGRY:
			current_state = State.ANGRY
			cat_button.texture_normal = tex_angry
	elif current_annoyance < 1.5: # Phải đợi xuống tận 1.5 điểm mới hết quạu
		if current_state != State.IDLE:
			current_state = State.IDLE
			cat_button.texture_normal = tex_idle

func _on_cat_button_pressed():
	if is_game_over: return
	
	# Mỗi lần chải tăng hẳn 2.5 điểm (Chải 2 cái là hiện quạu, 3 cái là dính cắn)
	current_annoyance += 2.5
	
	if particles:
		particles.restart() 
		
	if current_state == State.ANGRY and current_annoyance >= max_annoyance:
		trigger_jumpscare()
	elif current_annoyance > max_annoyance:
		current_annoyance = max_annoyance

func trigger_jumpscare():
	is_game_over = true
	cat_button.texture_normal = tex_jumpscare
	await get_tree().create_timer(1.2).timeout
	get_tree().reload_current_scene()
