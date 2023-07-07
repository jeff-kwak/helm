class_name HelmCanvas
extends CanvasLayer


signal helm_shown()
signal helm_hidden()


const HELM_TOGGLE_ACTION_NAME = "ui_toggle_helm"


@onready var command_input = %CommandInput
@onready var result_output = %Result


var _registered_objects = { }
var _registered_descriptions = { }
var _already_shown = false


func _ready():
    register("help", Help.new(result_output, _registered_descriptions), "Display help and registered objects")
    hide_helm()


func register(registered_name: String, target, description: String = ""):
    if _registered_objects.has(registered_name):
        push_warning("The registered name '%s' has already been used. Not replacing the original" % registered_name)
        return

    _registered_objects[registered_name] = target
    _registered_descriptions[registered_name] = description




func hide_helm():
    visible = false
    command_input.focus_mode = Control.FOCUS_NONE
    helm_hidden.emit()


func show_helm():
    visible = true
    if not _already_shown:
        _already_shown = true
        _eval_command("help")

    command_input.focus_mode = Control.FOCUS_ALL
    command_input.clear()
    command_input.grab_focus()
    helm_shown.emit()


func _on_command_input_text_changed(new_text:String):
    print("helm: text changed %s" % new_text)


func _on_command_input_text_submitted(command:String):
    _eval_command(command)


func _eval_command(command: String):

    var expression = Expression.new()
    var error = expression.parse(command, _registered_objects.keys())

    if error != OK:
        _append_error(command, expression)
        return

    var result = expression.execute(_registered_objects.values(), self)

    if not expression.has_execute_failed():
        _append_ok(command, result)
    else:
        _append_error(command, expression)


func _append_ok(command: String, result) -> void:
    result_output.append_text("[color=green][b]> {command}[/b][/color]\n".format({ "command": command }))
    result_output.append_text(str(result))
    result_output.append_text("\n")


func _append_error(command: String, expression: Expression) -> void:
    result_output.append_text("[color=red][b]< ERROR '{command}'[/b][/color]\n".format({"command": command}))
    result_output.append_text("[color=red]{result}[/color]".format({"result": expression.get_error_text()}))
    result_output.append_text("\n")






class Help:

    const HELP_HEADER = """
        A very simple runtime expression validator. Register
        objects in your program using the [b]register[/b] function
        and use them as normal. Here are all the registered
        objects so far.

"""


    var _out: RichTextLabel
    var _desc = {}


    func _init(target_output: RichTextLabel, registered_descriptions):
        _out = target_output
        _desc = registered_descriptions

    func _to_string():
        _out.append_text("\n")
        _out.push_bold()
        _out.push_color(Color.CYAN)
        _out.append_text("\t\tHelm\n")
        _out.pop()
        _out.pop()
        _out.push_color(Color.YELLOW)
        _out.append_text(HELP_HEADER)
        _out.pop()
        var desc: PackedStringArray = _desc.keys()
        desc.sort()
        for reg_name in desc:
            _out.push_color(Color.WHITE)
            _out.push_bold()
            _out.append_text("\t\t%s" % reg_name)
            _out.pop()
            _out.pop()
            _out.push_color(Color.LIGHT_GRAY)
            _out.append_text("\t\t%s\n" % _desc[reg_name])
            _out.pop()

        return ""

