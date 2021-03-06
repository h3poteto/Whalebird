//
//  MediaImageView.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/08/27.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class MediaImageView: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(image: UIImage?) {
        super.init(image: image)
    }
    convenience init(image: UIImage!, windowSize: CGRect!) {
        self.init(image: image)
        self.sizeToFit()
        
        // 初期状態では画面に収まるようにリサイズしておく
        if (self.frame.size.width > windowSize.size.width) {
            let scale = windowSize.size.width / self.frame.size.width
            self.frame.size = CGSize(width: windowSize.size.width, height: self.frame.size.height * scale)
        }
        if (self.frame.size.height > windowSize.size.height) {
            let scale = windowSize.size.height / self.frame.size.height
            self.frame.size = CGSize(width: self.frame.size.width * scale, height: windowSize.size.height)
        }
        self.center = CGPoint(x: windowSize.size.width / 2.0, y: windowSize.size.height / 2.0)
        self.isUserInteractionEnabled = true
    }
}
