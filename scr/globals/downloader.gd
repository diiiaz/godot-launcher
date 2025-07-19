extends Node

signal download_started(downloadable: Downloadable)
signal download_ticked(downloadable: Downloadable, percentage: float)
signal download_finished(downloadable: Downloadable)

const RELOAD_LAUNCHER_AFTER_UPDATE_BATCH_FILE = "res://scripts/reload_launcher_after_update.bat"
const ZIP_EXTENSION: String = ".zip"

var _is_downloading: bool


func is_downloading() -> bool:
	return _is_downloading


func download(downloadable: Downloadable) -> void:
	if _is_downloading:
		ToastsManager.create_warning_toast(tr("WARNING_ALREADY_DOWNLOADING_BUILD"))
		return
	
	if downloadable.is_downloaded():
		ToastsManager.create_warning_toast(tr("WARNING_ALREADY_DOWNLOADED_BUILD").format({"build_name": downloadable.get_name()}))
		return
	
	var toast: Toast = await ToastsManager.create_progress_toast(tr("TOAST_DOWNLOADING_BUILD").format({"build_name": downloadable.get_name()}))
	
	_is_downloading = true
	download_started.emit(downloadable)
	var https_request: HTTPRequest = HTTPRequest.new()
	add_child(https_request)
	https_request.request_completed.connect(_http_request_completed)

	https_request.set_download_file(downloadable.get_unextracted_path()) # when downloaded the file will be saved in downloadable.get_path()
	var request: Error = https_request.request(downloadable.get_url())
	
	while _is_downloading:
		var percentage: float = remap(https_request.get_downloaded_bytes(), 0, downloadable.get_size(), 0.0, 1.0)
		toast.set_progress(remap(percentage, 0.0, 1.0, 0.0, 0.98))
		download_ticked.emit(downloadable, percentage)
		await get_tree().process_frame
		if https_request.get_downloaded_bytes() >= downloadable.get_size() and https_request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			_is_downloading = false
	
	https_request.queue_free()
	
	if request != OK:
		ToastsManager.create_error_toast(TranslationServer.translate("ERROR_REQUEST_FAILED").format({"error": request}))
		toast.close()
		return
	
	if ZIP_EXTENSION in downloadable.get_name():
		await extract_all_from_zip(downloadable.get_unextracted_path())
	
	ToastsManager.create_info_toast(TranslationServer.translate("TOAST_SUCCESS_DOWNLOADED_BUILD").format({"build_name": downloadable.get_name()}))
	download_finished.emit(downloadable)
	downloadable.downloaded.emit()
	toast.set_progress(1.0)


func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		ToastsManager.create_error_toast(TranslationServer.translate("ERROR_DOWNLOAD_FAILED").format({"error": result}))


func extract_all_from_zip(zip_file_path: String) -> void:
	var reader = ZIPReader.new()
	reader.open(zip_file_path)
	
	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open(zip_file_path.get_base_dir())
	
	var files = reader.get_files()
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue
		
		if "console" in file_path:
			continue
		
		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)
	
	await get_tree().process_frame
	DirAccess.remove_absolute.call_deferred(zip_file_path)
