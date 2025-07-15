extends RefCounted
class_name StaticSignal

static var static_signal_id: int = 0

static func make() -> Signal:
	var signal_name: String = "StaticSignal-%s" % static_signal_id
	var owner_class := (StaticSignal as Object)
	owner_class.add_user_signal(signal_name)
	static_signal_id += 1
	return Signal(owner_class, signal_name)
