//
//  SimpleHTTPResponse.m
//  TouchMe
//
//  Created by Alex P on 16/11/2007.
//  © 2007 __MyCompanyName__. All rights reserved.
//

#import "SimpleHTTPResponse.h"

static NSDateFormatter *dateFormatter = nil;

@implementation SimpleHTTPResponse {
	NSMutableDictionary *_data;
}

- (id)init { dateFormatter = dateFormatter ?: [NSDateFormatter.alloc initWithDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz" allowNaturalLanguage:YES];

  return self = super.init ?
  
  _data = @{  @"headers" :  @{ @"Content-type" : @"text/html",
                                       @"Date" : [dateFormatter stringFromDate:NSDate.date],
                                    @"Expires" : [dateFormatter stringFromDate:[NSDate.alloc initWithTimeIntervalSinceNow:10]],
                                     @"Server" : NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"] ?: @"SimpleHTTPd"}.mutableCopy,
              @"code"     : @200,
              @"content"  : NSData.data }.mutableCopy, self : nil;
}

- (void)addHeader:(NSString *)key withValue:(NSString *)value {

	[_data[@"headers"] setValue:value forKey:key];
}

- (NSDictionary *)headers {	return _data[@"headers"]; }

- (void)setContentType:(NSString *)mimeType
{
	[_data[@"headers"] setValue:[mimeType copy] forKey:@"Content-type"];
}

- (NSString *)contentType {

	return _data[@"headers"][@"Content-type"];
}

- (void)setResponseCode:(int)code
{
	_data[@"code"] = @(code);
}

- (int)responseCode
{
	return [_data[@"code"] intValue];
}

- (void)setContent:(NSData *)toData
{
	_data[@"content"] = toData;
}

- (void)setContentString:(NSString *)toString
{
	_data[@"content"] = [toString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
}

- (NSData *)content
{
	return _data[@"content"];
}

@end
