extends RefCounted
class_name Helper

static func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)

static func get_first_regex_find(pattern: String, subject: String) -> String:
	var regex: RegEx = RegEx.new()
	regex.compile(pattern)
	var result: RegExMatch = regex.search(subject)
	if not result:
		return ""
	return result.get_string(1)
