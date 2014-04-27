
//  SimpleHTTPServer.m  Created by Jürgen on 19.09.06.  © 2006 Cultured Code. License: Creative Commons Attribution 2.5 License  http://creativecommons.org/licenses/by/2.5/

#import "SimpleHTTPServer.h"
#import "SimpleHTTPConnection.h"
#import "SimpleHTTPResponder.h"
#import "SimpleHTTPRequest.h"
#import "SimpleHTTPResponse.h"
#import <sys/socket.h>   // for AF_INET, PF_INET, SOCK_STREAM, SOL_SOCKET, SO_REUSEADDR
#import <netinet/in.h>   // for IPPROTO_TCP, sockaddr_in

@implementation SimpleHTTPServer { NSFileHandle * _fileHandle; }

@synthesize port = _port, responder = _responder,  currentRequest = _currentRequest,
                        connections = _connections,      requests = _requests;

- (id)initWithTCPPort:(NSUInteger)po responder:(SimpleHTTPResponder *)dl {

	if(!(self = super.init)) return nil;

  _port           = po;
  _responder      = dl;
  _connections    = NSMutableArray.new;
  _requests       = NSMutableArray.new;

  int fd = -1;
  CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, NULL, NULL);

  if(socket) {
    fd = CFSocketGetNative(socket);
    int yes = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));

    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(_port);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
    if (kCFSocketSuccess != CFSocketSetAddress(socket, (__bridge CFDataRef)address4))
      !self.loggingEnabled ?: NSLog(@"Could not bind to address");
  } else !self.loggingEnabled ?: NSLog(@"No server socket");

  _fileHandle = [NSFileHandle.alloc initWithFileDescriptor:fd closeOnDealloc:YES];

  [NSNotificationCenter.defaultCenter addObserverForName:NSFileHandleConnectionAcceptedNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {

    NSFileHandle *remoteFileHandle  = note.userInfo[NSFileHandleNotificationFileHandleItem];
    NSNumber *errorNo               = note.userInfo[@"NSFileHandleError"];

    if(errorNo) return !self.loggingEnabled ?: NSLog(@"NSFileHandle Error: %@", errorNo);

    [_fileHandle acceptConnectionInBackgroundAndNotify];

    if(remoteFileHandle) {

      SimpleHTTPConnection *connection = [SimpleHTTPConnection.alloc initWithFileHandle:remoteFileHandle delegate:self];

      if(connection) [[self mutableArrayValueForKey:@"connections"] insertObject:connection atIndex:_connections.count];
    }
  }];

  [_fileHandle acceptConnectionInBackgroundAndNotify];	return self;
}

- (void) stop { [_fileHandle closeFile]; [NSNotificationCenter.defaultCenter removeObserver:self]; }

#pragma mark Managing connections

- (void)closeConnection:(SimpleHTTPConnection *)connection {
	NSUInteger connectionIndex = [_connections indexOfObjectIdenticalTo:connection];

	if(connectionIndex == NSNotFound) return;

	// We remove all pending requests pertaining to connection
	NSMutableIndexSet *obsoleteRequests = NSMutableIndexSet.indexSet; __block BOOL stopProcessing = NO;

  [_requests enumerateObjectsUsingBlock:^(SimpleHTTPRequest *request, NSUInteger idx, BOOL *stop) {

		if(request.connection == connection) {
			if(request == self.currentRequest) stopProcessing = YES;
			[obsoleteRequests addIndex:idx];
		}
	}];

	[[self mutableArrayValueForKey:   @"requests"] removeObjectsAtIndexes:obsoleteRequests];
	[[self mutableArrayValueForKey:@"connections"] removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:connectionIndex]];

	if(stopProcessing) { [_responder stopProcessing]; _currentRequest = nil; }

	[self processNextRequestIfNecessary];
}

#pragma mark Managing requests

- (void)newRequestWithURL:(NSURL*)url method:(NSString*)m body:(NSData*)body
                  headers:(NSDictionary*)headers    connection:(SimpleHTTPConnection*)conn
{
  if(self.loggingEnabled) {
    NSLog(@"request for: %@ method: %@ body: %@", url, m, body);
    NSLog(@"requestWithURL:connection:");
  }
  if( url == nil ) return;

  [[self mutableArrayValueForKey:@"requests"] addObject:
            [SimpleHTTPRequest.alloc initWithDictionary:@{
                @"url" : url,         @"method" : m,    @"body" : body,
            @"headers" : headers, @"connection" : conn, @"date" : NSDate.date}.mutableCopy]];

  [self processNextRequestIfNecessary];
}

- (void)processNextRequestIfNecessary
{
  if( _currentRequest == nil && _requests.count ) {
    _currentRequest = _requests[0];

		SimpleHTTPResponse *response;

		if([[_currentRequest method] isEqualToString:@"POST"]) {
			response = [_responder processPOST:_currentRequest];
		} else {
			response = [_responder processGET:_currentRequest];
		}

		[self processResponse:response];
  }
}

#pragma mark Sending replies

// The Content-Length header field will be automatically added
- (void)processResponse:(SimpleHTTPResponse *)response
{
  !self.loggingEnabled ?: NSLog(@"sending output");

	CFHTTPMessageRef msg = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [response responseCode],
                                                     NULL, kCFHTTPVersion1_1); // Use standard status description

  [response.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {

    CFHTTPMessageSetHeaderFieldValue(msg, (__bridge CFStringRef)([key   isKindOfClass:NSString.class] ? key : [key description]),
                                     (__bridge CFStringRef)([value isKindOfClass:NSString.class] ? value : [value description]));
  }];
  if(response.content) {
    CFHTTPMessageSetHeaderFieldValue(msg, (CFStringRef)@"Content-Length", (__bridge CFStringRef)@(response.content.length).stringValue);
    CFHTTPMessageSetBody(msg, (__bridge CFDataRef)[response content]);
  }

  CFDataRef msgData = CFHTTPMessageCopySerializedMessage(msg);
  @try {
    [self.currentRequest.connection.fileHandle writeData:(__bridge NSData *)msgData];
  }
  @catch (NSException *exception) {
    !self.loggingEnabled ?:
    NSLog(@"Error while sending response (%@): %@", self.currentRequest.url, exception.reason);
  }
  CFRelease(msgData); CFRelease(msg);

  //  A reply indicates that the current request has been completed
  //  (either successfully of by responding with an error message) - Hence we need to remove the current request:
  NSUInteger index =   [_requests indexOfObjectIdenticalTo:[self currentRequest]];
  if( index != NSNotFound ) [[self mutableArrayValueForKey:@"requests"]
                             removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
  _currentRequest = nil;
  [self processNextRequestIfNecessary];
}

@end

//- (void)newConnection:(NSNotification *)note {

//			NSIndexSet *insertedIndexes = [NSIndexSet indexSetWithIndex:_connections.count];
//			[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:];
//			[_connections addObject:connection];
//			[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"connections"];
//		}
//	}
//}
//        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
//        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"requests"];

//        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"requests"];    }
  //	NSIndexSet *connectionIndexSet = [NSIndexSet indexSetWithIndex:connectionIndex];
  //	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:obsoleteRequests forKey:@"requests"];
  //	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:connectionIndexSet forKey:@"connections"];
//	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:connectionIndexSet forKey:@"connections"];
//	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:obsoleteRequests forKey:@"requests"];
//  NSIndexSet *insertedIndexes = [NSIndexSet indexSetWithIndex:_requests.count];
//  [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"requests"];
//  [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:insertedIndexes forKey:@"requests"];
