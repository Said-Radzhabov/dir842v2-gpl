local deuteron_dir = io.popen("realpath ../../output/build/deuteron-*/teal_modules/src"):read("*line")

return {
	include_dir = {
		deuteron_dir,
		'fixup_profile',
	}
}
