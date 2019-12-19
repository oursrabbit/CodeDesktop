//
//  Preview.swift
//  HttpTest
//
//  Created by 杨璨 on 2019/11/25.
//  Copyright © 2019 canyang. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
