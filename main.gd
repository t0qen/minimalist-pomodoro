extends Control

# /* global pom variable */

@onready var pom_timer: Timer = $pom_timer
@onready var pom_label: Label = $pomo

enum POMSTATE {
	WORK,
	BREAK,
	STOPPED,
	NOTLAUNCHED,
	PAUSED
}

var current_pom_state : POMSTATE = POMSTATE.NOTLAUNCHED

var is_night_mode : bool = false
var is_stopped : bool = false
var is_paused : bool = false



# pom mode : 50/10 or 25/5
# 25/5 default mode
var work_duration : int = 25
var break_duration : int = 5  

# /* pom func */

func start_pom():
	if current_pom_state == POMSTATE.NOTLAUNCHED or current_pom_state == POMSTATE.BREAK or current_pom_state == POMSTATE.STOPPED  : # all the conditions for pom to start work session
		pom_timer.start((work_duration * 60) - 1) # start timer with work duration in sec
		current_pom_state = POMSTATE.WORK
	elif current_pom_state == POMSTATE.WORK:
		pom_timer.start((break_duration * 60) - 1)
		current_pom_state = POMSTATE.BREAK
	update_pom()
	
func stop_pom():
	pom_timer.stop()
	current_pom_state = POMSTATE.STOPPED
	update_pom()
	
func toggle_pause():
	if is_paused:
		pom_timer.paused = false
		
	else:
		pom_timer.paused = true
		current_pom_state = POMSTATE.PAUSED
		
	is_paused = !is_paused
	update_pom()
	
func toggle_mode():
	stop_pom()
	if work_duration == 25:
		work_duration = 50
		break_duration = 10
	else:
		work_duration = 25
		break_duration = 5
	update_pom()

	
func update_pom():
	if current_pom_state == POMSTATE.NOTLAUNCHED or current_pom_state == POMSTATE.STOPPED:
		pom_label.text = str(work_duration) + ":00"
	else:
		var pom_value : int = int(pom_timer.time_left)
		# pom / 60 : min
		# pom % 60 : sec
		
		# format minute values
		var format_adj_min : String = ""
		if (pom_value / 60) < 10: # print 05 instead of 5
			format_adj_min = "0"
			
		# format second values
		var format_adj_sec : String = ""
		if (pom_value % 60) < 10: # print 05 instead of 5
			format_adj_sec = "0"
	
		# assemble minute and second lefts and print them
		pom_label.text = format_adj_min + str(pom_value / 60) + ":" + format_adj_sec + str(pom_value % 60)
	
func _on_main_pressed() -> void:
	"""
	Not launched : start pomo
	Started : pause
	Paused : resume
	"""
	
	if current_pom_state == POMSTATE.STOPPED or current_pom_state == POMSTATE.NOTLAUNCHED:
		start_pom()
	elif current_pom_state == POMSTATE.WORK or current_pom_state == POMSTATE.BREAK or current_pom_state == POMSTATE.PAUSED:
		toggle_pause()
		
	update_pom()
	
func kill():
	get_tree().quit()

func _on_pom_timer_timeout() -> void:
	print("restarting")
	start_pom()
	
func _on_update_timeout() -> void:
	update_pom()

func _ready() -> void:
	update_pom()

func _on_stop_pressed() -> void:
	stop_pom()


func _on_mode_pressed() -> void:
	toggle_mode()


func _on_kill_pressed() -> void:
	kill()
