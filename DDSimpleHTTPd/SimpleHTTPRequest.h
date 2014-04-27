//
//  SimpleHTTPRequest.h
//  TouchMe
//
//  Created by Alex P on 16/11/2007.
//  © 2007 __MyCompanyName__. All rights reserved.

//  Refactored for new objC,ARC and ios/foundation.framework 24.5.13  © 2013 Dominik Pich

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@class SimpleHTTPConnection;

@interface SimpleHTTPRequest : NSObject

- (id) initWithDictionary:(NSMutableDictionary*)d;

@property (readonly)                NSURL * url;
@property (readonly)               NSData * body;
@property (readonly)               NSDate * date;
@property (readonly)             NSString * method;
@property (readonly)         NSDictionary * headers;
@property (readonly) SimpleHTTPConnection * connection;

- (NSString*) getHeader:(NSString*)byName;
- (NSString*)   postVar:(NSString*)byName;
- (NSString*)    getVar:(NSString*)byName;

@end
