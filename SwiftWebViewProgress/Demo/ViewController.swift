//
//  ViewController.swift
//  SwiftWebViewProgress
//
//  Created by Daichi Ichihara on 2014/12/03.
//  Copyright (c) 2014 MokuMokuCloud. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, WebViewProgressDelegate {
    private var webView: UIWebView!
    private var progressView: WebViewProgressView!
    private var progressProxy: WebViewProgress!

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        webView = UIWebView(frame: self.view.bounds)
        self.view.addSubview(webView)
        
        progressProxy = WebViewProgress()
        webView.delegate = progressProxy
        progressProxy.webViewProxyDelegate = self
        progressProxy.progressDelegate = self
        
        progressView = WebViewProgressView(frame: CGRect.zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(progressView)

        self.view.addConstraint(NSLayoutConstraint(item: progressView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: progressView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: progressView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        self.progressView.addConstraint(NSLayoutConstraint(item: progressView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 2.0))
        
        loadApple()
    }

    // MARK: Private Method
    private func loadApple() {
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "https://apple.com")!))
    }
    
    // MARK: - WebViewProgressDelegate
    func webViewProgress(webViewProgress: WebViewProgress, updateProgress progress: Float) {
        NSLog("progress: \(progress)")
        progressView.setProgress(progress, animated: true)
    }
}
