extends Node2D


var time: float:
    get:
        return Time.get_unix_time_from_system()

func _ready():
    Helm.register("main", self)
    Helm.register("zebra", self)
    Helm.register("alpha", self)


func say(something):
    var result = "say " + something
    print("main: %s" % result)
    return result


var help: String:
    get:
        return "this is smart enough"
