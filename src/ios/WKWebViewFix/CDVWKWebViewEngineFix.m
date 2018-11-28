//
//  CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.m
//
//  Created by Nikolay Demyankov on 04.04.16.
//

#import "CDVWKWebViewEngineFix.h"
#import <objc/message.h>

@implementation CDVWKWebViewEngineFix

 -(void)setServerPath:(NSString *) path
 {

		NSLog(@"we are actually using this hot code fix");

    super.basePath = path;
    BOOL restart = [super.webServer isRunning];
    if (restart) {
      [super.webServer stop];
    }
    
    if (super.CDV_LOCAL_SERVER == nil) {
        NSDictionary * settings = super.commandDelegate.settings;
        //bind to designated hostname or default to localhost
        NSString *bind = [settings cordovaSettingForKey:@"WKBind"];
        if(bind == nil){
            bind = @"localhost";
        }
         //bind to designated port or default to 8080
        int portNumber = [settings cordovaFloatSettingForKey:@"WKPort" defaultValue:8080];
         //set the local server name
        super.CDV_LOCAL_SERVER = [NSString stringWithFormat:@"http://%@:%d", bind, portNumber];
    }
    
    NSString *serverUrl = self.CDV_LOCAL_SERVER;
    
    [super.webServer addGETHandlerForBasePath:@"/" directoryPath:path indexFilename:((CDVViewController *)self.viewController).startPage cacheAge:0 allowRangeRequests:YES];
    
    NSString *codePushUrl =@"(^/var/mobile/|^/Users/)";
    [super.webServer addHandlerForMethod:@"GET" pathRegex:codePushUrl requestClass:GCDWebServerFileRequest.class asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        
        NSString *absUrl = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:serverUrl withString:@""];
        absUrl = [absUrl stringByRemovingPercentEncoding];
        NSRange range = [absUrl rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            absUrl = [absUrl substringToIndex:range.location];
        }
        GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:absUrl];
        completionBlock(response);
    }];
    
    [super.webServer addHandlerForMethod:@"GET" pathRegex:@"_file_/" requestClass:GCDWebServerFileRequest.class asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
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
         [super startServer];
     }
 }

@end
