PROJECT_NAME := DrawOver
BUILD_DIR := $(CURDIR)/build
PROJECT_DIR := $(CURDIR)/src
BUILD_PREFIX := $(BUILD_DIR)/$(PROJECT_NAME)

GODOT_BIN := godot
GODOT_EXPORT := $(GODOT_BIN) $(PROJECT_DIR)/project.godot --no-window --export

all: win32 win64 linux32 linux64 osx

build-dir:
	mkdir -p $(BUILD_DIR)

# Build executables by export preset
%win32.exe: $(PROJECT_DIR)
	$(GODOT_EXPORT) "Windows x32" $@

%win64.exe: $(PROJECT_DIR)
	$(GODOT_EXPORT) "Windows x64" $@

%linux32.x86: $(PROJECT_DIR)
	$(GODOT_EXPORT) "Linux/X11 x32" $@

%linux64.x86_64: $(PROJECT_DIR)
	$(GODOT_EXPORT) "Linux/X11 x64" $@

%osx.zip: $(PROJECT_DIR)
	$(GODOT_EXPORT) "Mac OSX" $@

win32: build-dir $(BUILD_PREFIX)_win32.exe
win64: build-dir $(BUILD_PREFIX)_win64.exe
linux32: build-dir $(BUILD_PREFIX)_linux32.x86
linux64: build-dir $(BUILD_PREFIX)_linux64.x86_64
osx: build-dir $(BUILD_PREFIX)_osx.zip

# Zip the application
%.zip:
	zip $@ -j $(basename $@).*

zip-win32: win32 $(BUILD_PREFIX)_win32.zip
zip-win64: win64 $(BUILD_PREFIX)_win64.zip
zip-linux32: linux32 $(BUILD_PREFIX)_linux32.zip
zip-linux64: linux64 $(BUILD_PREFIX)_linux64.zip
zip-osx: osx  # osx already outputs a zip file

zip-all: zip-win32 zip-win64 zip-linux32 zip-linux64 zip-osx
