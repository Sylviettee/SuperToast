stds.luvit = {
   globals = {"process"}
}

stds.tests = {
   globals = {"toast"}
}

std = "max+luvit"

ignore = {"2../_.*", "631"}

files["**/spec/**/*_spec.lua"].std = "max+tests+busted"
files["**/testRunner.lua"].ignore = {"143", "122"}
files["**/util/doc/docgen.lua"].ignore = {"113"}
files["**/types/*.lua"].ignore = {"212", "631", "241", "614", "211"}
