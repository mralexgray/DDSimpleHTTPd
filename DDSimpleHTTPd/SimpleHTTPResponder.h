
//  HTTPResponder.h  Created by Alex P on 15/11/2007
//  Refactored for new objC,ARC and ios/foundation.framework 24.5.13 © 2013 Dominik Pich
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@class SimpleHTTPRequest, SimpleHTTPResponse;

@protocol SimpleHTTPResponderDelegate <NSObject>

/*! @return if the delegate provides an answer we return that
    @note defaults implementation attempts to respond, but with only limited mime types, and can ONLY do @c GET's
*/
@optional
- (SimpleHTTPResponse*) processPOST:(SimpleHTTPRequest*)r;
- (SimpleHTTPResponse*)  processGET:(SimpleHTTPRequest*)r;

@end

/*! @class SimpleHTTPResponder @warning all not thread safe and only meant to be used on main thread */

@interface SimpleHTTPResponder : NSObject <SimpleHTTPResponderDelegate>

/*! @return all filetypes(with extensions) and their mimetype we can handle out-of-the-box */

+ (NSDictionary*)knownMimetypes;

/*! @param webroot needs to be set if delegate doesnt handle everything.
    @note the properties wont take effect while the server is up (delegate is the exception).
    @param autogenerateIndex only applies if you dont specify an index file.
*/
@property (nonatomic,copy) NSString * webRoot,
                                    * indexFile,
                                    * bonjourName;
@property (readonly)          NSURL * localURL;
@property (nonatomic)          BOOL   autogenerateIndex,
                                      loggingEnabled;
@property(nonatomic)      NSUInteger  port;

@property(nonatomic,assign) id<SimpleHTTPResponderDelegate> delegate;

@property(nonatomic, getter = isListening) BOOL listening;

@end

@interface SimpleHTTPResponder (RequestProcessing)

- (SimpleHTTPResponse*) processRequest:(SimpleHTTPRequest*)r;
- (void) stopProcessing;

@end
