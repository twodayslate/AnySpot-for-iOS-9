THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222

include /opt/theos/makefiles/common.mk

TWEAK_NAME = AnySpot9
AnySpot9_FILES = Tweak.xm Testing.xm
AnySpot9_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += AnySpotPreferences

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += anyspotpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
