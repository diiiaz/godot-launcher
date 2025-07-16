extends Node

const TAGS_GROUP_NAME = "releases"

signal downloaded_build(build: Build)
signal uninstalled_build(build: Build)
signal updated

var _releases: Array[Release]
var _downloaded_builds: Array[Build]


func initialize() -> void:
	# WARNING: move this to the button to download the build, we don't want to update the whole releases.
	SettingsManager.updated.connect(func(setting: Settings.SETTING): if setting == Settings.SETTING.BUILDS_PATH: update_releases())
	update_releases()


func get_releases(tags_filter: PackedStringArray = [], string_filter: String = "", offset: int = 0) -> Array[Release]:
#func get_releases() -> Array[Release]:
	if _releases.is_empty():
		await update_releases()
	
	TagsManager.get_tags_group(BuildsManager.TAGS_GROUP_NAME).clear()
	for release in _releases:
		TagsManager.get_tags_group(BuildsManager.TAGS_GROUP_NAME).add_tags(release.get_tags())
	
	var releases: Array[Release] = _releases.duplicate(true)
	
	if not tags_filter.is_empty():
		releases = releases.filter(func(release: Release): return release.get_tags().any(func(tag_name: String): return tag_name in tags_filter))
	
	if not string_filter.is_empty():
		releases.assign(FuzzySearcher.mapped_search(string_filter, releases, func(release: Release): return Helper.strip_bbcode(release.get_formatted_name())))
	
	releases = releases.slice(offset, offset + SettingsManager.get_setting(Settings.SETTING.MAX_ITEMS_PER_PAGE))
	
	return releases


func get_releases_amount() -> int:
	if _releases.is_empty():
		await update_releases()
	return _releases.size()

func get_downloaded_builds() -> Array[Build]:
	return _downloaded_builds

func has_downloaded_builds() -> bool:
	return not _downloaded_builds.is_empty()
	#return DirAccess.get_files_at(SettingsManager.get_settings().builds_path).size() > 0


func update_releases(force_fetch_new_releases: bool = false) -> void:
	if not await ConnectionTester.is_connected_to_internet():
		return
	
	_downloaded_builds.clear()
	_releases.clear()
	for release_dict: Dictionary in await BuildsFetcher.fetch_or_load_releases(force_fetch_new_releases):
		var release: Release = Release.new() \
			.set_version(ReleaseHelper.get_version_from_release_dict(release_dict)) \
			.set_type(ReleaseHelper.get_type_from_release_dict(release_dict)) \
			.set_type_version(ReleaseHelper.get_type_version_from_release_dict(release_dict)) \
			.set_published_time(TimeHelper.convert_iso_to_unix_time(release_dict.published_at))
		
		for build_dict: Dictionary in release_dict.assets:
			var build: Build = Build.new(build_dict)
			release.add_build(build)
			build.downloaded.connect(
				func():
					_downloaded_builds.append(build)
					downloaded_build.emit(build))
			build.uninstalled.connect(
				func():
					_downloaded_builds.erase(build)
					uninstalled_build.emit(build))
			if build.is_downloaded():
				_downloaded_builds.append(build)
				downloaded_build.emit(build)
		
		_releases.append(release)
	updated.emit()


func check_for_new_releases() -> void:
	if await BuildsFetcher.has_new_release():
		await update_releases(true)
	else:
		ToastsManager.create_info_toast(TranslationServer.translate("TOAST_NO_NEW_RELEASES"))


func uninstall_build(build: Build) -> void:
	if not build.is_downloaded():
		return
	
	var err: Error = DirAccess.remove_absolute(build.get_path())
	if err != OK:
		ToastsManager.create_error_toast(error_string(err))
		return
	
	ToastsManager.create_info_toast(tr("SUCCESS_UNINSTALLED_BUILD") % [build.get_name()])
	build.uninstalled.emit()
