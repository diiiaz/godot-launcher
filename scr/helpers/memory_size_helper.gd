extends RefCounted
class_name MemorySizeHelper

const BYTE_SIZE: int = 1
const KILOBYTE_SIZE: int = BYTE_SIZE * 1024
const MEGABYTE_SIZE: int = KILOBYTE_SIZE * 1024
const GIGABYTE_SIZE: int = MEGABYTE_SIZE * 1024


static func format_file_size(file_size: float) -> String:
	return str(snapped(get_largest_size_from_byte_size(file_size), 0.1), get_size_name_from_byte_size(file_size))


static func get_largest_size_from_byte_size(byte_size: float) -> float:
	if byte_size > GIGABYTE_SIZE:
		return byte_size / float(GIGABYTE_SIZE)
	elif byte_size > MEGABYTE_SIZE:
		return byte_size / float(MEGABYTE_SIZE)
	elif byte_size > KILOBYTE_SIZE:
		return byte_size / float(KILOBYTE_SIZE)
	return byte_size


static func get_size_name_from_byte_size(byte_size: float) -> String:
	if byte_size > GIGABYTE_SIZE:
		return "GB"
	elif byte_size > MEGABYTE_SIZE:
		return "MB"
	elif byte_size > KILOBYTE_SIZE:
		return "KB"
	return "Bytes"
	
