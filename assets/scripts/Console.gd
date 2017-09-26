extends CanvasLayer

#Command Line Interface (CLI) for the interpreter

#Default Console keyboard commands:
	#` = open or close console
	#F1 = put last used command back into input bar
	#CTRL + C = Stop buffering

onready var rootNode = get_node("/root/RootNode")
onready var outputNode = get_node("Control/term_panel/term_out")
onready var inputNode = get_node("Control/term_panel/term_in")
onready var interpreter = get_node("Interpreter")
onready var soundPlayer = get_node("Global_SoundControl")

# Key Input: Enter the keymap values!
export (String) var input_map_enter
export (String) var input_map_toggle
export (String) var input_map_getLast
export (String) var input_map_stopBuffer

var MAXHISTORY = 10

# Console status
var is_enabled = false
var inputHistory = []
var GlobalsampleLibrary = SampleLibrary.new()

#Startup message
var BANNER = "Welcome to the console window for more info type \"Help\" "

# Console signal
signal console_status

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(false)
	set_process_input(true)
	soundPlayer.set_sample_library(GlobalsampleLibrary)
	
	# Add indentation and scrolling so you always see bottom line
	outputNode.push_indent(1)
	outputNode.set_scroll_follow(true)
	
	#Startup message
	write("\n")
	write("Title: " + rootNode.title + "\n Version: " + rootNode.version)
	write(BANNER)
	
func _process(delta):
	# Prevents removal of command line sign "$ " 
	if(inputNode.get_text().length() <= 1):
		clear()
		
	# Enable focus after animation has been completed and enabled
	if(!get_node("Control/console_animation").is_playing() && is_enabled):
		inputNode.set_focus_mode(inputNode.FOCUS_CLICK)
		inputNode.grab_focus()
		
func _input(event):
	# Processes user input in console
	if(is_enabled):
		if(event.is_action_pressed(input_map_enter)):
			process_input(inputNode.get_text())
			
		#Put last used command in input
		if(event.is_action_pressed(input_map_getLast)):
			#prevents errors
			if(inputHistory.size() > 0): 
				inputNode.set_text("$ " + inputHistory[0])
				inputNode.set_cursor_pos(inputHistory[0].length())
	# Toggle console
	if(event.is_action_pressed(input_map_toggle)):
		toggle()
	#stop buffering with keyboard
	if(event.is_action_pressed(input_map_stopBuffer)):
		if(interpreter.isBuffering):
			interpreter.end_buffer()
	
		
func process_input(msg):
	if(!interpreter.isBuffering):
		# Write input to console
		write(msg)
		
		# Clean the string
		msg = msg.replace("$ ", "")
		msg = msg.strip_edges()
		
		# Send command to intepreter for execution
		# if its not empty
		if(msg != ""):
			#Add command to history
			if(inputHistory.size() >= MAXHISTORY):
				#Write history to a history file when MaxHistory is reached
				interpreter.write_script("command_history", inputHistory)
				inputHistory.pop_back()
			
			inputHistory.push_front(msg)
			interpreter.receiveCMD(msg)
			
	if(interpreter.isBuffering):
		# Clean the string
		msg = msg.replace("$ ", "")
		msg = msg.strip_edges()
		var bufferInput = msg
		#ignore "start_buffer" command first time when starting buffer
		if(bufferInput == inputHistory[0]):
			inputHistory.clear()
			inputHistory.append("null")
		else:
			#add line numbering
			msg = str(interpreter.lineNumber) + ". " + msg
			write(msg)
			#Send to intepreter (adds to buffer)
			if(bufferInput != ""):
				interpreter.receiveCMD(bufferInput)
		
# Execute command directly from outside (without interacting with console directly)'
func execute(cmd):
	interpreter.receiveCMD(cmd)

# Writes to console
func write(msg):
	outputNode.add_text(str(msg) + "\n")
	clear()

# Clears the command input line
func clear():
	inputNode.set_text("$ ")
	inputNode.set_cursor_pos(2)
	
# Toggles the console window
func toggle():
	if(!get_node("Control/console_animation").is_playing()): 
		is_enabled = !is_enabled
		set_process(is_enabled)
		
		# Remove line edit focus when disabling console
		if(!is_enabled):
			inputNode.set_focus_mode(inputNode.FOCUS_NONE)
			inputNode.grab_focus()
		
		# Animation
		if(is_enabled):
			get_node("Control/console_animation").play("console_open")
		else:
			get_node("Control/console_animation").play("console_close")
		
		# Notify others about console status
		notify_others()

# Notifies other scripts that are connected to this, that console status has changed
func notify_others():
	emit_signal("console_status", is_enabled)
