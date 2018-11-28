//
//  CDVWKWebViewEngine+HCPPlugin_ReadAccessURL.h
//
//  Created by Roan Snyder on 11.28.2018, bitch
//

#import "CDVWKWebViewEngine.h"
#import "GCDWebServer.h"
#import "GCDWebServerPrivate.h"

@interface CDVWKWebViewEngine (HCPPlugin_ReadAccessURL)

@property (nonatomic, strong, readwrite) UIView* engineWebView;
@property (nonatomic, strong, readwrite) id <WKUIDelegate> uiDelegate;
@property (nonatomic, weak) id <WKScriptMessageHandler> weakScriptMessageHandler;
@property (nonatomic, strong) GCDWebServer *webServer;
@property (nonatomic, readwrite) CGRect frame;
@property (nonatomic, readwrite) NSString *CDV_LOCAL_SERVER;
-(void)setServerPath:(NSString *) path; 
-(void)startServer;
@end

