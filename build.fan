using build
using compiler

class Build : BuildPod {

	new make() {
		podName = "afBeanUtils"
		summary = "Utilities and software patterns commonly associated with data objects"
		version = Version("1.0.8")

		meta = [
			"pod.dis"		: "Bean Utils",
			"repo.internal"	: "true",
			"repo.tags"		: "system",
			"repo.public"	: "false"
		]

		depends = [
			"sys 1.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/`]
		resDirs = [`doc/`]
	}
}
