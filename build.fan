using build

class Build : BuildPod {

	new make() {
		podName = "afBeanUtils"
		summary = "Utilities and software patterns commonly associated with data objects"
		version = Version("0.0.4")

		meta = [
			"proj.name"		: "Bean Utils",
			"internal"		: "true",
			"tags"			: "system",
			"repo.private"	: "false"
		]

		depends = [
			"sys 1.0"
		]
		
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [,]
	}
}
