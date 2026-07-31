# 目标架构与 SDK 设定
TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

# 安装调试时的目标进程名称（嘀嗒出行）
INSTALL_TARGET_PROCESSES = com.didapinche.taxi

include $(THEOS)/makefiles/common.mk

# 插件名称设置为 AntiDiDaAD
TWEAK_NAME = AntiDiDaAD

AntiDiDaAD_FILES = Tweak.xm
AntiDiDaAD_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
