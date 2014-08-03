//
//  ViewController.m
//  YYGeoIP
//
//  Created by Yuan-Yi Chang on 2014/8/3.
//  Copyright (c) 2014年 Yuan-Yi Chang. All rights reserved.
//

#import "ViewController.h"
#import "YYGeoIPSDK.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /*
    NSLog(@"out: %@", [YYGeoIPSDK query_ipinfo_io]);
    NSLog(@"out: %@", [YYGeoIPSDK query_www_geoplugin_net]);
    NSLog(@"out: %@", [YYGeoIPSDK query_ip_api_com]);
     */
    [YYGeoIPSDK asyncQuery:^(NSDictionary *ret) {
        NSLog(@"ret: %@", ret);
    }];
    
}


@end
