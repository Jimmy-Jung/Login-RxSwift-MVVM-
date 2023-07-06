//
//  LoginViewModel.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/05.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel {
    
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let emailValid = BehaviorRelay<Bool>(value: false)
    let passwordValid = BehaviorRelay<Bool>(value: false)
    let everythingValid = BehaviorRelay<Bool>(value: false)
    let loginTapped = PublishRelay<Void>()
    let loginSuccess = PublishRelay<Void>()
    let emailErrorMessage = PublishRelay<String>()
    let passwordErrorMessage = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        setup()
        setupLoginTapped()
    }
    
    private func setup() {
        email
            .map { $0.isValidEmail() }
            .bind(to: emailValid)
            .disposed(by: disposeBag)
        
        password
            .map { $0.isValidPassword() }
            .bind(to: passwordValid)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(emailValid, passwordValid) { $0 && $1 }
            .bind(to: everythingValid)
            .disposed(by: disposeBag)
        
    }

    
    private func setupLoginTapped() {
        loginTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                self.login()
                print("로그인 버튼 탭드")
                if self.accountCheck {
                    print("어카운트 체크드")
                    loginSuccess.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func login() {
        if email.value.isEmpty {
            emailErrorMessage.accept("이메일을 입력해주세요.")
            return
        }
        
        if password.value.isEmpty {
            passwordErrorMessage.accept("비밀번호를 입력해주세요.")
            return
        }
        
        if !accountCheck {
            emailErrorMessage.accept("등록되지 않은 이메일 입니다.")
            return
        }
        if !accountCheck {
            passwordErrorMessage.accept("비밀번호가 올바르지 않습니다.")
            return
        }
        
    }
    
    private var accountCheck: Bool {
        return email.value == DV.Account.defaultEmail
        && password.value == DV.Account.defaultPassword
        ? true : false
    }
}
