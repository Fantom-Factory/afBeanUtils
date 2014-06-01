using build

class Build : BuildPod {

	new make() {
		podName = "afBeanUtils"
		summary = "(Internal) "
		version = Version("0.0.1")

		meta = [
			"proj.name"		: "Bean Utils",
			"tags"			: "system",
			"repo.private"	: "true"
		]

		depends = [
			"sys 1.0"
		]
		
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
	}
}
