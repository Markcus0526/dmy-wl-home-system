/*
    File:       GetController.h
*/

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface GetController : NSObject {
}

@property (nonatomic, strong, readwrite) NSString *contentType;
@property (nonatomic, strong, readwrite) NSString *urlPath;
@property (nonatomic, strong, readwrite) NSDictionary *params;
@property (nonatomic, strong, readwrite) NSMutableData *serverData;


- (void)initialize;
- (void)startReceive;

@end
