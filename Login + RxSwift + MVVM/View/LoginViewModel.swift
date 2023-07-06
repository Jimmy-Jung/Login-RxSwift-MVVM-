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
        setupEmail()
        setupPassword()
        setupEverythingValid()
        setupLoginTapped()
    }
    
    private func setupEmail() {
        email
            .map { $0.isValidEmail() }
            .bind(to: emailValid)
            .disposed(by: disposeBag)
    }
    
    private func setupPassword() {
        password
            .map { $0.isValidPassword() }
            .bind(to: passwordValid)
            .disposed(by: disposeBag)
    }
    
    private func setupEverythingValid() {
        Observable.combineLatest(emailValid, passwordValid) { $0 && $1 }
            .bind(to: everythingValid)
            .disposed(by: disposeBag)
    }
    
    private func setupLoginTapped() {
        loginTapped
            .subscribe(onNext: { [weak self] in
                self?.login()
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
        
        if !emailValid.value {
            emailErrorMessage.accept("등록되지 않은 이메일 입니다.")
            return
        }
        if !passwordValid.value {
            passwordErrorMessage.accept("비밀번호가 올바르지 않습니다.")
            return
        }
    }
}
