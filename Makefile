TARGET = iphone:latest:7.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MetroLockScreen
MetroLockScreen_FILES = iOS9.x iOS10.x iOS11.x iOS13.x WiFi.x Telephony.x Telephony12.x Telephony13.x Notifications.x ColorFlowSupport.x BulletinServer.x NowPlaying14.x $(wildcard *.m)
MetroLockScreen_FILES += ForceBinds.x
MetroLockScreen_FRAMEWORKS = UIKit CoreGraphics QuartzCore IOKit
MetroLockScreen_CFLAGS = -fobjc-arc -Iinclude -include sha1.pch -include DRM.pch -std=gnu11
#MetroLockScreen_CFLAGS = -fobjc-arc -include DRM-stub.pch
#MetroLockScreen_OBJ_FILES = libcrypto.a
#MetroLockScreen_USE_SUBSTRATE=0

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += metrolockscreensettings
include $(THEOS_MAKE_PATH)/aggregate.mk
