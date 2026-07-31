#import <Foundation/Foundation.h>
#import <netdb.h>
#import <substrate.h>

// 定义黑名单域名后缀列表
static NSArray<NSString *> *blockedSuffixes;

// 原 getaddrinfo 函数指针
static int (*orig_getaddrinfo)(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res);

// 替换后的 getaddrinfo 函数
static int my_getaddrinfo(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res) {
    if (hostname != NULL) {
        NSString *hostStr = [NSString stringWithUTF8String:hostname];
        if (hostStr) {
            hostStr = [hostStr lowercaseString];
            for (NSString *suffix in blockedSuffixes) {
                // 匹配完整域名或后缀匹配（例如 matching .admob.com 或者 admob.com）
                if ([hostStr isEqualToString:suffix] || [hostStr hasSuffix:[@"." stringByAppendingString:suffix]]) {
                    // 返回 EAI_NONAME 模拟 DNS 解析失败/主机不可达
                    return EAI_NONAME;
                }
            }
        }
    }
    // 非黑名单域名，放行调用原始函数
    return orig_getaddrinfo(hostname, servname, hints, res);
}

%ctor {
    @autoreleasepool {
        // 嘀嗒出行 去广告及隐私追踪黑名单列表
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

        // 使用 C/C++ 层 Hook 拦截底层 getaddrinfo API
        MSHookFunction((void *)getaddrinfo, (void *)my_getaddrinfo, (void **)&orig_getaddrinfo);
    }
}
