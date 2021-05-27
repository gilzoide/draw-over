PROJECT_NAME := DrawOver
BUILD_DIR := $(CURDIR)/build
PROJECT_DIR := $(CURDIR)/src
LOCALIZATIONS_DIR := $(PROJECT_DIR)/localizations
BUILD_PREFIX := $(BUILD_DIR)/$(PROJECT_NAME)
ADDITIONAL_FILES := $(BUILD_DIR)/README.txt $(BUILD_DIR)/LICENSE.txt $(BUILD_DIR)/LICENSE-3RD-PARTY.txt

GODOT := godot
GODOT_EXPORT := $(GODOT) $(PROJECT_DIR)/project.godot --no-window --export
BUTLER := butler
BUTLER_PROJECT := gilzoide/draw-over

all: win32 win64 linux32 linux64 osx

build-dir:
	@mkdir -p $(BUILD_DIR)

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

win32: $(BUILD_PREFIX)_win32.exe | build-dir
win64: $(BUILD_PREFIX)_win64.exe | build-dir
linux32: $(BUILD_PREFIX)_linux32.x86 | build-dir
linux64: $(BUILD_PREFIX)_linux64.x86_64 | build-dir
osx: $(BUILD_PREFIX)_osx.zip | build-dir

# Simplify README for bundling along the application
%README.txt: README.md
	sed -E -e 's/!?\[([^]]*)\]\([^)]*\)/\1/' $< > $@

%LICENSE.txt: LICENSE
	cp $< $@

%LICENSE-3RD-PARTY.txt: LICENSE-3RD-PARTY
	cp $< $@

# Zip the application
%.zip: $(ADDITIONAL_FILES)
	zip $@ -j $(basename $@).* $^

zip-win32: win32 $(BUILD_PREFIX)_win32.zip
zip-win64: win64 $(BUILD_PREFIX)_win64.zip
zip-linux32: linux32 $(BUILD_PREFIX)_linux32.zip
zip-linux64: linux64 $(BUILD_PREFIX)_linux64.zip
zip-osx: osx $(ADDITIONAL_FILES)  # osx already outputs a zip file
	zip $(BUILD_PREFIX)_osx.zip -j $(ADDITIONAL_FILES)
	zipnote $(BUILD_PREFIX)_osx.zip \
		| sed -e '/README.txt/a @=Draw Over.app/Contents/Resources/README.txt' \
		      -e '/LICENSE.txt/a @=Draw Over.app/Contents/Resources/LICENSE.txt' \
		      -e '/LICENSE-3RD-PARTY.txt/a @=Draw Over.app/Contents/Resources/LICENSE-3RD-PARTY.txt' \
		| zipnote -w $(BUILD_PREFIX)_osx.zip

zip-all: zip-win32 zip-win64 zip-linux32 zip-linux64 zip-osx


# Push to itch.io using butler
push-win32: zip-win32
	$(BUTLER) push $(BUILD_PREFIX)_win32.zip $(BUTLER_PROJECT):win32

push-win64: zip-win64
	$(BUTLER) push $(BUILD_PREFIX)_win64.zip $(BUTLER_PROJECT):win64

push-linux32: zip-linux32
	$(BUTLER) push $(BUILD_PREFIX)_linux32.zip $(BUTLER_PROJECT):linux32

push-linux64: zip-linux64
	$(BUTLER) push $(BUILD_PREFIX)_linux64.zip $(BUTLER_PROJECT):linux64

push-osx: zip-osx
	$(BUTLER) push $(BUILD_PREFIX)_osx.zip $(BUTLER_PROJECT):osx

push-all: push-win32 push-win64 push-linux32 push-linux64 push-osx


# Extract localizations
extract-localizations:
	pybabel extract -F $(LOCALIZATIONS_DIR)/pybabelrc -k text -k tr -k hint_tooltip -o $(LOCALIZATIONS_DIR)/messages.pot $(PROJECT_DIR)
	pybabel update -i $(LOCALIZATIONS_DIR)/messages.pot -l pt -o $(LOCALIZATIONS_DIR)/pt.po
