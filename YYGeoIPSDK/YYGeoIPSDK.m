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
    //NSLog(@"jsonObject: %@", jsonObject);
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

+ (NSDictionary *)queryGPSViaMapsWithLatitude:(float)latitude longitude:(float)longitude {
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    id ret = [[self class] parseJsonObj:[[self class] query:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", latitude, longitude]]]];
    
    NSString *country = nil, *county = nil, *city = nil, *postal_code = nil;
    if (ret && [ret isKindOfClass:[NSDictionary class]]) {
        NSDictionary *raw = (NSDictionary *)ret;
        if ([raw[@"status"] isEqualToString:@"OK"] && raw[@"results"]  && [raw[@"results"] isKindOfClass:[NSArray class]]) {
            for (id raw_item in raw[@"results"] ) {
                if ([raw_item isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *item = (NSDictionary *)raw_item;
                    if (item[@"address_components"] && [item[@"address_components"] isKindOfClass:[NSArray class]]) {
                        for (id raw_meta in item[@"address_components"]) {
                            if ([raw_meta isKindOfClass:[NSDictionary class]]) {
                                NSDictionary *meta = (NSDictionary *)raw_meta;
                                //NSLog(@"meta: %@", meta);
                                if (meta[@"types"] && [meta[@"types"] count] >= 2) {
                                    @try {
                                        if ([meta[@"types"][0] isEqualToString:@"country"]) {
                                            country = meta[@"short_name"];
                                        } else if ([meta[@"types"][0] isEqualToString:@"administrative_area_level_2"]) {
                                            county = meta[@"short_name"];
                                        } else if ([meta[@"types"][0] isEqualToString:@"administrative_area_level_3"]) {
                                            city = meta[@"short_name"];
                                        } else if ([meta[@"types"][0] isEqualToString:@"postal_code"]) {
                                            postal_code = meta[@"short_name"];
                                        }
                                    }
                                    @catch (NSException *exception) {
                                    }
                                    @finally {
                                    }
                                }
                            }
                        }
                    }
                }
                
                if (city && county && country) {

                    break;
                }
            }
        }
    }
    if (country)
        output[YYGeoIP_COUNTRY_CODE] = country;

    if (postal_code)
        output[YYGeoIP_POSTAL_CODE] = postal_code;
    if (city) {
        output[YYGeoIP_CITY] = city;
        output[YYGeoIP_LOCATION] = city;
    }
    if (county) {
        output[YYGeoIP_COUNTY] = county;
        output[YYGeoIP_LOCATION] = county; // use county first
    }
    output[YYGeoIP_LATITUDE] = [NSString stringWithFormat:@"%f", latitude];
    output[YYGeoIP_LONGITUDE] = [NSString stringWithFormat:@"%f", longitude];

    return output;
}

+ (NSDictionary *)queryGPSWithLatitude:(float)latitude longitude:(float)longitude
{
    switch (arc4random()%1) {
        case 0:
            return [[self class] queryGPSViaMapsWithLatitude:latitude longitude:longitude];
    }
    return @{};
}

+ (void)asyncQuery:(float)latitude longitude:(float)longitude callback:(void (^)(NSDictionary *ret))callback
{
    dispatch_async(dispatch_queue_create("gpsquery", NULL), ^{
        if (callback) {
            callback([[self class] queryGPSWithLatitude:latitude longitude:longitude]);
        }
    });
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
