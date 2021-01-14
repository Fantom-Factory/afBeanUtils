using build

class Build : BuildPod {

	new make() {
		podName = "afBeanUtils"
		summary = "Utilities and software patterns commonly associated with data objects"
		version = Version("1.0.13")

		meta 	= [
			"pod.dis"		: "Bean Utils",
			"repo.internal"	: "true",
			"repo.tags"		: "system",
			"repo.public"	: "true",

			// ---- SkySpark ----
			"ext.name"		: "afBeanUtils",
			"ext.icon"		: "afBeanUtils",
//			"ext.depends"	: "",
			"skyarc.icons"	: "true",
		]

		index	= ["skyarc.ext" : "afBeanUtils"]

		depends = [
			"sys 1.0.68 - 1.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/`]
		resDirs = [`doc/`, `svg/`]
	}
}
