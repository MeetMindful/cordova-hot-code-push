//
//  CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.m
//
//  Created by Nikolay Demyankov on 04.04.16.
//

#if WK_WEBVIEW_ENGINE_IS_USED

#import "CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.h"
#import <objc/message.h>


@implementation CDVWKWebViewEngine (HCPPlugin_ReadAccessURL)

// - (id)loadRequest:(NSURLRequest*)request
// {
//     if ([self canLoadRequest:request]) { // can load, differentiate between file urls and other schemes
// 		CDVViewController* vc = (CDVViewController*)self.viewController;                

// 		//if its contains localhost, the application use local web server
//         if([vc.startPage containsString: @"localhost"]) {
// 			NSURLComponents *newUrl = [NSURLComponents componentsWithString:vc.startPage];

// 			//Case: Navigation after update install complete
// 			if (request.URL.fileURL) {
// 	    		NSString *newPath = [@"/local-filesystem" stringByAppendingString: "_file_/"];
// 	        newUrl.path = [ newPath stringByAppendingString: request.URL.path ];
//     			NSLog(@"new pathing that other bitch %@", newUrl.path);

// 			    return [(WKWebView*)self.engineWebView loadRequest:[NSURLRequest requestWithURL:newUrl.URL]];
// 			} 
// 			//Case: load application start page
// 			else {
// 				NSURL *wwwPath = [NSURL URLWithString:vc.wwwFolderName];
// 			    if(wwwPath.fileURL) {
// 			    		NSString *newPath = [@"/local-filesystem" stringByAppendingString: "_file_/"];
// 			        newUrl.path = [ newPath stringByAppendingString:[wwwPath.path stringByAppendingString:@"index.html"] ];
//         			NSLog(@"new pathing that bitch %@", newUrl.path);

// 			        return [(WKWebView*)self.engineWebView loadRequest:[NSURLRequest requestWithURL:newUrl.URL]];
// 			    }
// 			    else {
// 			        return [(WKWebView*)self.engineWebView loadRequest:request];
// 			    }
// 			}
// 		}
// 		//Original way
// 		else {
// 			if (request.URL.fileURL) {
// 			    SEL wk_sel = NSSelectorFromString(CDV_WKWEBVIEW_FILE_URL_LOAD_SELECTOR);
			    
// 			    // by default we set allowingReadAccessToURL property to the plugin's root folder,
// 			    // so the WKWebView would load our updates from it.
// 			    NSURL* readAccessUrl = [HCPFilesStructure pluginRootFolder];
			    
// 			    // if we are loading index page from the bundle - we need to go up in the folder structure, so the next load from the external storage would work
// 			    if (![request.URL.absoluteString containsString:readAccessUrl.absoluteString]) {
// 			        readAccessUrl = [[[request.URL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent] URLByDeletingLastPathComponent];
// 			    }
			    
// 			    return ((id (*)(id, SEL, id, id))objc_msgSend)(self.engineWebView, wk_sel, request.URL, readAccessUrl);
// 			} else {
// 			    return [(WKWebView*)self.engineWebView loadRequest:request];
// 			}
// 		}
//     } else { // can't load, print out error
//         NSString* errorHtml = [NSString stringWithFormat:
// 								@"<!doctype html>"
// 								@"<title>Error</title>"
// 								@"<div style='font-size:2em'>"
// 								@"   <p>The WebView engine '%@' is unable to load the request: %@</p>"
// 								@"   <p>Most likely the cause of the error is that the loading of file urls is not supported in iOS %@.</p>"
// 								@"</div>",							   
// 								NSStringFromClass([self class]),
// 								[request.URL description],
// 								[[UIDevice currentDevice] systemVersion]
//                                ];

//         return [self loadHTMLString:errorHtml baseURL:nil];
//     }
// }

// no clue what this does
// https://github.com/superbigsoft/cordova-plugin-ionic-webview/commit/fa4664aa9f89ed0421ecfdc072f6d7fac8124f29
-(void)setServerPath:(NSString *) path
 {
     self.basePath = path;
     BOOL restart = [self.webServer isRunning];
    if (restart) {
        [self.webServer stop];
    }
    
    if (self.CDV_LOCAL_SERVER == nil) {
        NSDictionary * settings = self.commandDelegate.settings;
        //bind to designated hostname or default to localhost
        NSString *bind = [settings cordovaSettingForKey:@"WKBind"];
        if(bind == nil){
            bind = @"localhost";
        }
         //bind to designated port or default to 8080
        int portNumber = [settings cordovaFloatSettingForKey:@"WKPort" defaultValue:8080];
         //set the local server name
        self.CDV_LOCAL_SERVER = [NSString stringWithFormat:@"http://%@:%d", bind, portNumber];
    }
    
    NSString *serverUrl = self.CDV_LOCAL_SERVER;
    
    [self.webServer addGETHandlerForBasePath:@"/" directoryPath:path indexFilename:((CDVViewController *)self.viewController).startPage cacheAge:0 allowRangeRequests:YES];
    
    NSString *codePushUrl =@"(^/var/mobile/|^/Users/)";
    [self.webServer addHandlerForMethod:@"GET" pathRegex:codePushUrl requestClass:GCDWebServerFileRequest.class asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        
        NSString *absUrl = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:serverUrl withString:@""];
         NSRange range = [absUrl rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            absUrl = [absUrl substringToIndex:range.location];
        }
         GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:absUrl];
        completionBlock(response);
    }];
    
    [self.webServer addHandlerForMethod:@"GET" pathRegex:@"_file_/" requestClass:GCDWebServerFileRequest.class asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        NSString *urlToRemove = [serverUrl stringByAppendingString:@"/_file_"];
        NSString *absUrl = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:urlToRemove withString:@""];
 
         NSRange range = [absUrl rangeOfString:@"?"];
         if (range.location != NSNotFound) {
             absUrl = [absUrl substringToIndex:range.location];
         }
 
         GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:absUrl];
         completionBlock(response);
     }];
     if (restart) {
         [self startServer];
     }
 }

@end

#endif
