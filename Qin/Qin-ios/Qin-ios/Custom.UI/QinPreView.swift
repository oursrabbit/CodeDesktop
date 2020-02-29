//
//  QinPreView.swift
//  Qin-ios
//
//  Created by 杨璨 on 2020/1/6.
//  Copyright © 2020 canyang. All rights reserved.
//

import AVFoundation
import UIKit

class QinPreView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let previewLayer = layer as! AVCaptureVideoPreviewLayer
        layer.cornerRadius = 90
        return previewLayer
    }
}
