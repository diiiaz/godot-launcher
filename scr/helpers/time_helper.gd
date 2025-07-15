extends Node
class_name TimeHelper

const CHECK_NEW_VERSION_TIME_SEC = 24 * 60 * 60  # 1 day


static func get_time_since_last_modified_date(project_last_modified_date_unix: int):
	var date_time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(int(Time.get_unix_time_from_system() - project_last_modified_date_unix))
	date_time_dict.year -= 1970
	date_time_dict.month -= 1
	date_time_dict.day -= 1
	return date_time_dict


static func format_date_time_dict(date_time_dict: Dictionary) -> String:
	if date_time_dict.year > 0:
		return TranslationServer.translate("LAST_MODIFIED_YEARS_AGO") % [date_time_dict.year]
	elif date_time_dict.month > 0:
		return TranslationServer.translate("LAST_MODIFIED_MONTH_AGO") % [date_time_dict.month]
	elif date_time_dict.day > 0:
		return TranslationServer.translate("LAST_MODIFIED_DAYS_AGO") % [date_time_dict.day]
	elif date_time_dict.hour > 0:
		return TranslationServer.translate("LAST_MODIFIED_HOURS_AGO") % [date_time_dict.hour]
	elif date_time_dict.minute > 0:
		return TranslationServer.translate("LAST_MODIFIED_MINUTES_AGO") % [date_time_dict.minute]
	elif date_time_dict.second > 0:
		return TranslationServer.translate("LAST_MODIFIED_SECONDS_AGO") % [date_time_dict.second]
	return TranslationServer.translate("LAST_MODIFIED_SECONDS_AGO") % [0]


static func convert_iso_to_unix_time(date_string: String) -> int:
	# Parse ISO 8601 string into a datetime dictionary
	var datetime_dict = Time.get_datetime_dict_from_datetime_string(date_string, true)
	
	# Validate parsing result
	if datetime_dict.is_empty():
		push_error("Invalid date format")
		return -1
	
	# Convert to Unix timestamp (seconds since 1970-01-01 UTC)
	var unix_time = Time.get_unix_time_from_datetime_dict(datetime_dict)
	return unix_time
