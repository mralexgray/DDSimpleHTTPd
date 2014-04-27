//
//  SimpleHTTPRequest.m
//  TouchMe
//
//  Created by Alex P on 16/11/2007.
//  © 2007 __MyCompanyName__. All rights reserved.
//

#import "SimpleHTTPRequest.h"
#import "SimpleHTTPConnection.h"

@implementation SimpleHTTPRequest { NSDictionary *data, *postVars, *getVars; }

- (id)initWithDictionary:(NSMutableDictionary *)dict
{
	if(self = [super init]) {
		data = dict;
		
		// if there was a body to the request, parse it like a query string
		if([self body] != nil) {
			postVars = [self processArgs:[[NSString alloc] initWithBytes:[[self body] bytes] length:[[self body] length] encoding:NSUTF8StringEncoding]];
		} else {
			postVars = @{};
		}
		
		// split "blah.html?key=value&key=value" into ["blah.html", "key=value&key=value"]
		NSArray *queryString = [[[self url] absoluteString] componentsSeparatedByString:@"?"];
		
		if([queryString count] == 2) {
			dict[@"url"] = [NSURL URLWithString:queryString[0]];
			getVars = [self processArgs:queryString[1]];
		} else {
			getVars = @{};
		}
		
		data = dict;
	}
	
	return self;
}

- (NSURL *)url
{
	return data[@"url"];
}

- (NSString *)method
{
	return data[@"method"];
}

- (NSDictionary *)headers
{
	return data[@"headers"];
}

- (NSString *)getHeader:(NSString *)byName;
{
	NSDictionary *headers = [self headers];
	
	if(headers != nil) {
		return headers[byName];
	}
	
	return nil;
}

- (NSData *)body
{
	return data[@"body"];
}

- (SimpleHTTPConnection *)connection
{
	return data[@"connection"];
}

- (NSDate *)date
{
	return data[@"date"];
}

- (NSString *)postVar:(NSString *)byName
{
	return postVars[byName];
}

- (NSString *)getVar:(NSString *)byName
{
	return getVars[byName];
}

#pragma mark -

- (NSDictionary *)processArgs:(NSString *)args
{
	NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
	NSArray *parts = [args componentsSeparatedByString:@"&"];
	NSEnumerator *enumerator = [parts objectEnumerator];
	NSString *keyValuePair;
	
	while(keyValuePair = [enumerator nextObject]) {
		NSArray *keyValueArray = [keyValuePair componentsSeparatedByString:@"="];
		
		if([keyValueArray count] == 2) {
			output[keyValueArray[0]] = keyValueArray[1];
		}
	}
	
	return output;
}

@end
