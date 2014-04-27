//
//  SimpleHTTPResponder.m
//  TouchMe
//
//  Created by Alex P on 15/11/2007.
//  © 2007 __MyCompanyName__. All rights reserved.
//

#import "SimpleHTTPResponder.h"
#import "SimpleHTTPConnection.h"
#import "SimpleHTTPServer.h"
#import "SimpleHTTPRequest.h"
#import "SimpleHTTPResponse.h"

@implementation SimpleHTTPResponder {	SimpleHTTPServer *_server; NSNetService *_bonjourService; } @dynamic listening;

+ (NSDictionary*)knownMimetypes { static NSDictionary *lookupTable = nil; static dispatch_once_t oneT;

  return dispatch_once(&oneT, ^{ lookupTable = @{

    @"ai": @"application/postscript",
    @"aif": @"audio/x-aiff",
    @"aifc": @"audio/x-aiff",
    @"aiff": @"audio/x-aiff",
    @"asc": @"text/plain",
    @"au": @"audio/basic",
    @"avi": @"video/x-msvideo",
    @"bcpio": @"application/x-bcpio",
    @"bin": @"application/octet-stream",
    @"c": @"text/plain",
    @"cc": @"text/plain",
    @"ccad": @"application/clariscad",
    @"cdf": @"application/x-netcdf",
    @"class": @"application/octet-stream",
    @"cpio": @"application/x-cpio",
    @"cpp": @"text/plain",
    @"cpt": @"application/mac-compactpro",
    @"cs": @"text/plain",
    @"csh": @"application/x-csh",
    @"css": @"text/css",
    @"dcr": @"application/x-director",
    @"dir": @"application/x-director",
    @"dms": @"application/octet-stream",
    @"doc": @"application/msword",
    @"docx": @"application/msword",
    @"dot": @"application/msword",
    @"drw": @"application/drafting",
    @"dvi": @"application/x-dvi",
    @"dwg": @"application/acad",
    @"dxf": @"application/dxf",
    @"dxr": @"application/x-director",
    @"eps": @"application/postscript",
    @"etx": @"text/x-setext",
    @"exe": @"application/octet-stream",
    @"ez": @"application/andrew-inset",
    @"f": @"text/plain",
    @"f90": @"text/plain",
    @"fli": @"video/x-fli",
    @"gif": @"image/gif",
    @"gtar": @"application/x-gtar",
    @"gz": @"application/x-gzip",
    @"h": @"text/plain",
    @"hdf": @"application/x-hdf",
    @"hh": @"text/plain",
    @"hqx": @"application/mac-binhex40",
    @"htm": @"text/html",
    @"html": @"text/html",
    @"ice": @"x-conference/x-cooltalk",
    @"ief": @"image/ief",
    @"iges": @"model/iges",
    @"igs": @"model/iges",
    @"ips": @"application/x-ipscript",
    @"ipx": @"application/x-ipix",
    @"jpe": @"image/jpeg",
    @"jpeg": @"image/jpeg",
    @"jpg": @"image/jpeg",
    @"js": @"application/x-javascript",
    @"kar": @"audio/midi",
    @"latex": @"application/x-latex",
    @"lha": @"application/octet-stream",
    @"lsp": @"application/x-lisp",
    @"lzh": @"application/octet-stream",
    @"m": @"text/plain",
    @"man": @"application/x-troff-man",
    @"me": @"application/x-troff-me",
    @"mesh": @"model/mesh",
    @"mid": @"audio/midi",
    @"midi": @"audio/midi",
    @"mime": @"www/mime",
    @"mov": @"video/quicktime",
    @"movie": @"video/x-sgi-movie",
    @"mp2": @"audio/mpeg",
    @"mp3": @"audio/mpeg",
    @"mpe": @"video/mpeg",
    @"mpeg": @"video/mpeg",
    @"mpg": @"video/mpeg",
    @"mpga": @"audio/mpeg",
    @"ms": @"application/x-troff-ms",
    @"msi": @"application/x-ole-storage",
    @"msh": @"model/mesh",
    @"nc": @"application/x-netcdf",
    @"oda": @"application/oda",
    @"pbm": @"image/x-portable-bitmap",
    @"pdb": @"chemical/x-pdb",
    @"pdf": @"application/pdf",
    @"pgm": @"image/x-portable-graymap",
    @"pgn": @"application/x-chess-pgn",
    @"png": @"image/png",
    @"pnm": @"image/x-portable-anymap",
    @"pot": @"application/mspowerpoint",
    @"ppm": @"image/x-portable-pixmap",
    @"pps": @"application/mspowerpoint",
    @"ppt": @"application/mspowerpoint",
    @"ppz": @"application/mspowerpoint",
    @"pre": @"application/x-freelance",
    @"prt": @"application/pro_eng",
    @"ps": @"application/postscript",
    @"qt": @"video/quicktime",
    @"ra": @"audio/x-realaudio",
    @"ram": @"audio/x-pn-realaudio",
    @"ras": @"image/cmu-raster",
    @"rgb": @"image/x-rgb",
    @"rm": @"audio/x-pn-realaudio",
    @"roff": @"application/x-troff",
    @"rpm": @"audio/x-pn-realaudio-plugin",
    @"rtf": @"text/rtf",
    @"rtx": @"text/richtext",
    @"scm": @"application/x-lotusscreencam",
    @"set": @"application/set",
    @"sgm": @"text/sgml",
    @"sgml": @"text/sgml",
    @"sh": @"application/x-sh",
    @"shar": @"application/x-shar",
    @"silo": @"model/mesh",
    @"sit": @"application/x-stuffit",
    @"skd": @"application/x-koan",
    @"skm": @"application/x-koan",
    @"skp": @"application/x-koan",
    @"skt": @"application/x-koan",
    @"smi": @"application/smil",
    @"smil": @"application/smil",
    @"snd": @"audio/basic",
    @"sol": @"application/solids",
    @"spl": @"application/x-futuresplash",
    @"src": @"application/x-wais-source",
    @"step": @"application/STEP",
    @"stl": @"application/SLA",
    @"stp": @"application/STEP",
    @"sv4cpio": @"application/x-sv4cpio",
    @"sv4crc": @"application/x-sv4crc",
    @"swf": @"application/x-shockwave-flash",
    @"t": @"application/x-troff",
    @"tar": @"application/x-tar",
    @"tcl": @"application/x-tcl",
    @"tex": @"application/x-tex",
    @"tif": @"image/tiff",
    @"tiff": @"image/tiff",
    @"tr": @"application/x-troff",
    @"tsi": @"audio/TSP-audio",
    @"tsp": @"application/dsptype",
    @"tsv": @"text/tab-separated-values",
    @"txt": @"text/plain",
    @"unv": @"application/i-deas",
    @"ustar": @"application/x-ustar",
    @"vcd": @"application/x-cdlink",
    @"vda": @"application/vda",
    @"vrml": @"model/vrml",
    @"wav": @"audio/x-wav",
    @"wrl": @"model/vrml",
    @"xbm": @"image/x-xbitmap",
    @"xlc": @"application/vnd.ms-excel",
    @"xll": @"application/vnd.ms-excel",
    @"xlm": @"application/vnd.ms-excel",
    @"xls": @"application/vnd.ms-excel",
    @"xlw": @"application/vnd.ms-excel",
    @"xml": @"text/xml",
    @"xpm": @"image/x-xpixmap",
    @"xwd": @"image/x-xwindowdump",
    @"xyz": @"chemical/x-pdb",
    @"zip": @"application/zip",
    @"m4v": @"video/x-m4v",
    @"webm": @"video/webm",
    @"ogv": @"video/ogv"};
  }), lookupTable;
}

- (BOOL) isListening { return !!_server; }
- (void) setListening:(BOOL)l {

  if (l) { _server = [SimpleHTTPServer.alloc initWithTCPPort:self.port responder:self];

    _bonjourName.length ?
      [_bonjourService  = [NSNetService.alloc initWithDomain:@""
                                                       type:@"_http._tcp."
                                                       name:_bonjourName
                                                       port:(int)_port] publish] : nil;
  } else {
    [_bonjourService stop]; _bonjourService = nil;
    [_server stop];                 _server = nil;
  }

  self.loggingEnabled ? NSLog(l ? @"Started %@" : @"Stopped %@", self) : nil;

}

- (NSString *)description {
  return [NSString stringWithFormat:@"<HTTP-Server %@ @ %d with webroot %@>", self.bonjourName, (int)self.port, self.webRoot];
}

#pragma mark -

- (SimpleHTTPResponse *)processPOST:(SimpleHTTPRequest *)r {

  return [_delegate respondsToSelector:@selector(processPOST:)]
                                    ? [_delegate processPOST:r]
                                      : [self processRequest:r];
}

- (SimpleHTTPResponse *)     processGET:(SimpleHTTPRequest*)r {

  return [_delegate respondsToSelector:@selector(processGET:)]
                                    ? [_delegate processGET:r]
                                     : [self processRequest:r];
}
- (SimpleHTTPResponse *) processRequest:(SimpleHTTPRequest *)request {

	SimpleHTTPResponse *response = [[SimpleHTTPResponse alloc] init];

	if(!!_webRoot) {

		NSString * fileName = request.url.path;
		NSArray *substrings = [fileName componentsSeparatedByString:@"?"];

		if(substrings.count > 1) fileName = substrings[0];  // parse out query strings

		NSDictionary * fileData = [self getFileFromWebRoot:fileName];

		if(!!fileData[@"error"]) {
			[response setResponseCode:404];
			[response setContentString:fileData[@"error"]];
		} else {
			[response setContentType:fileData[@"mimeType"]];
			[response setContent:fileData[@"data"]];
		}
	} else {
		[response setResponseCode:404];
		[response setContentString:@"Handler not found."];
	}

	return response;
}
- (void) stopProcessing { }


- (NSDictionary *)getFileFromWebRoot:(NSString *)requestedFile {

	NSMutableDictionary *output = NSMutableDictionary.new; BOOL webRootIsDir = NO;

	if([NSFileManager.defaultManager fileExistsAtPath:self.webRoot isDirectory:&webRootIsDir]) {
    //if webroot is file, return that
    if(!webRootIsDir) {
      self.loggingEnabled ? NSLog(@"Sending webroot directly as it is a file with mimetype %@", [self getMimeTypeFromFile:self.webRoot]) : nil;

      output[@"data"] = [NSData dataWithContentsOfFile:self.webRoot];
      output[@"mimeType"] = [self getMimeTypeFromFile:self.webRoot];
    }
    else {
      NSString *path = [self.webRoot stringByAppendingString:requestedFile];
      self.loggingEnabled ? NSLog(@"file requested was %@", path) : nil;

      //return the file if it can be found
      //check if it is a directory
      BOOL isDirectory = false;
      if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]
         && [[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        //depending on wether it is a file or a dir, we gotta treat it differently
        if(isDirectory) {
          if(self.indexFile != nil) {
            if([[requestedFile substringFromIndex:[requestedFile length] - 1] isEqualToString:@"/"]) {
              return [self getFileFromWebRoot:[requestedFile stringByAppendingString:self.indexFile]];
            }
            else {
              return [self getFileFromWebRoot:[requestedFile stringByAppendingString:[@"/" stringByAppendingString:self.indexFile]]];
            }
          }
          else if(self.autogenerateIndex) {
            return [self generateIndexFromWebRoot:requestedFile for:path];
          }
          else output[@"error"] = @"Directory index not permitted";
        }
        else {
          self.loggingEnabled ? NSLog(@"Sending file %@ with mimetype %@", path, [self getMimeTypeFromFile:path]) : nil;

          output[@"data"] = [NSData dataWithContentsOfFile:path];
          output[@"mimeType"] = [self getMimeTypeFromFile:path];
        }
      }
      else {
        self.loggingEnabled ? NSLog(@"Could not read file %@", path) : nil;
        output[@"error"] = @"Cannot read file";
      }
    }
	} else output[@"error"] = _webRoot.length ? @"Webroot set to invalid path" : @"Webroot not set";

	return output;
}

- (NSDictionary*)generateIndexFromWebRoot:(NSString *)requestedFile for:(NSString*)path {
  NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];

  NSMutableString *html = [NSMutableString stringWithFormat:@"<html><body><h2>Index for '%@'</h2><ul>", path];
  for (NSString *content in contents) {
    [html appendFormat:@"\n<li><a href=\"%@\">%@</a></li>", [requestedFile stringByAppendingPathComponent:content], content];
  }
  [html appendString:@"</ul></body></html>"];

	NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
  output[@"data"] = [html dataUsingEncoding:NSUTF8StringEncoding];
  output[@"mimeType"] = @"text/html";
  return output;
}

- (NSString *)getMimeTypeFromFile:(NSString *)filePath {
	NSArray *fileNameParts = [filePath componentsSeparatedByString:@"."];
	NSString *extension = fileNameParts[[fileNameParts count] -1];

	return [self.class MIMETypeForExtension:extension];
}

+ (NSString *) MIMETypeForExtension:(NSString *)extension {
  NSString *mimetype = extension.length ? [self knownMimetypes][extension] : nil;
  return mimetype == nil ? @"application/octet-stream" : mimetype;
} // from AmazonSKDUtil

- (NSURL*) localURL { return [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%lu",
                                                    NSHost.currentHost.name,
                                                    self.port]];
}

@end
