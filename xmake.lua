set_exceptions "cxx"
set_encodings "utf-8"

--- However, by default, the Microsoft Visual C++ compiler does not 
--- always report the correct value for the __cplusplus macro. 
--- eg: C++20: __cplusplus is 202002L
--- To make the compiler report the correct value, you can use 
--- the /Zc:__cplusplus flag.
set_languages "c++20"
add_cxxflags("cl::/Zc:__cplusplus")

--- The /bigobj flag increases the number of sections that an object file 
--- can contain. This is useful when you have very large source files that 
--- result in a large number of sections, which can exceed the default limit.
--- This flag is often necessary when dealing with large templates or
--- heavily templated code in C++.
add_cxxflags("/bigobj")

--- The /FS flag enables file sharing mode, allowing multiple compiler processes
--- to write to the same .PDB file simultaneously.
add_cxxflags("/FS")

add_cxxflags(
	"/W4", --- warning level 4, like -Wall in gcc
	"/analyze",  --- msvc static code analysis support 
	"/permissive-",  --- enforce strict standard conformance
	"/sdl",  --- enable additional security features
	"/external:anglebrackets", --- treat all headers files included in <> as external code
 	"/analyze:external-", --- didn't analyze external code
 {force = true} )
set_policy("build.warning", true)

if is_mode("release") then 
	--- generate PDB
	add_cxxflags("/Zi")      
	add_ldflags("/DEBUG")    
	--add_cxxflags("/O2")
else 
	add_cxxflags("/Zi")      
	add_ldflags("/DEBUG") 
	add_cxxflags("/Od", --- -O0 in gcc
	 "/RTC1" --- enable basic run-time checks, this cannot be set in release mode
	 )
end

set_config("pkg_searchdirs", "$(env PROJECTS_PATH)/../.xmake_pkgs")
set_config("vcpkg", "$(env PROJECTS_PATH)/vcpkg")

add_rules("mode.debug", "mode.release")
add_rules("mode.profile", "mode.coverage", "mode.asan", "mode.tsan", "mode.lsan", "mode.ubsan")
add_rules("plugin.compile_commands.autoupdate", { outputdir = "build", lsp = "clangd" })
add_rules("utils.install.pkgconfig_importfiles")
add_rules("utils.install.cmake_importfiles")
add_runenvs("PATH", "$(projectdir)/bin")

includes("cc-common/xmake.lua")
add_includedirs("$(buildir)", "cc-common")

add_requireconfs("*", { debug = is_mode("debug") })

add_requires("spdlog", { alias = "spdlog", configs = { header_only = true }, debug = is_mode("debug") })
add_requires("fmt", { alias = "fmt", configs = { header_only = true }, debug = is_mode("debug") })
add_requires("conan::quickfix/1.15.1", { alias = "quickfix", configs = { defines = { "HAVE_SSL=ON" } }, debug = is_mode("debug") })
add_requires("conan::boost/1.85.0", { alias = "boost", configs = { debug = is_mode("debug") } })
add_requires("conan::nlohmann_json/3.12.0", { alias = "nlohmann_json", configs = { debug = is_mode("debug") } })
--Note: To avoid add multi version of protobuf, so we have better to set the version of protobuf as same as the version of protobuf required by the grpc/1.67.1 
add_requires("conan::protobuf/5.27.0", { alias = "protobuf", configs = { debug = is_mode("debug") } })
--benchmark/1.9.4: Invalid: Current cppstd (14) is lower than the required C++ standard (17).
add_requires("conan::benchmark/1.9.4", { alias = "benchmark", configs = { debug = is_mode("debug"), settings = {"compiler.cppstd=20"},
        settings_build = {'compiler.cppstd=20'} } })


add_defines("HAVE_STD_UNIQUE_PTR", --- if not define this quickfix will use std::auto_ptr which has been deprecated in c++17, cannot compile under cpp20
	"HAVE_SSL"                     --- invoke SSL support of quickfix
	, "_UNICODE", "UNICODE", "NOMINMAX", "BOOST_ASIO_HAS_STD_COROUTINE",
	"SPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_TRACE", "SPDLOG_WCHAR_TO_UTF8_SUPPORT", "WIN32_LEAN_AND_MEAN"
)

add_packages("quickfix", "spdlog", "fmt", "boost", "nlohmann_json", "protobuf", "benchmark")

local main_target_name = "generate_config"
target(main_target_name)
	add_defines("VERSION_MAJOR=1", "VERSION_MINOR=2", "VERSION_ALTER=0")
	add_files("src/*.cpp", "src/generated/*.cc")
	remove_files("src/load_config_main.cpp")
	add_includedirs("src")
	add_includedirs("src/generated")
	set_kind("binary")
	add_deps("cc-common")

local sub_target_name = "load_config"
target(sub_target_name)
	add_defines("VERSION_MAJOR=1", "VERSION_MINOR=2", "VERSION_ALTER=0")
	add_files("src/*.cpp", "src/generated/*.cc")
	remove_files("src/generate_config_main.cpp")
	add_includedirs("src")
	add_includedirs("src/generated")
	set_kind("binary")
	add_deps("cc-common")

local benchmark_target_name = "benchmark"
target(benchmark_target_name)
	--We dont need output spglog when benchmark is running, so we turn off all the spdlog.
	add_defines("SPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_OFF")
	add_defines("VERSION_MAJOR=1", "VERSION_MINOR=2", "VERSION_ALTER=0")
	add_files("src/*.cpp", "src/generated/*.cc")
	remove_files("src/load_config_main.cpp","src/generate_config_main.cpp")
	add_files("benchmarks/*.cpp")
	add_includedirs("src")
	add_includedirs("src/generated")
	set_kind("binary")
	add_deps("cc-common")

after_build(function(target)
	import("core.project.task")
	task.run("uber_pkg", { archive = false })
end)

task("uber_pkg")
on_run(function()
	import("core.project.project")
	import("core.project.config")
	import("utils.archive")
	import("core.base.option")

	config.load()

	local target = project.target(main_target_name)

	local list = { vformat(path.join("$(projectdir)", target:targetdir(), "*")),
		vformat("$(projectdir)/bin/*"),
		vformat("$(env WINDIR)/system32/msvcp140_atomic_wait.dll")
	}

	if option.get("archive") then
		local to = format("%s/%s-%s-v%s.zip", config.buildir(), target:name(), config.arch(), target:version())
		print("archive files", list, "to", to)
		archive.archive(to, list, { recurse = false, verbose = true })
	else
		local to = path.join(target:targetdir())
		for i, f in ipairs(list) do
			if i > 1 then
				print("copy", f, "to", to)
				os.cp(f, to)
			end
		end
	end
end)


