TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = com.didapinche.taxi

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AntiDiDaAD

# 1. 这里加上 fishhook.c
AntiDiDaAD_FILES = Tweak.xm fishhook.c
AntiDiDaAD_CFLAGS = -fobjc-arc

# 2. 注意：绝对不要有 AntiDiDaAD_LIBRARIES = fishhook 这行！

include $(THEOS_MAKE_PATH)/tweak.mk
