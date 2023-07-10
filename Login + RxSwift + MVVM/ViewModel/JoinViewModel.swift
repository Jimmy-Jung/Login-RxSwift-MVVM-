//
//  JoinViewModel.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/10.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

final class JoinViewModel {
    
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let emailValid = BehaviorRelay<Bool>(value: false)
    let passwordValid = BehaviorRelay<Bool>(value: false)
    let everythingValid = BehaviorRelay<Bool>(value: false)
    let joinTapped = PublishRelay<Void>()
    let joinSuccess = PublishRelay<Void>()
    let emailErrorMessage = PublishRelay<String>()
    let passwordErrorMessage = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        setup()
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
        
        joinTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                self.createUser()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func createUser() {
        let email = email.value
        let password = password.value
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                let code = (error as NSError).code
                switch code {
                case 17007: //이미 가입한 계정일때
                    //로그인 하기
                    Auth.auth().signIn(withEmail: email, password: password)
                    self?.joinSuccess.accept(())
                default:
                    self?.emailErrorMessage.accept(error.localizedDescription)
                }
            }
        }
    }
    
}

