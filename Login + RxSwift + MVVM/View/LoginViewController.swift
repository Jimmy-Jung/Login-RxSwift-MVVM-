//
//  ViewController.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/04.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    private var loginView = LoginView()
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    private lazy var textFields = [loginView.emailTextField, loginView.passwordTextField]
    
    override func loadView() {
        view = loginView
    }
    override func viewDidLoad() {
            super.viewDidLoad()

            setupAddTarget()
            setupBindings()
        loginView.emailTextField.text = DV.Account.defaultEmail
        loginView.passwordTextField.text = DV.Account.defaultPassword
        }

        private func setupAddTarget() {
            
            let tapGesture = UITapGestureRecognizer()
                view.addGestureRecognizer(tapGesture)

                tapGesture.rx.event
                    .subscribe(onNext: { [weak self] _ in
                        self?.view.endEditing(true)
                    })
                    .disposed(by: disposeBag)
            
            textFields.forEach { textField in
                textField.rx.controlEvent([.editingDidBegin,.editingChanged])
                    .subscribe(onNext: { [weak self] in
                        self?.textFieldDidBeginEditing(textField)
                    })
                    .disposed(by: disposeBag)
            }
            
            textFields.forEach { textField in
                textField.rx.controlEvent(.editingDidEnd)
                    .subscribe(onNext: { [weak self] in
                        self?.textFieldDidEndEditing(textField)
                    })
                    .disposed(by: disposeBag)
            }
            
            loginView.emailTextField.rx.text.orEmpty
                .bind(to: viewModel.email)
                .disposed(by: disposeBag)

            loginView.passwordTextField.rx.text.orEmpty
                .bind(to: viewModel.password)
                .disposed(by: disposeBag)

            loginView.passwordSecureButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.loginView.passwordTextField.isSecureTextEntry.toggle()
                })
                .disposed(by: disposeBag)

            viewModel.emailValid
                .map { $0 ? UIColor.systemGreen : UIColor.kakaoLightBrown}
                .bind(to: loginView.emailInfoLabel.rx.textColor)
                .disposed(by: disposeBag)

            viewModel.passwordValid
                .map { $0 ? UIColor.systemGreen : UIColor.kakaoLightBrown}
                .bind(to: loginView.passwordInfoLabel.rx.textColor)
                .disposed(by: disposeBag)

            viewModel.everythingValid
                .subscribe(onNext: { [weak self] in
                    self?.loginView.loginButton.isEnabled = $0
                    self?.loginView.loginButton.backgroundColor = $0 ? .kakaoBrown : .kakaoLightBrown
                })
                .disposed(by: disposeBag)
            
            loginView.loginButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    // 회원가입 버튼 클릭 시 동작하는 코드 구현
                    print("로그인 버튼 눌림")
                    self?.viewModel.loginTapped.accept($0)
                })
//                .bind(to: viewModel.loginTapped)
                .disposed(by: disposeBag)

            viewModel.loginSuccess
                .subscribe(onNext: { [weak self] in
                    IsLogin.launchedBefore = true
                    self?.dismiss(animated: true)
                    
                })
                .disposed(by: disposeBag)

            loginView.joinButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    // 회원가입 버튼 클릭 시 동작하는 코드 구현
                    print("회원가입 버튼 눌림")
                    
                })
                .disposed(by: disposeBag)

            loginView.passwordResetButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    // 비밀번호 재설정 버튼 클릭 시 동작하는 코드 구현
                })
                .disposed(by: disposeBag)
        }

        private func setupBindings() {
            viewModel.emailErrorMessage
                .subscribe(onNext: { [weak self] in
                    self?.loginView.emailInfoLabel.text = $0
                    self?.loginView.emailInfoLabel.textColor = .systemRed
                    self?.loginView.emailInfoLabel.shake()
                })
                .disposed(by: disposeBag)

            viewModel.passwordErrorMessage
                .subscribe(onNext: { [weak self] in
                    self?.loginView.passwordInfoLabel.text = $0
                    self?.loginView.passwordInfoLabel.textColor = .systemRed
                    self?.loginView.passwordInfoLabel.shake()
                })
                .disposed(by: disposeBag)

        }
    

    
}

extension LoginViewController {
    // MARK: - 텍스트필드 델리게이트
    //텍스트필드 편집 시작할때의 설정 - 문구가 위로올라가면서 크기 작아지고, 오토레이아웃 업데이트
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == loginView.emailTextField {
            loginView.emailTextFieldView.backgroundColor = .systemGray6
            loginView.emailInfoLabel.font = UIFont.systemFont(ofSize: 11)
            // 오토레이아웃 업데이트
            loginView.emailInfoLabelCenterYConstraint?.update(offset: -13)
        }
        
        if textField == loginView.passwordTextField {
            loginView.passwordTextFieldView.backgroundColor = .systemGray6
            loginView.passwordInfoLabel.font = UIFont.systemFont(ofSize: 11)
            // 오토레이아웃 업데이트
            loginView.passwordInfoLabelCenterYConstraint?.update(offset: -13)
        }
        
        // 실제 레이아웃 변경은 애니메이션으로 줄꺼야
        UIView.animate(withDuration: 0.2) {
            self.loginView.stackView.layoutIfNeeded()
        }
    }
    
    
    // 텍스트필드 편집 종료되면 백그라운드 색 변경 (글자가 한개도 입력 안되었을때는 되돌리기)
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == loginView.emailTextField {
            loginView.emailTextFieldView.backgroundColor = .systemBackground
            // 빈칸이면 원래로 되돌리기
            if loginView.emailTextField.text == "" {
                loginView.emailInfoLabel.font = UIFont.systemFont(ofSize: 18)
                loginView.emailInfoLabelCenterYConstraint?.update(offset: -3)
            }
        }
        if textField == loginView.passwordTextField {
            loginView.passwordTextFieldView.backgroundColor = .systemBackground
            // 빈칸이면 원래로 되돌리기
            if loginView.passwordTextField.text == "" {
                loginView.passwordInfoLabel.font = UIFont.systemFont(ofSize: 18)
                loginView.passwordInfoLabelCenterYConstraint?.update(offset: -3)
            }
        }
        
        // 실제 레이아웃 변경은 애니메이션으로 줄꺼야
        UIView.animate(withDuration: 0.3) {
            self.loginView.stackView.layoutIfNeeded()
        }
    }
}
