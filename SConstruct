#!/usr/bin/env python
import os
import sys

env = SConscript("external/godot-cpp/SConstruct")

# For the reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["manuka/source/"])
sources = Glob("manuka/source/*.cpp")

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "game/extensions/manuka/libgdmanuka.{}.{}.framework/libgdmanuka.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "game/extensions/manuka/libgdmanuka{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)