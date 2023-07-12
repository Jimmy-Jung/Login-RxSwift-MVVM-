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
        static let stackViewSpace: CGFloat = 18
    }
    
    enum ImageName {
        static let appLogo = "kakaoLOGO"
        static let googleLogo = "logo_google"
        static let appleLogo = "logo_apple"
    }
    
    enum LabelText {
        static let emailInfoLabel = "이메일주소 또는 전화번호"
        static let passwordInfoLabel = "비밀번호"
        static let passwordSecureButton = "표시"
        static let loginButton = "로그인"
        static let joinButton = "회원가입"
        static let passwordResetButton = "비밀번호 재설정"
        static let googleButton = "구글로 계속하기"
        static let appleButton = "애플로 계속하기"
    }
    
    enum LoginErrorText {
        static let internetError = "인터넷 연결을 확인해주세요."
        static let emailError = "등록되지 않은 이메일 입니다."
        static let passwordError = "비밀번호가 올바르지 않습니다."
        static let loginError = "로그인에 실패했습니다."
    }
    
    enum LogoutErrorText {
        static let title = "로그아웃 실패"
    }
}

