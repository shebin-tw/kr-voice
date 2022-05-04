//
//  REcordingButton.swift
//  KRVoice
//
//  Created by Shebin Koshy on 12/04/22.
//

import Foundation
import UIKit

@IBDesignable
public class RecordingButton: UIButton {
  
  @IBInspectable public var pulseColor: UIColor = hexStringToUIColor(hex: "#FF5733")//#FF9900
  @IBInspectable public var pulseDuration: CGFloat = 0.51
  @IBInspectable public var pulseRadius: CGFloat = 3.0
  
  private lazy var mainLayer: CAShapeLayer = { [unowned self] in
    let layer = CAShapeLayer()
    layer.bounds = self.bounds;
    layer.cornerRadius = self.bounds.width / 2;
    layer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
    layer.zPosition = -1;
    return layer
    }()
  
  private lazy var animationGroup: CAAnimationGroup = {
    let animationGroup = CAAnimationGroup()
    animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
    animationGroup.duration = CFTimeInterval(self.pulseDuration)
    return animationGroup
  }()
  
  private var isAnimating = false
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.layer.addSublayer(mainLayer)
      self.setTitle("", for: .normal)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.layer.addSublayer(mainLayer)
  }
  
  public func animate(_ animate: Bool) {
      if isAnimating == true && animate == true {
          //already animating
          return
      }
    isAnimating = animate
    handleAnimations()
  }
  
  private func handleAnimations() {
    if !isAnimating {
      return
    }
    
    let animation = createAnimation()
      self.layer.insertSublayer(animation, at: 0)
//    self.layer.insertSublayer(animation, below: mainLayer)
    animation.add(animationGroup, forKey: "pulse")
    let after: DispatchTime = .now() + pulseDuration
    DispatchQueue.main.asyncAfter(deadline: after) { [weak self] in
        self?.isAnimating = false
    }
  }
  
  private func createAnimation() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.backgroundColor = pulseColor.cgColor;
    layer.bounds = self.bounds;
    layer.cornerRadius = self.bounds.width / 2;
    layer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2);
    
    layer.contentsScale = UIScreen.main.scale
    layer.zPosition = -2;
    layer.opacity = 0
    return layer
  }
  
  private func createScaleAnimation() -> CABasicAnimation {
    let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
    scaleAnimation.fromValue = 1
    scaleAnimation.toValue = pulseRadius + 1
    scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    return scaleAnimation
  }
  
  private func createOpacityAnimation() -> CAKeyframeAnimation {
    let animation = CAKeyframeAnimation(keyPath: "opacity")
    animation.values = [0.8, 0.4, 0]
    animation.keyTimes = [0.0, 0.5, 1.0]
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    return animation
  }
}

enum RecordingStatus {
    case startRecording, endRecording, error
}

private extension Bundle {
  static var voiceOverlayBundle: Bundle {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: RecordingButton.self)
    #endif
  }
}

@available(iOS 10.0, *)
extension RecordingButton {
    func setimage(_ isRecording: Bool) {
    }
    
    func playSound(with recordingStatus: RecordingStatus){
    }
}


func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
