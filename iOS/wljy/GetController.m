/*
    File:       GetController.m
*/

#import "GetController.h"
#import "NetworkManager.h"
#import "Constants.h"

//#import <sys/socket.h>
//#import <netinet/in.h>
//#import <SystemConfiguration/SystemConfiguration.h>
//#import "CommManager.h"
//#import "CommCompMgr.h"
//#import "Common.h"
//#import "SBJson.h"
//#import "ServiceMethod.h"
#import "AFHTTPClient.h"
//#import "AFJSONRequestOperation.h"
//#import "ServiceParams.h"
//#import "Common.h"


@implementation GetController

#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)initialize {
    self.urlPath = nil;
    self.params = nil;
    self.contentType = nil;
    self.serverData = nil;
}

- (void)receiveDidStart
{
    NSLog( @"Receiving");
    //[[NetworkManager sharedInstance] didStartNetworkOperation];
}

- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"succeeded";
    }
    NSLog(@"%@", statusString);
    
    //[[NetworkManager sharedInstance] didStopNetworkOperation];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:statusString, @"status", self.contentType, @"contentType", self.serverData, @"data", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:HConnectionCompleteNotification object:self userInfo:dictionary];    
}

#pragma mark * Core transfer code

- (void)startReceive
{    
    NSString *method = Server_Address;
    method = [method stringByAppendingString:@"phone/"];
    method = [method stringByAppendingString:self.urlPath];    
            
                
    [self receiveDidStart];
    self.serverData = [NSMutableData data];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[[NetworkManager sharedInstance] smartURLForString:Server_Address]];
    
    [httpClient getPath:method parameters:self.params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         //NSLog(@"Request Successful, response '%@'", responseStr);
         
         [self.serverData appendData:responseObject];
         [self receiveDidStopWithStatus:nil];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         //NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
         
         [self receiveDidStopWithStatus:error.localizedDescription];
     }];
}

@end
