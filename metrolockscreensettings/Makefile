TARGET=iphone:clang:11.2:8.0
ARCHS=armv7 arm64 arm64e
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MetroLockScreenSettings
MetroLockScreenSettings_FILES = CSMLSRootListController.m CSMLSAdvancedSettingsController.m CSMetroLockScreenLogoCell.m
MetroLockScreenSettings_INSTALL_PATH = /Library/PreferenceBundles
MetroLockScreenSettings_FRAMEWORKS = UIKit
MetroLockScreenSettings_PRIVATE_FRAMEWORKS = Preferences
MetroLockScreenSettings_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MetroLockScreenSettings.plist$(ECHO_END)
