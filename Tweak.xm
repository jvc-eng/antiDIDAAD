#import <Foundation/Foundation.h>
#import <netdb.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <mach-o/nlist.h>

// ---------- fishhook 结构体声明 ----------
struct rebinding {
    const char *name;
    void *replacement;
    void **replaced;
};

#ifdef __cplusplus
extern "C" {
#endif
    int rebind_symbols(struct rebinding rebindings[], size_t rebindings_nel);
#ifdef __cplusplus
}
#endif
// ----------------------------------------

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
                        return EAI_NONAME; // 拦截域名解析
                    }
                }
            }
        }
    }
    return orig_getaddrinfo(hostname, servname, hints, res);
}

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

        // 使用 fishhook 重绑定 getaddrinfo 符号，兼容免越狱环境
        struct rebinding getaddrinfo_rebinding = {
            "getaddrinfo",
            (void *)my_getaddrinfo,
            (void **)&orig_getaddrinfo
        };
        struct rebinding rebindings[] = { getaddrinfo_rebinding };
        rebind_symbols(rebindings, 1);
    }
}
