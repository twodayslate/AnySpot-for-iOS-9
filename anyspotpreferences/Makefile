TARGET=:clang
ARCHS = armv7 armv7s arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AnySpotPreferences
AnySpotPreferences_FILES = AnySpotRootListController.m AnySpotAdvancedListController.m
AnySpotPreferences_INSTALL_PATH = /Library/PreferenceBundles
AnySpotPreferences_FRAMEWORKS = UIKit
AnySpotPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AnySpotPreferences.plist$(ECHO_END)
