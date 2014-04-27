
//  main.m  DDSimpleHTTPd  Created by Dominik Pich on 24.05.13.

#import <Cocoa/Cocoa.h>
#import "SimpleHTTPResponder.h"

int main(int argc, const char * argv[]) {

  BOOL debug =
#if !DEBUG
    NO;
    if(argc != 4) return printf("Usage: DDSimpleHTTPd NAME PORT WebRootPath"), 1;
#endif
    YES;

    @autoreleasepool {

      SimpleHTTPResponder *smplSrvr = SimpleHTTPResponder.new;
      smplSrvr.port                 = debug ? 8000 : @(argv[2]).intValue;
      smplSrvr.webRoot              = debug ? @"/" : @(argv[3]);
      smplSrvr.bonjourName          = debug ? NSHost.currentHost.name : @(argv[1]);
      smplSrvr.loggingEnabled       = debug;
      smplSrvr.autogenerateIndex    = YES;
      smplSrvr.listening            = YES;
        
      printf("Running server %s...\nPress Ctrl+C to stop it ...", smplSrvr.description.UTF8String);

      [NSWorkspace.sharedWorkspace openURL:smplSrvr.localURL]; [NSRunLoop.mainRunLoop run]; //RUN and WAIT for ctrl+c
    }
    return 0;
}