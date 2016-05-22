//
//  SwiftWebViewProgress.swift
//  SwiftWebViewProgress
//
//  Created by Daichi Ichihara on 2014/12/03.
//  Copyright (c) 2014 MokuMokuCloud. All rights reserved.
//

import UIKit

@objc public protocol WebViewProgressDelegate {
    func webViewProgress(webViewProgress: WebViewProgress, updateProgress progress: Float)
}

public class WebViewProgress: NSObject {
    
    public weak var progressDelegate: WebViewProgressDelegate?
    public weak var webViewProxyDelegate: UIWebViewDelegate?
    public var progress: Float = 0.0
    
    private var loadingCount: Int = 0
    private var maxLoadCount: Int = 0
    private var currentUrl: NSURL?
    private var interactive: Bool = false
    
    private let InitialProgressValue: Float = 0.1
    private let InteractiveProgressValue: Float = 0.5
    private let FinalProgressValue: Float = 0.9
    private let completePRCURLPath = "/webviewprogressproxy/complete"
    
    // MARK: Initializer
    override public init() {
        super.init()
    }
    
    // MARK: Private Method
    private func startProgress() {
        if progress < InitialProgressValue {
            setProgress(InitialProgressValue)
        }
    }
    
    private func incrementProgress() {
        var progress = self.progress
        let maxProgress = interactive == true ? FinalProgressValue : InteractiveProgressValue
        let remainPercent = Float(Float(loadingCount) / Float(maxLoadCount))
        let increment = (maxProgress - progress) * remainPercent
        progress += increment
        progress = fmin(progress, maxProgress)
        setProgress(progress)
    }

    private func setProgress(progress: Float) {
        guard progress > self.progress || progress == 0 else {
            return
        }
        self.progress = progress
        progressDelegate?.webViewProgress(self, updateProgress: progress)
    }
    
    // MARK: Public Method
    public func reset() {
        maxLoadCount = 0
        loadingCount = 0
        interactive = false
        setProgress(0.0)
    }
    
}

extension WebViewProgress: UIWebViewDelegate {
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.URL else {
            return false
        }
        if url.path == completePRCURLPath {
            setProgress(1.0)
            return false
        }
        
        var ret = true
        if webViewProxyDelegate!.respondsToSelector(#selector(UIWebViewDelegate.webView(_:shouldStartLoadWithRequest:navigationType:))) {
            ret = webViewProxyDelegate!.webView!(webView, shouldStartLoadWithRequest: request, navigationType: navigationType)
        }
        
        var isFragmentJump = false
        if let fragmentURL = url.fragment {
            let nonFragmentURL = url.absoluteString.stringByReplacingOccurrencesOfString("#"+fragmentURL, withString: "")
            isFragmentJump = nonFragmentURL == webView.request!.URL!.absoluteString
        }
        
        let isTopLevelNavigation = request.mainDocumentURL! == request.URL
        let isHTTP = url.scheme == "http" || url.scheme == "https"
        if ret && !isFragmentJump && isHTTP && isTopLevelNavigation {
            currentUrl = request.URL
            reset()
        }
        return ret
    }
    
    public func webViewDidStartLoad(webView: UIWebView) {
        if webViewProxyDelegate!.respondsToSelector(#selector(UIWebViewDelegate.webViewDidStartLoad(_:))) {
            webViewProxyDelegate!.webViewDidStartLoad!(webView)
        }
        
        loadingCount += 1
        maxLoadCount = loadingCount > maxLoadCount ? loadingCount : maxLoadCount
        startProgress()
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        if webViewProxyDelegate!.respondsToSelector(#selector(UIWebViewDelegate.webViewDidFinishLoad(_:))) {
            webViewProxyDelegate!.webViewDidFinishLoad!(webView)
        }
        
        loadingCount -= 1
        incrementProgress()
        
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        
        if readyState == "interactive" {
            self.interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(webView.request?.mainDocumentURL?.scheme)://\(webView.request?.mainDocumentURL?.host)\(completePRCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS)
        }

        if readyState == "complete" && isNotRedirect(webView) {
            setProgress(1.0)
        }
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if webViewProxyDelegate!.respondsToSelector(#selector(UIWebViewDelegate.webView(_:didFailLoadWithError:))) {
            webViewProxyDelegate!.webView!(webView, didFailLoadWithError: error)
        }
        
        loadingCount -= 1
        incrementProgress()
        
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        
        if readyState == "interactive" {
            self.interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(webView.request?.mainDocumentURL?.scheme)://\(webView.request?.mainDocumentURL?.host)\(completePRCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS)
        }
        
        if readyState == "complete" && isNotRedirect(webView) {
            setProgress(1.0)
        }
    }

    private func isNotRedirect(webView: UIWebView) -> Bool {
        guard let currentUrl = currentUrl else {
            return false
        }

        return currentUrl == webView.request?.mainDocumentURL
    }
}
