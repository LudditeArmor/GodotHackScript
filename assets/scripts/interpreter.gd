extends Node

#This is where all the magic happens

onready var rootNode = get_node("/root/RootNode")
onready var console = get_node("/root/RootNode/Console")

var defaultScript_PATH = "res://GodotHackScript/"
#if isVerbose = true the console displays extra info (for debugging)
var isVerbose = false
var isBuffering = false
#A buffer can be used as a program (a list of commands to be executed in sequence)
var buffer = []
#internal memory of buffers
var bufferArray = []
#internal memory of variables
var variableList = {}
#Used for line numbering in buffering mode and viewing scripts (it has no effect in the program)
var lineNumber = 1 
#Current command position in buffer being executed
var currentPos = 0
#Last command position in buffer that was executed
var lastPos = 0

#List of all commands
#Each command has a helper description
var commandList = {"help":"Syntax: help:command Info: Show help info",
				   "output":"Syntax: output:message Info:Print mesage to console",
				   "show_history":"Info: Show command history",
				   "clear_history":"Info: Clear command history",
				   "new_Var":"Syntax: new_Var:variable,value Info: create a new variable",
				   "setVar":"Syntax: setVar:variable,valuex Info: Change a variable", 
				   "get_Var":"Syntax: get_Var:variable,storage(optional) Info: show value of a variable and optionally store result in variable",
				   "add_Vars":"Syntax:add_Vars:var1,var2,result Info: adds 2 variables together and stores result", 
				   "sub_Vars":"Syntax:sub_Vars:var1,var2,result Info: subtracts 2 variables and stores result",
				   "mul_Vars":"Syntax:mul_Vars:var1,var2,result Info: multiplies 2 variables together and stores result",
				   "div_Vars":"Syntax:div_Vars:var1,var2,result Info: divides 2 variables and stores result",
				   "sin":"Syntax: sin:var1,result Info: store the sin() of var1 into result",
				   "load_script":"Syntax: load_script:fileName Info: load and execute a script",
				   "write_script":"Syntax: write_script:filename,stringArray=buffer Info: writes string array to script",
				   "append_script":"Syntax: append_script:filename,command Info: write a single string to end of a file ",
				   "show_script":"Syntax: show_script:filename Info: Show the contents of a script",
				   "start_buffer":"Info: Start buffering all input into a string array",
				   "end_buffer":"Info: stop buffering all input",
				   "show_buffer":"Info: Show contents of entire buffer",
				   "clear_buffer":"Info: clear entire buffer",
				   "exec_buffer":"Info: Executes all commands in a buffer",
				   "jump_buffer":"Syntax: jump_buffer:var1, Info: executes command at specified line in buffer if integer is given, if string is given it jumps to specified label",
				   "save_buffer":"Syntax: save_buffer:index(optional) Store current buffer in a buffer array (buffer memory)",
				   "load_buffer":"Syntax: load_buffer:index(optional) Load a buffer from the buffer array (buffer memory)",
				   "export_dict":"Syntax:export_dict:fileName,dictionary write dictionary to a file",
				   "import_dict":"Syntax:import_dict:fileName,dictionary load dictionary and store it in given dictionary",
				   "for":"Syntax: for:var1,var2,command Info: Executes command for var1 to var2 times",
				   "if":"Syntax: if:var1,var2,command,mode Info: Executes command only if var1 and var2 pass the test Modes: EQUAL, NOT, GREATER, SMALLER",
				   "exec":"Syntax: exec:command Info: directly executes specified command",
				   "get_node":"Syntax: get_node:nodePath,storage Info: Store node with nodepath in variable",
				   "add_object":"Syntax: add_object:name Info: Adds an object",
				   "clr":"Info: Clear console window",
				   "toggle_verbose":"Info: Sets verbose logging for debugging",
				   "show_varList":"Info: Show all stored variables",
				   "get_input":"Syntax: get_input:variable Info: wait for input into and store in a variable",
				   "get_random":"Syntax: get_random:a,b,result Info: get a random integer between a and b and store it in result",
				   "play_sound":"Syntax: play_sound:name Info: Plays a sound with given name"
				  }

#On startup
func _ready():
	pass
	
#Receive command for execution
func receiveCMD(input):
	#Commands are handled only when not buffering
	if(isBuffering == false):
		var command = ""
		var arguments = []
		#Checks if command has extra arguments
		var argumentIdentity = input.findn(":")
		if(argumentIdentity != -1):
			#Strip the command from the raw input
			command = input.substr(0, argumentIdentity)
			#Get all the arguments
			var args = input.right(argumentIdentity+1)
			#Check if there is more than 1 argument
			if(args.findn(",") != -1):
				#Seperate all the arguments and put into array
				arguments = args.split(",", false)
			#Only 1 argument
			else:
				arguments.resize(1)
				arguments[0] = args
		#No extra arguments
		else:
			command = input
			
		#Ignoring labels
		if(command.substr(0, 4) == "LBL_"):
			command = ""
			
		#For potential debugging
		if(isVerbose):
			output("---------------")
			output("+Verbose Mode+")
			output("---------------")
			output("raw input:" + input)
			output("command:" + command)
			for i in range(0, arguments.size()):
				output("argument:" + arguments[i])
			output("---------------")
		
		#############################
		#Proccesing all the commands#
		#############################
		if(commandList.has(command)):
			if(command == "help"):
				if(arguments.size() == 0):
					help("empty")
				else:
					help(arguments[0])
			if(command == "output"):
					output(arguments[0])
			if(command == "show_history"):
				show_history()
			if(command == "clear_history"):
				clear_history()
			if(command == "new_Var"):
				new_Var(arguments[0], arguments[1])
			if(command == "get_Var"):
				if(arguments.size() == 1):
					get_Var(arguments[0])
				if(arguments.size() == 2):
					get_Var(arguments[0], arguments[1])
				else:
					output("ERROR: Incorrect # of arguments")
					return -1
			if(command == "add_Vars"):
				if(arguments.size() == 3):
					add_Vars(arguments[0], arguments[1], arguments[2])
				else:
					output("ERROR: Incorrect # of arguments")
					return -1
			if(command == "sub_Vars"):
				if(arguments.size() == 3):
					sub_Vars(arguments[0], arguments[1], arguments[2])
				else:
					output("ERROR: Incorrect # of arguments")
					return -1
			if(command == "mul_Vars"):
				if(arguments.size() == 3):
					mul_Vars(arguments[0], arguments[1], arguments[2])
				else:
					output("ERROR: Incorrect # of arguments")
					return -1
			if(command == "div_Vars"):
				if(arguments.size() == 3):
					div_Vars(arguments[0], arguments[1], arguments[2])
				else:
					output("ERROR: Incorrect # of arguments")
					return -1
			if(command == "sin"):
				sinCMD(arguments[0], arguments[1])
			if(command == "load_script"):
				load_script(arguments[0])
			if(command == "show_script"):
				show_script(arguments[0])
			if(command == "write_script"):
				if(arguments.size() == 1):
					write_script(arguments[0])
				elif(arguments.size() == 2):
					write_script(arguments[0], arguments[1])
				else:
					output("ERROR: Incorrect # of arguments")
					return -1
			if(command == "start_buffer"):
				start_buffer()
			if(command == "stop_buffer"):
				stop_buffer()
			if(command == "show_buffer"):
				show_buffer()
			if(command == "clear_buffer"):
				clear_buffer()
			if(command == "exec_buffer"):
				exec_buffer()
			if(command == "jump_buffer"):
				if(arguments.size() == 1):
					jump_buffer(arguments[0])
				else:
					output("ERROR: Incorrect arguments")
					return -1
			if(command == "save_buffer"):
				if(arguments.size() == 0):
					save_buffer()
				elif(arguments.size() == 1):
					save_buffer(arguments[0])
				else:
					output("ERROR: Incorrect arguments")
					return -1
			if(command == "load_buffer"):
				if(arguments.size() == 0):
					load_buffer()
				elif(arguments.size() == 1):
					load_buffer(arguments[0])
				else:
					output("ERROR: Incorrect arguments")
					return -1
			if(command == "export_dict"):
				export_dictionary(arguments[0], arguments[1])
			if(command == "import_dict"):
				import_dictionary(arguments[0], arguments[1])
			if(command == "for"):
				forCMD(arguments[0], arguments[1], arguments[2])
			if(command == "if"):
				if(arguments.size() == 4):
					ifCMD(arguments[0], arguments[1], arguments[2], arguments[3])
				else:
					output("ERROR: Incorrect # of arguments")
					return -1
			if(command == "exec"):
				receiveCMD(arguments[0])
			if(command == "get_node"):
				get_NodeCMD(arguments[0], arguments[1])
			if(command == "clr"):
				clr()
			if(command == "toggle_verbose"):
				toggle_verbose()
			if(command == "show_varList"):
				show_varList()
			if(command == "get_input"):
				get_inputCMD(arguments[0])
			if(command == "get_rnadom"):
				get_random(arguments[0], arguments[1], arguments[2])
			if(command == "play_sound"):
				play_soundCMD(arguments[0])
		else:
			output("Unknown command \"" + str(input) + "\" \n For a list of commands type \"help:all\"")
	#Buffering stops handling all commands and instead writes all input into a buffer (string array)
	else:
		lineNumber += 1
		buffer.append(input)
		if(input == "stop_buffer"):
			stop_buffer()

##########################################
# ALL COMMAND FUNCTIONS BEYOND THIS POINT#
##########################################

func help(info):
	if(info == "empty"):
		output("Type: help:all for a list of all commands")
		output("Type: help:command for syntax and info on a specific command")
		output("Default Keyboard commands:")
		output("` - open or close this console window") 
		output("F1 or SHIFT + UP - re-use last used command")
		output("CTRL+C - End buffering ")
	elif(info == "all"):
		output("A list of all the commands: ")
		for key in commandList:
			output(key)
	elif(commandList.has(info)):
		output(commandList[info])
	else:
		output("Specified command does not exist")

func output(msg):
	console.write(msg)
	
func show_history():
	output(str(console.inputHistory))
	
func clear_history():
	console.inputHistory.clear()
	
func new_Var(varName, value):
	variableList[varName] = value
	
func get_Var(varName, storage = "null"):
	if variableList.has(varName):
		output(variableList[varName])
		if(storage != "null"):
			new_Var(storage, variableList[varName])
		return variableList[varName]
	else:
		output("ERROR: variable does not exist")
		output("ERR: From function: get_var(varName, storage=0)")
		return -1
	
func add_Vars(var1, var2, result):
	var r = float(check_num_or_var(var1)) + float(check_num_or_var(var2))
	new_Var(result, r)
	return r
	
		
func sub_Vars(var1, var2, result):
	var r = float(check_num_or_var(var1)) - float(check_num_or_var(var2))
	new_Var(result, r)
	return r
		
func mul_Vars(var1, var2, result):
	var r = float(check_num_or_var(var1)) * float(check_num_or_var(var2))
	new_Var(result, r)
	return r
		
func div_Vars(var1, var2, result):
	var r = float(check_num_or_var(var1)) / float(check_num_or_var(var2))
	new_Var(result, r)
	return r
		
func sinCMD(var1, result):
	var r = sin(float(check_num_or_var(var1)))
	new_Var(result, r)
	return r
	
#Executes all the commands in a txt file
func load_script(fileName):
	#Save current buffer first
	if(buffer.size() != 0):
		save_buffer()
	#clear buffer to get a new one from file
	clear_buffer()
	var file = File.new()
	if (file.file_exists(defaultScript_PATH + fileName + ".txt")):
		file.open(defaultScript_PATH + fileName + ".txt", file.READ)
		var i = 0
		while(file.get_line() != "END"):
			buffer.append(file.get_line())
			i += 1
		file.close()
		exec_buffer()
		
	else:
		output("ERROR: No such file exsists: " + fileName)
		output("ERR: From function: load_script(fileName)")
		return -1 #Error!  We don't have a file to load
		
func show_script(fileName):
	var file = File.new()
	if (file.file_exists(defaultScript_PATH + fileName + ".txt")):
		file.open(defaultScript_PATH + fileName + ".txt", file.READ)
		var i = 0
		lineNumber = 1
		while(file.get_line() != "END"):
			output(str(lineNumber) + ". " + file.get_line())
			i += 1
			lineNumber += i
		file.close()
		
	else:
		output("ERROR: No such file exsists: " + fileName)
		output("ERR: From function: show_script(fileName)")
		return -1 #Error!  We don't have a file to load

func write_script(fileName, buff=buffer):
	var file = File.new()
	file.open(defaultScript_PATH + fileName + ".txt", file.WRITE)
	for i in range(0, buff.size()):
		file.store_line(buff[i])
	file.store_line("END")
	file.close()
	save_buffer(0)
	clear_buffer()
	if(isVerbose):
		output("Written buffer to file: " + fileName + ".txt")
		output("Buffer saved in BufferArray[0]")
		output("Current buffer cleared")
	
func start_buffer():
	output("+++Buffering Mode Started+++")
	#Clear and save old buffer
	if(buffer.size() > 0):
		save_buffer()
		clear_buffer()
	isBuffering = true
	
func end_buffer():
	output("+++Buffering Mode Stopped+++")
	lineNumber = 0
	isBuffering = false

func show_buffer():
	lineNumber = 0
	for i in range(0, buffer.size()):
		lineNumber += 1
		output(str(lineNumber) + ". " + buffer[i])
		
func clear_buffer():
	buffer.clear()
	
func exec_buffer():
	currentPos = 0
	for i in range(0, buffer.size()):
		lastPos = currentPos
		receiveCMD(buffer[i])
		currentPos += 1
		
func jump_buffer(position):
	#safe current position first
	currentPos = lastPos
	#Check if position is a number
	if(position.is_valid_integer()):
		position = int(position)
		if(position > buffer.size()):
			output("ERROR: position: " + position + " does not exist in buffer")
			output("ERR: From function: jump_buffer(position)")
			return -1
		else:
			receiveCMD(buffer[position])
	#Jump to string label and execute next command
	else:
		if(buffer.find("LBL_" + position) != -1):
			receiveCMD(buffer[buffer.find("LBL_" + position)]+1)
		else:
			output("ERROR: Label: " + "LBL_" + position + " not found")
			output("ERR: From function: jump_buffer(position)")
			return -1
			
func save_buffer(index = -1):
	if(buffer.size() > 0):
		if(index == -1):
			bufferArray.append(buffer)
		else:
			bufferArray.insert(index, buffer)
	else:
		output("ERROR: Cant save empty buffer")
		output("ERR: From function: save_buffer(index = -1)")
		return -1
		
func load_buffer(index = -1):
	if(index == -1):
		buffer = bufferArray.front()
	else:
		buffer = bufferArray[index]
		
func export_dictionary(fileName, dict):
	var file = File.new()
	file.open(defaultScript_PATH + fileName + ".txt", file.WRITE)
	
	file.close()
	
func import_dictionary(fileName, dict):
	pass
		
func forCMD(start, end, command):
	#First check if variables are numbers or stored variables
	start = check_num_or_var(start)
	end = check_num_or_var(end)
		
	for i in range(float(start), float(end)):
		receiveCMD(command)

func ifCMD(var1, var2, command, mode):
	mode = mode.capitalize()
	if(mode == "EQUAL"):
		if(var1 == var2):
			receiveCMD(command)
	if(mode == "NOT"):
		if(var1 != var2):
			receiveCMD(command)
	if(mode == "GREATER"):
		if(var1 > var2):
			receiveCMD(command)
	if(mode == "SMALLLER"):
		if(var1 < var2):
			receiveCMD(command)

func get_NodeCMD(nodePath, storage):
	var node = get_node(nodePath)
	new_Var(storage, node)
	return node
	
func add_object(name):
	pass
	
func clr():
	console.outputNode.clear()
	
func toggle_verbose():
	if(isVerbose):
		isVerbose = false
	else:
		isVerbose = true
		output("Verbose mode enabled")
		
func show_varList():
	output(variableList)
	
func get_inputCMD(storage):
	var input = yield(console.inputNode, "text_entered")
	output("Waiting for input:...")
	print(input)
	# Clean the string
	input = input.replace("$ ", "")
	input = input.strip_edges()
	if(input != ""):
		new_Var(storage, input)
		print(str(variableList))
		print(input)
	elif(isVerbose):
		output("WARNING: empty string entered, input not saved")
		
func get_random(a, b, result):
	#Seed the random number generator
	randomize()
	var random = randi()%check_num_or_var(a)+check_num_or_var(b)
	new_Var(result, random)
	return random
	
func play_soundCMD(name):
	if console.GlobalsampleLibrary.has_sample():
		console.soundPlayer.play(name)
	else:
		output("ERROR: sound " + name + " not found")
		output("ERR: From function: play_soundCMD(name)") 
		
#Checks if a string is a number or a stored variable
#Returns number if number else return stored variable
func check_num_or_var(string):
	if(string.is_valid_integer() or string.is_valid_float()):
		return string
	else:
		if(variableList.has(string)):
			return variableList[string]
		else:
			output("ERROR: Variable " + string + " not found")
			output("ERR: From function: check_num_or_var(string)") 
			return -1