//
//  CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.m
//
//  Created by Nikolay Demyankov on 04.04.16.
//

#import "CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.h"
#import <objc/message.h>

@implementation CDVWKWebViewEngine (HCPPlugin_ReadAccessURL)

 -(void)setServerPath:(NSString *) path
 {

		NSLog(@"we are actually using this hot code fix");

    (CDVWKWebViewEngine*)self.basePath = path;
    BOOL restart = [(CDVWKWebViewEngine*)self.webServer isRunning];
    if (restart) {
      [(WKWebView*)self.webServer stop];
    }
    
    if ((CDVWKWebViewEngine*)self.CDV_LOCAL_SERVER == nil) {
        NSDictionary * settings = (CDVWKWebViewEngine*)self.commandDelegate.settings;
        //bind to designated hostname or default to localhost
        NSString *bind = [settings cordovaSettingForKey:@"WKBind"];
        if(bind == nil){
            bind = @"localhost";
        }
         //bind to designated port or default to 8080
        int portNumber = [settings cordovaFloatSettingForKey:@"WKPort" defaultValue:8080];
         //set the local server name
        (WKWebView*)self.CDV_LOCAL_SERVER = [NSString stringWithFormat:@"http://%@:%d", bind, portNumber];
    }
    
    NSString *serverUrl = self.CDV_LOCAL_SERVER;
    
    [(CDVWKWebViewEngine*)self.webServer addGETHandlerForBasePath:@"/" directoryPath:path indexFilename:((CDVViewController *)self.viewController).startPage cacheAge:0 allowRangeRequests:YES];
    
    NSString *codePushUrl =@"(^/var/mobile/|^/Users/)";
    [(CDVWKWebViewEngine*)self.webServer addHandlerForMethod:@"GET" pathRegex:codePushUrl requestClass:GCDWebServerFileRequest.class asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        
        NSString *absUrl = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:serverUrl withString:@""];
        absUrl = [absUrl stringByRemovingPercentEncoding];
        NSRange range = [absUrl rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            absUrl = [absUrl substringToIndex:range.location];
        }
        GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:absUrl];
        completionBlock(response);
    }];
    
    [(CDVWKWebViewEngine*)self.webServer addHandlerForMethod:@"GET" pathRegex:@"_file_/" requestClass:GCDWebServerFileRequest.class asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        NSString *urlToRemove = [serverUrl stringByAppendingString:@"/_file_"];
        NSString *absUrl = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:urlToRemove withString:@""];
 				absUrl = [absUrl stringByRemovingPercentEncoding];
        NSRange range = [absUrl rangeOfString:@"?"];
        if (range.location != NSNotFound) {
          absUrl = [absUrl substringToIndex:range.location];
        }
 
         GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:absUrl];
         completionBlock(response);
     }];
     if (restart) {
         (CDVWKWebViewEngine*)[self startServer];
     }
 }

@end
