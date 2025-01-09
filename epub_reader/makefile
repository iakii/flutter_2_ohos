clean: 
		@echo "Cleaning flutter project..."
		@flutter clean

husky:
		@echo "Setting up husky..."
		@dart pub add --dev husky
		@dart run husky install
		@dart run husky add .husky/pre-commit "make format"

format:
		@echo "Formatting the code"
		@dart format lib/
		@dart run pubspec_dependency_sorter
		@dart run import_sorter:main lib/

get: ## Get pub packages.
		@flutter pub get

version: ## Get pub packages.
		@flutter doctor -v

runner: 
		@echo "build_runner..."
		@dart run build_runner watch  --use-polling-watcher --delete-conflicting-outputs

window-release: 
		@dart pub global activate flutter_distributor
		@echo "Build Windows platform..."
		@flutter_distributor package --platform windows --targets exe --skip-clean

linux-deb: 
		@echo "Build Linux deb platform..."
		@flutter_distributor package --platform linux --targets deb --skip-clean

android-release: 
		@echo "Build Android platform..."
		@flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi

gen-go:
		@echo "gen the code"
		@dart run bindgo:run --config bindgo.yaml
		@dart run ffigen --config webrtc_ffi_config.yaml
		@dart run ffigen --config webdav_ffi_config.yaml

gen-rust:
		@echo "gen rust bridge code"
		@flutter_rust_bridge_codegen generate

 
 

android-env:
		@rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android

macos-release:
		@flutter_distributor package --platform macos --targets dmg --skip-clean