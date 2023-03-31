@tool
extends EditorPlugin

var shake = 0.0
var shake_intensity = 0.0
var timer = 0.0
var last_key = ""
var pitch_increase := 0.0
var editors = {}
var color_counter = 0

const PITCH_DECREMENT := 10.0

const Boom = preload("boom.tscn")
const Blip = preload("blip.tscn")
const Newline = preload("newline.tscn")

const Dock = preload("dock.tscn")
var dock

signal typing

func _enter_tree():
	var editor = get_editor_interface()
	var script_editor = editor.get_script_editor()
	script_editor.connect("editor_script_changed", Callable(self, "editor_script_changed"))
	
	# Add the main panel
	dock = Dock.instantiate()
	connect("typing", Callable(dock, "_on_typing"))
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)


func _exit_tree():
	if dock:
		remove_control_from_docks(dock)
		dock.free()
		

func get_all_text_editors(parent : Node):
	for child in parent.get_children():
		
		if child.get_child_count():
			get_all_text_editors(child)
			
		if child is TextEdit:
			editors[child] = { "text": child.text, "line": child.get_caret_line()}# , "bgimage": bg}
		
			if child.is_connected("caret_changed", Callable(self, "caret_changed")):
				child.disconnect("caret_changed", Callable(self, "caret_changed"))
			child.connect("caret_changed", Callable(self, "caret_changed").bind(child))
				
			if child.is_connected("text_changed", Callable(self, "text_changed")):
				child.disconnect("text_changed", Callable(self, "text_changed"))
			child.connect("text_changed", Callable(self, "text_changed").bind(child))

			if child.is_connected("gui_input", Callable(self, "gui_input")):
				child.disconnect("gui_input", Callable(self, "gui_input"))
			child.connect("gui_input", Callable(self, "gui_input"))


func gui_input(event):
	# Get last key typed
	if event is InputEventKey and event.pressed:
		event = event as InputEventKey
		last_key = event.as_text_keycode()

func editor_script_changed(script):
	var editor = get_editor_interface()
	var script_editor = editor.get_script_editor()
	
	editors.clear()
	get_all_text_editors(script_editor)


func _process(delta):
	var editor = get_editor_interface()
	
	if shake > 0:
		shake -= delta
		editor.get_base_control().position = Vector2(randf_range(-shake_intensity,shake_intensity), randf_range(-shake_intensity,shake_intensity))
	else:
		editor.get_base_control().position = Vector2.ZERO

	timer += delta
	if (pitch_increase > 0.0):
		pitch_increase -= delta * PITCH_DECREMENT

func do_shake(duration, intensity):
	if shake > 0:
		return
	shake = duration
	shake_intensity = intensity
	
func caret_changed(textedit):
	var editor = get_editor_interface()

	if not editors.has(textedit):
		# For some reason the editor instances all change
		# when the file is saved so you need to reload them
		editors.clear()
		get_all_text_editors(editor.get_script_editor())
		
	editors[textedit]["line"] = textedit.get_caret_line()

var font = preload("res://addons/ridiculous_coding/JetBrainsMono_Regular.woff2")

func text_changed(textedit : TextEdit):
	var editor = get_editor_interface()
	var settings = editor.get_editor_settings()
	
	if not editors.has(textedit):
		# For some reason the editor instances all change
		# when the file is saved so you need to reload them
		editors.clear()
		get_all_text_editors(editor.get_script_editor())
		
	# Get line and character count
	var line = textedit.get_caret_line()
	var column = textedit.get_caret_column()
	
	# Compensate for code folding
	var folding_adjustment = 0
	for i in range(textedit.get_line_count()):
		if i > line:
			break
		if textedit.is_line_folded(i):
			folding_adjustment += 1

	# Compensate for tab size
	var tab_size = settings.get_setting("text_editor/behavior/indent/size")
	var line_text = textedit.get_line(line).substr(0,column)
	column += line_text.count("\t") * (tab_size - 1)

	# Compensate for scroll
	var vscroll = textedit.scroll_vertical
	var hscroll = textedit.scroll_horizontal
	# When you are scrolled to the bottom of a file
	# and you delete some lines from the bottom using Ctrl+X
	# then the vscroll can go down without changing the visible
	# scroll position. That throws off the calculation because
	# we're calculating the position from the lower position but
	# visually the position hasn't moved. By setting vscroll
	# to the new actual position, the editor moves the visible
	# lines to remove the gap. It changes the editor behavior
	# slightly for a better result.
	textedit.scroll_vertical = vscroll
	#                                                    
	# Compensate for line spacing
	var line_spacing = settings.get_setting("text_editor/appearance/whitespace/line_spacing")
	
	# Load editor font
	# font = load("res://addons/ridiculous_coding/JetBrainsMono_Regular.woff2")
	var code_font_size = settings.get_setting("interface/editor/code_font_size")
	var fontsize = font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, code_font_size)
	
	# Compute caret position
	var pos = textedit.get_caret_draw_pos()
	
	pos.y -= 8 # Caret height
	
	emit_signal("typing")
	
	if editors.has(textedit):
		# Deleting
		if timer > 0.1 and len(textedit.text) < len(editors[textedit]["text"]):
			timer = 0.0
			
			if dock.explosions:
				# Draw the thing
				var thing = Boom.instantiate()
				thing.position = pos
				thing.destroy = true
				if dock.chars: thing.last_key = last_key
				thing.sound = dock.sound
				thing.color_counter = color_counter
				color_counter += 1
				textedit.add_child(thing)
				
				if dock.shake:
					# Shake
					do_shake(0.2, 10)

		# Typing
		if timer > 0.01 and len(textedit.text) >= len(editors[textedit]["text"]):
			timer = 0.0

			# Draw the thing
			var thing = Blip.instantiate()
			thing.pitch_increase = pitch_increase
			pitch_increase += 1.0
			thing.position = pos
			thing.destroy = true
			thing.blips = dock.blips
			thing.color_counter = color_counter
			color_counter += 1
			if dock.chars: thing.last_key = last_key
			thing.sound = dock.sound
			textedit.add_child(thing)
			
			if dock.shake:
				# Shake
				do_shake(0.05, 5)
		# Newline
		if textedit.get_caret_line() != editors[textedit]["line"]:
			# Draw the thing
			var thing = Newline.instantiate()
			thing.position = pos
			thing.destroy = true
			thing.blips = dock.blips
			textedit.add_child(thing)
			
			if dock.shake:
				# Shake
				do_shake(0.05, 5)

	editors[textedit]["text"] = textedit.text
	editors[textedit]["line"] = textedit.get_caret_line()
