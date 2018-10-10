//
//  MAVAWSSNSSubscriptorManager.m
//  MAVAWSSNSSubscriptor
//
//  Created by Mavericks's iOS Dev on 10/10/18.
//  Copyright © 2018 Mavericks. All rights reserved.
//

#import "MAVAWSSNSSubscriptorManager.h"
#import "MAVAWSSNSSubscriptorConfiguration.h"

@implementation MAVAWSSNSSubscriptorManager

//Singleton
+(id)shared{
    static MAVAWSSNSSubscriptorManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

//AWS's sns client
-(AWSSNS *)sns{
    NSAssert(self.configuration != nil, @"Configuration not been initialized");
    
    //init credentials provider
    AWSStaticCredentialsProvider* credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey: _configuration.accessKey secretKey: _configuration.secretKey];
    
    //aws service configuration
    AWSServiceConfiguration* configuration = [[AWSServiceConfiguration alloc] initWithRegion:_configuration.region credentialsProvider:credentialsProvider];
    
    //register sns service
    [AWSSNS registerSNSWithConfiguration:configuration forKey:_configuration.appKey];
    
    //return sns client
    AWSSNS* sns = [AWSSNS SNSForKey:_configuration.appKey];
    
    return sns;
}

//Create AWS's Platform Endpoint
-(void)createPlatformEndpoint:(NSString *)deviceTokenString{
    NSAssert(self.configuration != nil, @"Configuration not been initialized");

    //init sns client
    AWSSNS* sns = [self sns];
    
    //init request
    AWSSNSCreatePlatformEndpointInput* request = [[AWSSNSCreatePlatformEndpointInput alloc] init];
    request.token = deviceTokenString; // device token
    request.platformApplicationArn = _configuration.awsPlatformEndpoint; //platform endpoint
    
    //create endpoint
    [sns createPlatformEndpoint:request completionHandler:^(AWSSNSCreateEndpointResponse* _Nullable response, NSError* _Nullable error){
        
        if(error){
            NSLog(@"%@",error);
            return;
        }
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:response.endpointArn forKey:@"endpointArn"];
        [defaults synchronize];
    }];
}

//AWS Suscribe to topic
//Topic arn: Topic arn (e.g arn:aws:sns:us-east-1:229502401976:{userID})
//Topic name: Name of topic (e.g userID)
-(void)subscribeToTopic:(NSString *)topicArn topicName:(NSString *)name{
    NSAssert(self.configuration != nil, @"Configuration not been initialized");
    
    //init sns
    AWSSNS* sns = [self sns];
    
    //create topic input with name
    AWSSNSCreateTopicInput* createTopicInput = [[AWSSNSCreateTopicInput alloc] init];
    
    createTopicInput.name = name;
    
    [sns createTopic:createTopicInput];
    
    //aws's subscription input
    AWSSNSSubscribeInput* input = [[AWSSNSSubscribeInput alloc] init];
    input.topicArn = topicArn;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    //endpoint arn
    NSString* endpointArn = [defaults valueForKey:@"endpointArn"];
    input.endpoint = endpointArn;
    input.protocols = @"application";
    
    //subscribe
    [sns subscribe:input completionHandler:^(AWSSNSSubscribeResponse* _Nullable response, NSError* _Nullable error){
        if(error) NSLog(@"%@",error);
        NSLog(@"%@",response);
    }];
}

// AWS Unsubscribe topic
// Topic arn: Topic arn (e.g arn:aws:sns:us-east-1:229502401976:{userID})
-(void)unsubscribeDeviceFromTopic:(NSString *)topicArn{
    //find subscription by topic
    [self findSubscriptionARNByTopic:topicArn success:^(NSString* _Nonnull subscription){
        //init sns
        AWSSNS* sns = [self sns];
        
        //unsubscribe input
        AWSSNSUnsubscribeInput* unsubscribeInput = [[AWSSNSUnsubscribeInput alloc] init];
        unsubscribeInput.subscriptionArn = subscription;
        
        //unsubscribe that input
        [sns unsubscribe:unsubscribeInput completionHandler:^(NSError* _Nullable error){
            if(error) NSLog(@"%@",error);
        }];
    } failure:^(NSError* _Nullable error){
        NSLog(@"%@",error);
    }];
}
// Find Subscription ARN By Topic
// Topic arn: Topic arn (e.g arn:aws:sns:us-east-1:229502401976:{userID})
-(void)findSubscriptionARNByTopic: (NSString*)topicArn success:(void (^)(NSString * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    
    //list subscription with topic
    AWSSNSListSubscriptionsByTopicInput* listSubscriptionRequest = [[AWSSNSListSubscriptionsByTopicInput alloc] init];
    listSubscriptionRequest.topicArn = topicArn;
    
    //init sns
    AWSSNS* sns = [self sns];
    
    //list of subscriptions
    [sns listSubscriptionsByTopic:listSubscriptionRequest completionHandler:^(AWSSNSListSubscriptionsByTopicResponse* _Nullable response, NSError* _Nullable error){
        if(error){
            failure(error);
            return;
        }
        
        for (AWSSNSSubscription* subscription in response.subscriptions) {
            NSString* arn = [[NSUserDefaults standardUserDefaults] valueForKey:@"endpointArn"];
            if([subscription.endpoint isEqualToString:arn]){
                success(subscription.subscriptionArn);
                return;
            }
        }
    }];
}


@end
