# android-example

## Environment

### Swift

1. Download and install the .pkg toolchain from https://www.swift.org/install
2. Get the SDK URL from https://github.com/swift-android-sdk/swift-android-sdk.git
3. The toolchain and SDK must be the same version (for development snapshots, the date and version must match)
4. Install the SDK with `swift sdk install`

### Android

1. Install sdkmanager: `brew install --cask android-commandlinetools`
2. Set up paths to commands:
   * `echo -n 'export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools\n' >> ~/.zshrc`
   * `echo -n 'export PATH=${ANDROID_HOME}/platform-tools:$PATH\n' >> ~/.zshrc`
   * `echo -n 'export PATH=${ANDROID_HOME}/emulator:$PATH\n' >> ~/.zshrc`
3. Install dependancies: `sdkmanager --install 'system-images;android-35;default;arm64-v8a' 'emulator' 'cmdline-tools;latest' 'build-tools;35.0.1' 'platforms;android-35' 'platform-tools' 'ndk;28.2.13676358'`
4. Create an emulator: `avdmanager create avd -n test -k 'system-images;android-35;default;arm64-v8a'` and launch `emulator -avd test`

### Configure

1. Set your SDK path at `<android-sdk>` and run script: `ANDROID_NDK_HOME=/opt/homebrew/share/android-commandlinetools/ndk/28.2.13676358 ~/Library/org.swift.swiftpm/swift-sdks/<android-sdk>.artifactbundle/swift-android/scripts/setup-android-sdk.sh`
2. Modify `makefile` arguments according to your preferences
3. Create a signing key with `make keystore`

### SPM to apk

1. Modify `build: aarch64` to `build: armv7 aarch64 x86_64` if you want to build all three architectures
2. Add missing dependencies to `LIBRARIES` if you want to use Foundation library, for example. You can identify missing dependencies by checking for dlopen errors in `adb logcat`
3. Finally, `make run` to build, archive, install, run and log application
