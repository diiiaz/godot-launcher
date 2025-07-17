extends BuildOptionbutton

var _project: Project


func setup(project: Project) -> void:
	_project = project
	update()


func update() -> void:
	super.update()
	
	if _project == null:
		return
	
	var projects_selected_builds: Dictionary = UserDataManager.get_user_data(UserData.USER_DATA.PROJECTS_SELECTED_BUILDS)
	
	if projects_selected_builds.has(_project.get_path().trim_suffix("/")):
		var index: int = 2
		for build: Build in BuildsManager.get_downloaded_builds():
			if build.get_path().get_file() == projects_selected_builds[_project.get_path().trim_suffix("/")]:
				select(index)
				selected_build.emit(build)
				return
			index += 1
