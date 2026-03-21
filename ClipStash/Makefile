.PHONY: generate build clean run

# Generate Xcode project from project.yml (requires xcodegen: brew install xcodegen)
generate:
	xcodegen generate

# Build the app
build: generate
	xcodebuild -project ClipStash.xcodeproj \
		-scheme ClipStash \
		-configuration Release \
		-derivedDataPath build/ \
		build

# Build debug
debug: generate
	xcodebuild -project ClipStash.xcodeproj \
		-scheme ClipStash \
		-configuration Debug \
		-derivedDataPath build/ \
		build

# Clean build artifacts
clean:
	rm -rf build/
	rm -rf ClipStash.xcodeproj

# Run the built app
run:
	open build/Build/Products/Release/ClipStash.app
