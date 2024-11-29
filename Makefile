APP_NAME = DisplayLayout
APP_BUNDLE = $(APP_NAME).app
APP_EXECUTABLE = $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
SOURCES = main.swift AppDelegate.swift
FRAMEWORKS = -framework AppKit

.PHONY: all clean install check-deps install-deps

all: check-deps $(APP_BUNDLE)

check-deps:
	@which brew > /dev/null || (echo "Homebrew is required. Install from https://brew.sh/" && exit 1)
	@which displayplacer > /dev/null || make install-deps

install-deps:
	@echo "Installing displayplacer..."
	@brew install jakehilborn/jakehilborn/displayplacer

$(APP_BUNDLE): $(APP_EXECUTABLE) Info.plist
	@mkdir -p $(APP_BUNDLE)/Contents
	@cp Info.plist $(APP_BUNDLE)/Contents/

$(APP_EXECUTABLE): $(SOURCES)
	@mkdir -p $(dir $@)
	swiftc $(SOURCES) $(FRAMEWORKS) -o $@

Info.plist:
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $@
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $@
	@echo '<plist version="1.0"><dict>' >> $@
	@echo '    <key>CFBundleExecutable</key><string>$(APP_NAME)</string>' >> $@
	@echo '    <key>CFBundleIdentifier</key><string>com.local.$(APP_NAME)</string>' >> $@
	@echo '    <key>CFBundleName</key><string>$(APP_NAME)</string>' >> $@
	@echo '    <key>CFBundlePackageType</key><string>APPL</string>' >> $@
	@echo '    <key>LSMinimumSystemVersion</key><string>10.10</string>' >> $@
	@echo '    <key>LSUIElement</key><true/>' >> $@
	@echo '</dict></plist>' >> $@

install: check-deps $(APP_BUNDLE)
	@cp -r $(APP_BUNDLE) /Applications/
	@make install-script

install-script:
	@if [ ! -f ~/.bin/display-layout ]; then \
		mkdir -p ~/.bin && \
		cp display-layout.sh ~/.bin/display-layout && \
		chmod +x ~/.bin/display-layout; \
		echo "Script installed to ~/.bin/display-layout"; \
		echo "Add ~/.bin to your PATH by adding this line to ~/.zshrc:"; \
		echo "export PATH=\"\$$HOME/.bin:\$$PATH\""; \
	fi

clean:
	@rm -rf $(APP_BUNDLE) Info.plist

