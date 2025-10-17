.PHONY: push launch armv7 aarch64 x86_64 build manifest bundle compress sign keystore install uninstall log

CONFIGURATION ?= release
TARGET ?= Application
ARCHIVE ?= .build/archive
TEMPORARY := .tmp
TEMPLATE = template.xml
SOURCES = .
RESOURCES = Resources
JAVA = Sources/Activity
ACTIVITY = local.app.Activity
#FOUNDATION = 1

#total apk size is 7.4mb without Foundation
LIBRARIES = swiftCore swift_Concurrency swift_StringProcessing swift_RegexParser swift_Builtin_float swift_math swiftAndroid dispatch BlocksRuntime swiftDispatch swiftSynchronization swiftRegexBuilder swiftCxx swiftCxxStdlib swiftDistributed swiftObservation swift_Differentiation

#total apk size is 36.5mb with Foundation
ifeq ($(FOUNDATION), 1)
LIBRARIES += Foundation FoundationEssentials FoundationInternationalization _FoundationICU FoundationNetworking FoundationXML
endif

ifndef JAVA
hasCode=false
ifndef ACTIVITY
ACTIVITY = android.app.NativeActivity
endif
else
hasCode=true
endif

APK ?= result.apk
PACKAGE ?= org.company.app

ANDROIDVERSION ?= 27
ANDROIDTARGET ?= 35

ASSETS = document.txt
IMAGES = icon.png
VALUES = values.xml

KEYSTORE := release-key.keystore
ALIAS ?= standkey
PASSWORD ?= password
DOMAIN := "CN=example.com, OU=ID, O=Example, L=Doe, S=John, C=GB"

ANDROIDSDK ?= /opt/homebrew/share/android-commandlinetools
ANDROIDNDK ?= $(firstword $(wildcard $(ANDROIDSDK)/ndk/*) )
ANDROIDJAR := $(ANDROIDSDK)/platforms/android-$(ANDROIDTARGET)/android.jar
BUILD_TOOLS ?= $(lastword $(wildcard $(ANDROIDSDK)/build-tools/*) )
AAPT ?= $(BUILD_TOOLS)/aapt
ADB ?= adb

# Swift toolcahin
TOOLCHAIN_PATH := $(HOME)/Library/Developer/Toolchains/swift-latest.xctoolchain
TOOLCHAIN_PLIST := $(TOOLCHAIN_PATH)/Info.plist

ifeq ($(TOOLCHAINS),)
$(warning TOOLCHAINS is not set, trying to extract latest from $(TOOLCHAIN_PATH))

ifeq ($(wildcard $(TOOLCHAIN_PATH)),)
$(error Toolchain not found at $(TOOLCHAIN_PATH))
endif

ifeq ($(wildcard $(TOOLCHAIN_PLIST)),)
$(error Info.plist not found in toolchain at $(TOOLCHAIN_PLIST))
endif

TOOLCHAIN_NAME := $(shell plutil -extract ShortDisplayName raw "$(TOOLCHAIN_PLIST)" 2>/dev/null)
TOOLCHAINS := $(shell plutil -extract CFBundleIdentifier raw "$(TOOLCHAIN_PLIST)" 2>/dev/null)

ifeq ($(TOOLCHAIN_NAME),)
$(error Failed to extract ShortDisplayName from $(TOOLCHAIN_PLIST))
endif

ifeq ($(TOOLCHAINS),)
$(error Failed to extract CFBundleIdentifier from $(TOOLCHAIN_PLIST))
endif

$(warning Using $(TOOLCHAIN_NAME))

endif
# Swift toolcahin

# Swift sdk
SDKS_PATH := $(HOME)/Library/org.swift.swiftpm/swift-sdks

ifeq ($(SDK),)
$(warning SDK is not set, trying to extract latest from $(SDKS_PATH))

ANDROID_BUNDLES := $(wildcard $(SDKS_PATH)/swift-*-android-*.artifactbundle)

ifneq ($(ANDROID_BUNDLES),)
SDK := $(shell echo "$(ANDROID_BUNDLES)" | tr ' ' '\n' | grep -E 'swift-[0-9.]+.*android' | sort -Vr | head -n 1)

ifneq ($(SDK),)
$(warning Found Android SDK: $(SDK))
else
$(warning $(ANDROID_BUNDLES))
$(error No Android SDK bundles found in $(SDKS_PATH))
endif

else
$(error No SDKs found in $(SDKS_PATH))
endif

endif
# Swift sdk

export TOOLCHAINS

define compile
swift build -c $(CONFIGURATION) --package-path $(SOURCES) --swift-sdk $(1)
mkdir -p $(ARCHIVE)/lib/$(2)
cp .build/$(CONFIGURATION)/lib$(TARGET).so $(ARCHIVE)/lib/$(2)/libmain.so
cp $(ANDROIDNDK)/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/$(3)/libc++_shared.so $(ARCHIVE)/lib/$(2)/libc++_shared.so
$(foreach library,$(LIBRARIES), cp $(SDK)/swift-android/swift-resources/usr/lib/$(4)/android/lib$(library).so $(ARCHIVE)/lib/$(2)/lib$(library).so;)
endef

armv7:
	$(call compile,armv7-unknown-linux-android28,armeabi-v7a,arm-linux-androideabi,swift-armv7)

aarch64:
	$(call compile,aarch64-unknown-linux-android28,arm64-v8a,aarch64-linux-android,swift-aarch64)
	
x86_64:
	$(call compile,x86_64-unknown-linux-android28,x86_64,x86_64-linux-android,swift-x86_64)

build: aarch64

manifest:
	mkdir -p $(TEMPORARY)
	package=$(PACKAGE) minSdkVersion=$(ANDROIDVERSION) targetSdkVersion=$(ANDROIDTARGET) hasCode=$(hasCode) activity=$(ACTIVITY) library=main entry=android_main \
	envsubst '$$package $$minSdkVersion $$targetSdkVersion $$hasCode $$activity $$library $$entry' < $(TEMPLATE) > $(TEMPORARY)/AndroidManifest.xml

bundle:
	mkdir -p $(ARCHIVE)/assets
	$(foreach asset,$(ASSETS),cp $(RESOURCES)/$(asset) $(ARCHIVE)/assets/$(asset);)
	
	mkdir -p $(TEMPORARY)/res/mipmap
	$(foreach image,$(IMAGES),cp $(RESOURCES)/$(image) $(TEMPORARY)/res/mipmap/$(image);)
	
	mkdir -p $(TEMPORARY)/res/values
	$(foreach value,$(VALUES),cp $(RESOURCES)/$(value) $(TEMPORARY)/res/values/$(value);)
	
ifdef JAVA
	mkdir -p $(TEMPORARY)/java
	javac -d $(TEMPORARY)/java -cp $(ANDROIDJAR) $(JAVA)/*.java
	$(BUILD_TOOLS)/d8 --lib $(ANDROIDJAR) --min-api $(ANDROIDVERSION) $(TEMPORARY)/java/local/app/*.class --output $(ARCHIVE)
endif

compress:
	$(AAPT) package -f -F $(TEMPORARY)/processed.apk -I $(ANDROIDJAR) -M $(TEMPORARY)/AndroidManifest.xml -S $(TEMPORARY)/res -A $(ARCHIVE)/assets

	unzip -o $(TEMPORARY)/processed.apk -d $(ARCHIVE)

	rm -rf $(TEMPORARY)

	cd $(ARCHIVE) && zip -D9r processed.apk . && zip -D0r processed.apk ./resources.arsc ./AndroidManifest.xml

	rm -rf $(APK)

	$(BUILD_TOOLS)/zipalign -v 4 $(ARCHIVE)/processed.apk $(APK)

sign:
	$(BUILD_TOOLS)/apksigner sign --key-pass pass:$(PASSWORD) --ks-pass pass:$(PASSWORD) --ks .android/$(KEYSTORE) $(APK)

keystore:
	mkdir -p .android
	keytool -genkey -v -keystore .android/$(KEYSTORE) -alias $(ALIAS) -keyalg RSA -keysize 2048 -validity 365 -storepass $(PASSWORD) -keypass $(PASSWORD) -dname $(DOMAIN)

install:
	$(ADB) install -r $(APK)

uninstall:
	$(ADB) uninstall $(PACKAGE)

launch:
	$(ADB) shell am start -W -n $(PACKAGE)/$(ACTIVITY)

log:
	$(eval PID:=$(shell $(ADB) shell pidof -s $(PACKAGE) || echo ""))
	@echo $(PID)
	$(if $(PID),$(ADB) logcat --pid=$(PID),$(ADB) logcat | grep $(PACKAGE))

archive: build manifest bundle compress sign

run: archive install launch log
