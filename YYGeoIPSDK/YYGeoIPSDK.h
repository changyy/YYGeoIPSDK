//
//  YYGeoIPSDK.h
//  YYGeoIP
//
//  Created by Yuan-Yi Chang on 2014/8/3.
//  Copyright (c) 2014年 Yuan-Yi Chang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YYGeoIP_IP              @"ip"
#define YYGeoIP_COUNTRY_CODE    @"country"
#define YYGeoIP_CITY            @"city"
#define YYGeoIP_LONGITUDE       @"longitude"
#define YYGeoIP_LATITUDE        @"latitude"
#define YYGeoIP_LOCATION        @"location"

@interface YYGeoIPSDK : NSObject

+ (NSDictionary *)query;
+ (void)asyncQuery:(void (^)(NSDictionary *ret))callback;

+ (NSDictionary *)query_ipinfo_io;
+ (NSDictionary *)query_ip_api_com;
+ (NSDictionary *)query_www_geoplugin_net;

@end
