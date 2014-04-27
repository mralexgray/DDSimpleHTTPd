//
//  SimpleHTTPServer.h
//
//  Created by Jürgen on 19.09.06.
//  © 2006 Cultured Code.
//  License: Creative Commons Attribution 2.5 License
//           http://creativecommons.org/licenses/by/2.5/
//
//  Refactored for new objC,ARC and ios/foundation.framework 24.5.13
//  © 2013 Dominik Pich
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@class SimpleHTTPConnection;
@class SimpleHTTPResponder;
@class SimpleHTTPRequest;

@interface SimpleHTTPServer : NSObject

- (id)initWithTCPPort:(NSUInteger)po
            responder:(SimpleHTTPResponder *)dl;
- (void)stop;

// Request currently being processed
// Note: this need not be the most recently received request
@property(readonly) SimpleHTTPRequest *currentRequest;

@property(readonly) SimpleHTTPResponder *responder;
@property(readonly) NSArray *connections, *requests;
@property(readonly) NSUInteger port;

@property(nonatomic) BOOL loggingEnabled;

@end

@interface SimpleHTTPServer (ConnectionCallback)

- (void)closeConnection:(SimpleHTTPConnection *)connection;
- (void)newRequestWithURL:(NSURL *)url
                   method:(NSString *)method
                     body:(NSData *)body
                  headers:(NSDictionary *)headers
               connection:(SimpleHTTPConnection *)connection;

@end