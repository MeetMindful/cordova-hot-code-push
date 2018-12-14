package com.nordnetab.chcp.main.wkwebviewfix;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;

import org.apache.cordova.ConfigXmlParser;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPreferences;
import org.apache.cordova.CordovaResourceApi;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaWebViewEngine;

import org.apache.cordova.NativeToJsMessageQueue;
import org.apache.cordova.PluginManager;
import org.apache.cordova.engine.SystemWebViewClient;
import org.apache.cordova.engine.SystemWebViewEngine;
import org.apache.cordova.engine.SystemWebView;

import com.ionicframework.cordova.webview.IonicWebViewEngine;


import java.io.File;
import java.net.MalformedURLException;

public class IonicWebViewEngineFix extends IonicWebViewEngine {
  
    /** Used when created via reflection. */
  public IonicWebViewEngineFix(Context context, CordovaPreferences preferences) {
    super(new SystemWebView(context), preferences);
    Log.d(TAG, "Ionic Web View Engine Starting Right Up 1...");
  }

  public IonicWebViewEngineFix(SystemWebView webView) {
    super(webView, null);
    Log.d(TAG, "Ionic Web View Engine Starting Right Up 2...");
  }

  public IonicWebViewEngineFix(SystemWebView webView, CordovaPreferences preferences) {
    super(webView, preferences);
    Log.d(TAG, "Ionic Web View Engine Starting Right Up 3...");
  }

  @Override
  public void loadUrl(String url, boolean clearNavigationStack) {
    if (!url.startsWith("file:///android_asset/")) {
        url = url.replace("file:",  "http://localhost:8080/_file_"); //no CDV_LOCAL_SERVER here!!
    }
    super.loadUrl(url, clearNavigationStack);
  }
}