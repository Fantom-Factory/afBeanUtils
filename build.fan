using build
using compiler

class Build : BuildPod {

	new make() {
		podName = "afBeanUtils"
		summary = "Utilities and software patterns commonly associated with data objects"
		version = Version("1.0.4")

		meta = [
			"proj.name"		: "Bean Utils",
			"repo.internal"	: "true",
			"repo.tags"		: "system",
			"repo.public"	: "true"
		]

		depends = [
			"sys 1.0"
		]

		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`doc/`]
	}
}
