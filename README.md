# GodotHackScript
An "ingame" scripting language for Godot programs

Godot HackScript can be used inside a Godot program after it has been compiled. (it runs inside the executable)

The foundation of the console part is a modificaiton of: https://github.com/Calinou/godot-console

Command List:

"help":"Syntax: help:command Info: Show help info",
"output":"Syntax: output:message Info:Print mesage to console",
"show_history":"Info: Show command history",
"clear_history":"Info: Clear command history",
"new_Var":"Syntax: new_Var:variable,value Info: create a new variable",
"setVar":"Syntax: setVar:variable,valuex Info: Change a variable", 
"get_Var":"Syntax: get_Var:variable,storage(optional) Info: show value of a variable and optionally store result in variable",
"add_Vars":"Syntax: add_Vars:var1,var2,result Info: adds 2 variables together and stores result", 
"sub_Vars":"Syntax: sub_Vars:var1,var2,result Info: subtracts 2 variables and stores result",
"mul_Vars":"Syntax: mul_Vars:var1,var2,result Info: multiplies 2 variables together and stores result",
"div_Vars":"Syntax: div_Vars:var1,var2,result Info: divides 2 variables and stores result",
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
"export_dict":"Syntax: export_dict:fileName,dictionary write dictionary to a file",
"import_dict":"Syntax: import_dict:fileName,dictionary load dictionary and store it in given dictionary",
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
