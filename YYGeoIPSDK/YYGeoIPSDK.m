//
//  YYGeoIPSDK.m
//  YYGeoIP
//
//  Created by Yuan-Yi Chang on 2014/8/3.
//  Copyright (c) 2014年 Yuan-Yi Chang. All rights reserved.
//

#import "YYGeoIPSDK.h"

#define YYGeoIP_KEY_INOUT       @"IN"
#define YYGeoIP_KEY_OUTUPT      @"OUT"

@implementation YYGeoIPSDK

+ (NSData *)query:(NSURL *)target
{
    NSURLResponse *response = nil;
    NSError * error = nil;
    NSData *data = nil;
    @try {
        data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:target] returningResponse:&response error:&error];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    if (error != nil)
        return nil;
    return data;
}

+ (id)parseJsonObj:(NSData *)data
{
    NSError *jsonError = nil;
    id jsonObject = nil;
    @try {
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    if (jsonError != nil)
        return nil;
    return jsonObject;
}

+ (NSDictionary *)query_base:(NSString *)url key:(NSArray *)keyMapArray
{
    //NSLog(@"query: %@", url);
    id jsonObject = [[self class] parseJsonObj:[[self class] query:[NSURL URLWithString:url]]];
    if (jsonObject) {
        NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
        //NSLog(@"jsonObject: %@", jsonObject);
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * json = (NSDictionary *)jsonObject;
            for (NSDictionary *key in keyMapArray )
                if (json[key[YYGeoIP_KEY_INOUT]])
                    output[key[YYGeoIP_KEY_OUTUPT]] = json[key[YYGeoIP_KEY_INOUT]];
            return output;
        }
    }
    return @{};
}

+ (NSDictionary *)query_www_geoplugin_net
{
    return [[self class] query_base:@"http://www.geoplugin.net/json.gp"
                                key:@[
                                      @{YYGeoIP_KEY_INOUT:@"geoplugin_city", YYGeoIP_KEY_OUTUPT:YYGeoIP_CITY},
                                      @{YYGeoIP_KEY_INOUT:@"geoplugin_countryCode", YYGeoIP_KEY_OUTUPT:YYGeoIP_COUNTRY_CODE},
                                      @{YYGeoIP_KEY_INOUT:@"geoplugin_request", YYGeoIP_KEY_OUTUPT:YYGeoIP_IP},
                                      @{YYGeoIP_KEY_INOUT:@"geoplugin_latitude", YYGeoIP_KEY_OUTUPT:YYGeoIP_LATITUDE},
                                      @{YYGeoIP_KEY_INOUT:@"geoplugin_longitude", YYGeoIP_KEY_OUTUPT:YYGeoIP_LONGITUDE},
                                      ]];
}

+ (NSDictionary *)query_ipinfo_io
{
    return [[self class] query_base:@"http://ipinfo.io/json"
                                key:@[
                                      @{YYGeoIP_KEY_INOUT:@"city", YYGeoIP_KEY_OUTUPT:YYGeoIP_CITY},
                                      @{YYGeoIP_KEY_INOUT:@"country", YYGeoIP_KEY_OUTUPT:YYGeoIP_COUNTRY_CODE},
                                      @{YYGeoIP_KEY_INOUT:@"ip", YYGeoIP_KEY_OUTUPT:YYGeoIP_IP},
                                      @{YYGeoIP_KEY_INOUT:@"loc", YYGeoIP_KEY_OUTUPT:YYGeoIP_LOCATION},
                                      ]];
}

+ (NSDictionary *)query_ip_api_com {
    return [[self class] query_base:@"http://ip-api.com/json"
                                key:@[
                                      @{YYGeoIP_KEY_INOUT:@"city", YYGeoIP_KEY_OUTUPT:YYGeoIP_CITY},
                                      @{YYGeoIP_KEY_INOUT:@"countryCode", YYGeoIP_KEY_OUTUPT:YYGeoIP_COUNTRY_CODE},
                                      @{YYGeoIP_KEY_INOUT:@"query", YYGeoIP_KEY_OUTUPT:YYGeoIP_IP},
                                      @{YYGeoIP_KEY_INOUT:@"lat", YYGeoIP_KEY_OUTUPT:YYGeoIP_LATITUDE},
                                      @{YYGeoIP_KEY_INOUT:@"lon", YYGeoIP_KEY_OUTUPT:YYGeoIP_LONGITUDE},
                                      ]];
}

+ (NSDictionary *)query
{
    switch (arc4random()%3) {
        case 0:
            return [[self class] query_ip_api_com];
        case 1:
            return [[self class] query_www_geoplugin_net];
        case 2:
            return [[self class] query_ipinfo_io];
    }
    return @{};
}

+ (void)asyncQuery:(void (^)(NSDictionary *ret))callback
{
    dispatch_async(dispatch_queue_create("ipquery", NULL), ^{
        if (callback) {
            callback([[self class] query]);
        }
    });
}

@end
