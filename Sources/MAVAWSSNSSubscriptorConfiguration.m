//
//  MAVAWSSNSSubscriptorConfiguration.m
//  MAVAWSSNSSubscriptor
//
//  Created by Mavericks's iOS Dev on 10/10/18.
//  Copyright © 2018 Mavericks. All rights reserved.
//

#import "MAVAWSSNSSubscriptorConfiguration.h"

@implementation MAVAWSSNSSubscriptorConfiguration

-(instancetype)init:(NSString *)secret accessKey:(NSString *)access{
    if(self = [super init]){
        _secretKey = secret;
        _accessKey = access;
        _region = AWSRegionUSEast1;
        _appKey = @"default";
    }
    return self;
}

@end
