extends RefCounted
class_name SystemHelper

enum PLATFORM {
	LINUX,
	MACOS,
	WINDOWS,
	UNKNOWN,
}

const PLATFORM_NAME = {
	PLATFORM.LINUX: "Linux",
	PLATFORM.MACOS: "MacOs",
	PLATFORM.WINDOWS: "Windows",
	PLATFORM.UNKNOWN: "",
}

const PLATFORM_NAMES = {
	PLATFORM.LINUX: ["X11"],
	PLATFORM.MACOS: ["macOS"],
	PLATFORM.WINDOWS: ["Windows"],
}

const PLATFORM_URL_PATTERNS_MAPPING = {
	PLATFORM.LINUX: ["linux"],
	PLATFORM.MACOS: ["macos", "universal"],
	PLATFORM.WINDOWS: ["windows", "win"],
}

const PLATFORM_ARCHITECTURE_PATTERNS_MAPPING = {
	PLATFORM.LINUX: ["arm32", "arm64", "x86_32", "x86_64"],
	PLATFORM.MACOS: ["universal"],
	PLATFORM.WINDOWS: ["32", "64", "arm64"],
}

static var _system_info: SystemInfo = null
@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
static var _plaform: PLATFORM = -1


static func get_or_create_platform() -> PLATFORM:
	if _plaform != -1:
		return _plaform
	for platform: PLATFORM in PLATFORM_NAMES.keys():
		for platform_name: String in PLATFORM_NAMES.values()[platform]:
			if OS.get_name() == platform_name:
				_plaform = platform
				break
	return _plaform


static func get_or_create_system_info() -> SystemInfo:
	if _system_info != null:
		return _system_info
	var architecture: String = "unknown"
	var platform: PLATFORM = get_or_create_platform()
	
	match platform:
		PLATFORM.WINDOWS:
			architecture = _get_windows_architecture()
		PLATFORM.MACOS:
			architecture = _get_macos_architecture()
		PLATFORM.LINUX:
			architecture = _get_linux_architecture()
		_: # Other platforms (BSD, Haiku, etc)
			architecture = "x86_64" if OS.has_feature("64") else "x86"
	
	_system_info = SystemInfo.new(get_or_create_platform(), architecture)
	return _system_info


static func _get_windows_architecture() -> String:
	# Windows architecture detection (handles WOW64 and ARM)
	var env_vars = [
		"PROCESSOR_ARCHITECTURE",    # Native arch (e.g., AMD64)
		"PROCESSOR_ARCHITEW6432"     # WOW64 arch (for 32-bit apps on 64-bit OS)
	]

	var arch = ""
	for var_name in env_vars:
		var value = OS.get_environment(var_name).to_lower()
		if value.is_empty():
			continue
		
		match value:
			"amd64", "ia64":
				arch = "x86_64"
			"x86":
				arch = "x86"
			"arm64":
				arch = "arm64"
			_:
				arch = value

		if !arch.is_empty():
			break

	# Handle WOW64 special case (32-bit app on 64-bit OS)
	if arch == "x86" && OS.has_feature("64"):
		arch = "x86_64"

	return arch if !arch.is_empty() else "x86"


static func _get_macos_architecture() -> String:
	# macOS architecture (Apple Silicon vs Intel)
	var arch: String
	var output = []
	var exit_code = OS.execute("uname", ["-m"], output)
	if exit_code == 0 && !output.is_empty():
		var uname_m = output[0].strip_edges().to_lower()
		match uname_m:
			"x86_64":
				# Check if running under Rosetta (Apple Silicon)
				var rosetta_check = []
				OS.execute("sysctl", ["-n", "sysctl.proc_translated"], rosetta_check)
				if !rosetta_check.is_empty() && rosetta_check[0].strip_edges() == "1":
					arch = "arm64"  # Running x86_64 binary on ARM via Rosetta
				else:
					arch = "x86_64"
			"arm64":
				arch = "arm64"
			_:
				arch = uname_m
	else:
		# Fallback for older macOS versions
		arch = "x86_64" if OS.has_feature("64") else "x86"
	return arch


static func _get_linux_architecture() -> String:
	# First try uname -m
	var output = []
	var arch: String
	var exit_code = OS.execute("uname", ["-m"], output)
	if exit_code == 0 && !output.is_empty():
		var uname_m = output[0].strip_edges().to_lower()
		match uname_m:
			"x86_64", "amd64":
				arch = "x86_64"
			"i686", "i386":
				arch = "x86"
			"aarch64", "armv8l":
				arch = "arm64"
			"armv7l", "armv6l":
				arch = "armv7"
			"riscv64":
				arch = "riscv64"
			_:
				arch = uname_m

	# If uname fails, check /proc/cpuinfo for ARM
	if arch == "unknown":
		var cpuinfo = FileAccess.open("/proc/cpuinfo", FileAccess.READ)
		if cpuinfo:
			var content = cpuinfo.get_as_text()
			cpuinfo.close()
			if "ARMv7" in content:
				arch = "armv7"
			elif "aarch64" in content:
				arch = "arm64"
			elif "x86_64" in content:
				arch = "x86_64"

	# Final fallback
	if arch == "unknown":
		arch = "x86_64" if OS.has_feature("64") else "x86"

	return arch
