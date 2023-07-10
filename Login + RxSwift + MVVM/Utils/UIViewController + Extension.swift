//
//  UIViewController + Extension.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/11.
//

import UIKit.UIViewController

extension UIViewController {
    func defaultAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }
}
