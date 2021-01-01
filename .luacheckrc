stds.luvit = {
   globals = {"process"}
}

stds.tests = {
   globals = {"toast"}
}

ignore = {
   "631", "211", "241"
}

std = "max+luvit"

excluded_files = {"**/deps/**/*.lua"}

files["**/spec/**/*_spec.lua"].std = "max+tests+busted"
files["**/testRunner.lua"].ignore = {"143", "122"}
files["**/util/doc/docgen.lua"].ignore = {"113"}
files["**/types/*.lua"].ignore = {"212", "631", "241", "614", "211"}