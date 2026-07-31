#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <netdb.h>
#import "fishhook.h"

// ==================== 1. 域名拦截部分 ====================

static NSArray<NSString *> *blockedSuffixes;
static int (*orig_getaddrinfo)(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res);

static int my_getaddrinfo(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res) {
    if (hostname != NULL) {
        @autoreleasepool {
            NSString *hostStr = [NSString stringWithUTF8String:hostname];
            if (hostStr) {
                hostStr = [hostStr lowercaseString];
                for (NSString *suffix in blockedSuffixes) {
                    if ([hostStr isEqualToString:suffix] || [hostStr hasSuffix:[@"." stringByAppendingString:suffix]]) {
                        return EAI_NONAME;
                    }
                }
            }
        }
    }
    return orig_getaddrinfo(hostname, servname, hints, res);
}

// ==================== 2. 广告弹窗视图拦截 (OC Hook) ====================

// 2.1 强行禁止广告 Controller 弹出 Presentation
%hook UIViewController

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    NSString *className = NSStringFromClass([viewControllerToPresent class]);
    
    // 常见的广告 SDK 视图控制器前缀
    if ([className containsString:@"BUNative"] ||      // 穿山甲 Pangle
        [className containsString:@"BUAd"] ||          // 穿山甲 Pangle
        [className containsString:@"BUSplash"] ||      // 穿山甲开屏
        [className containsString:@"BUExpress"] ||     // 穿山甲模板
        [className containsString:@"GDT"] ||           // 广点通/优量汇
        [className containsString:@"BaiduMobAd"] ||    // 百度广告
        [className containsString:@"KSAd"] ||          // 快手广告
        [className containsString:@"Atmos"] ||         // AnyThink/TopOn
        [className containsString:@"ADJ"] ||           // Adjust
        [className containsString:@"AdViewController"]) {
        
        // 直接丢弃，不弹出广告
        if (completion) {
            completion();
        }
        return;
    }
    
    %orig(viewControllerToPresent, flag, completion);
}

%end

// 2.2 Hook 穿山甲 (Pangle) 广告请求与展示（截图中样式的典型来源）
%hook BUNativeExpressInterstitialAd
- (BOOL)isAdValid { return NO; }
- (void)showAdFromRootViewController:(id)arg1 { return; }
%end

%hook BUNativeExpressFullscreenVideoAd
- (BOOL)isAdValid { return NO; }
- (void)showAdFromRootViewController:(id)arg1 { return; }
%end

// 2.3 Hook 腾讯优量汇 (GDT) 插屏/视频广告
%hook GDTUnifiedInterstitialAd
- (BOOL)isAdValid { return NO; }
- (void)presentAdFromRootViewController:(id)arg1 { return; }
%end

// ==================== 3. 初始化构造器 ====================

%ctor {
    @autoreleasepool {
        blockedSuffixes = @[
            @"admob.com",
            @"adservice.google.com",
            @"als.baidu.com",
            @"anythinktech.com",
            @"applovin.com",
            @"applvn.com",
            @"byteoversea.com",
            @"gdt.qq.com",
            @"gifshow.com",
            @"googleads.g.doubleclick.net",
            @"hm.baidu.com",
            @"inmobi.com",
            @"ironsrc.com",
            @"is.com",
            @"ksapisrv.com",
            @"kuaishou.com",
            @"mi.gdt.qq.com",
            @"mobads.baidu.com",
            @"pagead2.googlesyndication.com",
            @"pangle.io",
            @"pangolin-sdk-toutiao.com",
            @"qzs.qq.com",
            @"sentry.io",
            @"snssdk.com",
            @"supersonicads.com",
            @"toponad.com",
            @"umeng.com",
            @"umengacs.m.taobao.com",
            @"umengcloud.com"
        ];

        struct rebinding getaddrinfo_rebinding = {
            "getaddrinfo",
            (void *)my_getaddrinfo,
            (void **)&orig_getaddrinfo
        };
        struct rebinding rebindings[] = { getaddrinfo_rebinding };
        rebind_symbols(rebindings, 1);
    }
}
