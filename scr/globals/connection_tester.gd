extends Node
 
signal connection_gained
signal connection_lost

var _connected: bool = false
#var _connected_last_state: bool = true

func is_connected_to_internet(warn_when_no_connection: bool = false) -> bool:
	var _http_request: HTTPRequest = HTTPRequest.new()
	add_child.call_deferred(_http_request)
	_http_request.request_completed.connect(_on_request_complete)
	await _http_request.ready
	_http_request.request("http://www.msftncsi.com/ncsi.txt")
	await _http_request.request_completed
	await get_tree().process_frame
	_http_request.queue_free()
	#if not _connected and _connected_last_state != _connected and warn_when_no_connection:
	if not _connected and warn_when_no_connection:
		ToastsManager.create_warning_toast(TranslationServer.translate("ERROR_NOT_CONNECTED_TO_INTERNET"), 5.0)
	#_connected_last_state = _connected
	return _connected


func _on_request_complete(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	if (response_code == HTTPClient.ResponseCode.RESPONSE_OK):
		if (_connected == false):
			connection_gained.emit()
		_connected = true
	else:
		if (_connected == true):
			connection_lost.emit()
		_connected = false
	pass
