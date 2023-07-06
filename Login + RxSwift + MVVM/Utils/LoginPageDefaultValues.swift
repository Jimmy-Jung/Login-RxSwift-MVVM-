//
//  DefaultValue.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/04.
//

import Foundation
struct DV {
    enum Account {
        static let defaultEmail = "jimmy@google.com"
        static let defaultPassword = "k123456"
    }
    
    enum TextSize {
        static let loginTextViewHeight: CGFloat = 48
    }
    
    enum ImageName {
        static let appLogo: String = "kakaoLOGO"
    }
    
    enum LabelText {
        static let emailInfoLabel = "이메일주소 또는 전화번호"
        static let passwordInfoLabel = "비밀번호"
        static let passwordSecureButton = "표시"
        static let loginButton = "로그인"
        static let joinButton = "회원가입"
        static let passwordResetButton = "비밀번호 재설정"
    }
}

