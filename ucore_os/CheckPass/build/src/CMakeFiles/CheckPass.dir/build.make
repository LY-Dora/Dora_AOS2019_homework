# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.5

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build

# Include any dependencies generated for this target.
include src/CMakeFiles/CheckPass.dir/depend.make

# Include the progress variables for this target.
include src/CMakeFiles/CheckPass.dir/progress.make

# Include the compile flags for this target's objects.
include src/CMakeFiles/CheckPass.dir/flags.make

src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o: src/CMakeFiles/CheckPass.dir/flags.make
src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o: ../src/CheckPass.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o"
	cd /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build/src && /usr/bin/c++   $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/CheckPass.dir/CheckPass.cpp.o -c /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/src/CheckPass.cpp

src/CMakeFiles/CheckPass.dir/CheckPass.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/CheckPass.dir/CheckPass.cpp.i"
	cd /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build/src && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/src/CheckPass.cpp > CMakeFiles/CheckPass.dir/CheckPass.cpp.i

src/CMakeFiles/CheckPass.dir/CheckPass.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/CheckPass.dir/CheckPass.cpp.s"
	cd /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build/src && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/src/CheckPass.cpp -o CMakeFiles/CheckPass.dir/CheckPass.cpp.s

src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o.requires:

.PHONY : src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o.requires

src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o.provides: src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o.requires
	$(MAKE) -f src/CMakeFiles/CheckPass.dir/build.make src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o.provides.build
.PHONY : src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o.provides

src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o.provides.build: src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o


# Object files for target CheckPass
CheckPass_OBJECTS = \
"CMakeFiles/CheckPass.dir/CheckPass.cpp.o"

# External object files for target CheckPass
CheckPass_EXTERNAL_OBJECTS =

src/libCheckPass.so: src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o
src/libCheckPass.so: src/CMakeFiles/CheckPass.dir/build.make
src/libCheckPass.so: src/CMakeFiles/CheckPass.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX shared module libCheckPass.so"
	cd /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build/src && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/CheckPass.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
src/CMakeFiles/CheckPass.dir/build: src/libCheckPass.so

.PHONY : src/CMakeFiles/CheckPass.dir/build

src/CMakeFiles/CheckPass.dir/requires: src/CMakeFiles/CheckPass.dir/CheckPass.cpp.o.requires

.PHONY : src/CMakeFiles/CheckPass.dir/requires

src/CMakeFiles/CheckPass.dir/clean:
	cd /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build/src && $(CMAKE_COMMAND) -P CMakeFiles/CheckPass.dir/cmake_clean.cmake
.PHONY : src/CMakeFiles/CheckPass.dir/clean

src/CMakeFiles/CheckPass.dir/depend:
	cd /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/src /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build/src /home/dora/Tsinghua_phd/AOS-project/ucore-new/CheckPass/build/src/CMakeFiles/CheckPass.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/CMakeFiles/CheckPass.dir/depend

