# 针对移动设备架构配置
TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = com.didapinche.taxi

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AntiDiDaAD

AntiDiDaAD_FILES = Tweak.xm
AntiDiDaAD_CFLAGS = -fobjc-arc
# 关键：链接 Theos 内置的 fishhook 库
AntiDiDaAD_LIBRARIES = fishhook

include $(THEOS_MAKE_PATH)/tweak.mk
