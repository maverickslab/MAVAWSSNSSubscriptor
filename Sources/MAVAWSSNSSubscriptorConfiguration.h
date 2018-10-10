//
//  MAVAWSSNSSubscriptorConfiguration.h
//  MAVAWSSNSSubscriptor
//
//  Created by Mavericks's iOS Dev on 10/10/18.
//  Copyright © 2018 Mavericks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSSNS/AWSSNS.h>

NS_ASSUME_NONNULL_BEGIN

@interface MAVAWSSNSSubscriptorConfiguration : NSObject

//AWS's secret key (IAM)
@property (readwrite) NSString* secretKey;

//AWS's access key (IAM)
@property (readwrite) NSString* accessKey;

//App key (your app name) e.g 'Kidsbook'
@property (readwrite) NSString* appKey;

//AWS's region type
@property (readwrite) AWSRegionType region;

//AWS's platform endpoint
@property (readwrite) NSString* awsPlatformEndpoint;

-(instancetype)init: (NSString*)secret accessKey: (NSString*)access;

@end

NS_ASSUME_NONNULL_END
