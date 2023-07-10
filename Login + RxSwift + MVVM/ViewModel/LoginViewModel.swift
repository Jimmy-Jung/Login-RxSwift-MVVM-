//
//  LoginViewModel.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/05.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

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
                self.signIn()
            })
            .disposed(by: disposeBag)
        
        
    }
  
    
    private func signIn() {
        
        Auth.auth().signIn(withEmail: email.value, password: password.value) { [weak self] authResult, error in
            if let error = error as? NSError {
                let tx = DV.LoginErrorText.self
            switch error.code {
            case AuthErrorCode.networkError.rawValue:
                self?.emailErrorMessage.accept(tx.internetError)
            case AuthErrorCode.userNotFound.rawValue:
                self?.emailErrorMessage.accept(tx.emailError)
            case AuthErrorCode.wrongPassword.rawValue:
                self?.passwordErrorMessage.accept(tx.passwordError)
            default:
                self?.emailErrorMessage.accept(tx.loginError)
                }
                
            } else {
                self?.loginSuccess.accept(())
            }
            
        }
        
    }
    
    
    
}
