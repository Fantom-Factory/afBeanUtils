using build

class Build : BuildPod {

	new make() {
		podName = "afBeanUtils"
		// TODO: make desc smaller!
		summary = "(Internal) A collection of utilities and software patterns commonly associated with data objects"
		version = Version("0.0.3")

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
