//
//  UserDefaults.swift
//  DollarMoreRefactor
//
//  Created by 정준영 on 2023/06/15.
//

import UIKit

@propertyWrapper
struct UserDefault<T> {
    private let key: String
    private let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

struct IsLogin {
    @UserDefault(key: keyEnum.isLogin.rawValue, defaultValue: false)
    static var launchedBefore: Bool
}

enum keyEnum: String {
    case isLogin = "isLogin"
}

