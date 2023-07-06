//
//  UIView + Extension.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/06.
//

import UIKit.UIView

extension UIView {
    //로그인 오류시 글씨 흔들기
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.08
        shake.repeatCount = 2
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))

        self.layer.add(shake, forKey: "position")
    }
}
