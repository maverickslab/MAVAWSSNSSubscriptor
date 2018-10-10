//
//  MAVAWSSNSSubscriptorManager.h
//  MAVAWSSNSSubscriptor
//
//  Created by Mavericks's iOS Dev on 10/10/18.
//  Copyright © 2018 Mavericks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSSNS/AWSSNS.h>

NS_ASSUME_NONNULL_BEGIN
@class MAVAWSSNSSubscriptorConfiguration;
@interface MAVAWSSNSSubscriptorManager : NSObject

//AWS's configuration
@property (readwrite) MAVAWSSNSSubscriptorConfiguration* configuration;

//Singleton
+(id)shared;

//AWS's sns client
-(AWSSNS*)sns;

//Create AWS's Platform Endpoint
-(void)createPlatformEndpoint: (NSString*)deviceTokenString;

//AWS Suscribe to topic
//Topic arn: Topic arn (e.g arn:aws:sns:us-east-1:229502401976:{userID})
//Topic name: Name of topic (e.g userID)
-(void)subscribeToTopic:(NSString*)topicArn topicName:(NSString*)name;

// AWS Unsubscribe topic
// Topic arn: Topic arn (e.g arn:aws:sns:us-east-1:229502401976:{userID})
-(void)unsubscribeDeviceFromTopic:(NSString*)topicArn;


@end

NS_ASSUME_NONNULL_END
