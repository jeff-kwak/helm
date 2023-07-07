extends Node2D

var help: String:
    get:
        return "this is smart enough"


var time: float:
    get:
        return Time.get_unix_time_from_system()


var _is_shown := false


func _ready():
    Helm.register("main", self)
    Helm.register("zebra", self)
    Helm.register("alpha", self)
    Helm.helm_shown.connect(_on_helm_shown)
    Helm.helm_hidden.connect(_on_helm_hidden)


func _input(event):
    if event.is_action_pressed("ui_toggle_helm"):
        Helm.show_helm() if not _is_shown else Helm.hide_helm()


func say(something):
    var result = "say " + something
    print("main: %s" % result)
    return result


var _msg:String = "default message"
var message: String:
    get:
        return _msg
    set(value): # can't get the setter to work
        _msg = value


func _on_helm_shown():
    print("helm shown signal was received")
    _is_shown = true
    get_tree().paused = true


func _on_helm_hidden():
    print("helm hidden signal was received")
    _is_shown = false
    get_tree().paused = false

