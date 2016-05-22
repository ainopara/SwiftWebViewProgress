//
//  SwiftWebViewProgressView.swift
//  SwiftWebViewProgress
//
//  Created by Daichi Ichihara on 2014/12/04.
//  Copyright (c) 2014年 MokuMokuCloud. All rights reserved.
//

import UIKit

public class WebViewProgressView: UIView {
    
    var progress: Float = 0.0
    var progressBarView: UIView
    var barAnimationDuration: NSTimeInterval = 0.1
    var fadeAnimationDuration: NSTimeInterval = 0.27
    var fadeOutDelay: NSTimeInterval = 0.1
    override public var tintColor: UIColor! {
        didSet {
            progressBarView.backgroundColor = tintColor
        }
    }
    
    // MARK: Initializer
    public override init(frame: CGRect) {
        progressBarView = UIView(frame: frame)
        super.init(frame: frame)
        self.userInteractionEnabled = false
        self.autoresizingMask = .FlexibleWidth
        self.tintColor = UIColor(red: 22/255, green: 126/255, blue: 251/255, alpha: 1.0) // Default tint colors

        progressBarView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(progressBarView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: Public Method
    public func setProgress(progress: Float, animated: Bool = false) {
        let isGrowing = progress > 0.0
        UIView.animateWithDuration((isGrowing && animated) ? barAnimationDuration : 0.0, delay: 0.0, options: .CurveEaseInOut, animations: {
            var frame = self.progressBarView.frame
            frame.size.width = CGFloat(progress) * self.bounds.size.width
            self.progressBarView.frame = frame
        }, completion: nil)
        
        if progress >= 1.0 {
            UIView.animateWithDuration(animated ? fadeAnimationDuration : 0.0, delay: fadeOutDelay, options: .CurveEaseInOut, animations: {
                self.progressBarView.alpha = 0.0
                }, completion: {
                    completed in
                    var frame = self.progressBarView.frame
                    frame.size.width = 0
                    self.progressBarView.frame = frame
            })
        } else {
            UIView.animateWithDuration(animated ? fadeAnimationDuration : 0.0, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.progressBarView.alpha = 1.0
            }, completion: nil)
        }
    }
}
