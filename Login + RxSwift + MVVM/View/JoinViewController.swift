//
//  JoinViewController.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/10.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

final class JoinViewController: UIViewController {
    
    private var joinView = JoinView()
    private let viewModel = JoinViewModel()
    private let disposeBag = DisposeBag()
    private lazy var textFields = [joinView.emailTextField, joinView.passwordTextField]
    
    override func loadView() {
        view = joinView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAddTarget()
        setupBindings()
        autoLogin()
    }
    private func autoLogin() {
        joinView.emailTextField.text = DV.Account.defaultEmail
        joinView.passwordTextField.text = DV.Account.defaultPassword
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
        
        joinView.emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        joinView.passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        joinView.passwordSecureButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.joinView.passwordTextField.isSecureTextEntry.toggle()
            })
            .disposed(by: disposeBag)
        
        
        joinView.joinButton.rx.tap
            .bind(to: viewModel.joinTapped)
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        viewModel.emailValid
            .map { $0 ? UIColor.systemGreen : UIColor.kakaoLightBrown}
            .bind(to: joinView.emailInfoLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        viewModel.passwordValid
            .map { $0 ? UIColor.systemGreen : UIColor.kakaoLightBrown}
            .bind(to: joinView.passwordInfoLabel.rx.textColor)
            .disposed(by: disposeBag)
        
        viewModel.everythingValid
            .subscribe(onNext: { [weak self] in
                self?.joinView.joinButton.isEnabled = $0
                self?.joinView.joinButton.backgroundColor = $0 ? .kakaoBrown : .kakaoLightBrown
            })
            .disposed(by: disposeBag)
        
        viewModel.emailErrorMessage
            .subscribe(onNext: { [weak self] in
                self?.joinView.emailInfoLabel.text = $0
                self?.joinView.emailInfoLabel.textColor = .systemRed
                self?.joinView.emailInfoLabel.shake()
            })
            .disposed(by: disposeBag)
        
        viewModel.passwordErrorMessage
            .subscribe(onNext: { [weak self] in
                self?.joinView.passwordInfoLabel.text = $0
                self?.joinView.passwordInfoLabel.textColor = .systemRed
                self?.joinView.passwordInfoLabel.shake()
            })
            .disposed(by: disposeBag)
        
        viewModel.joinSuccess
            .subscribe(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
}

extension JoinViewController {
    // MARK: - 텍스트필드 델리게이트
    //텍스트필드 편집 시작할때의 설정 - 문구가 위로올라가면서 크기 작아지고, 오토레이아웃 업데이트
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == joinView.emailTextField {
            joinView.emailTextFieldView.backgroundColor = .systemGray6
            joinView.emailInfoLabel.font = UIFont.systemFont(ofSize: 11)
            // 오토레이아웃 업데이트
            joinView.emailInfoLabelCenterYConstraint?.update(offset: -13)
        }
        
        if textField == joinView.passwordTextField {
            joinView.passwordTextFieldView.backgroundColor = .systemGray6
            joinView.passwordInfoLabel.font = UIFont.systemFont(ofSize: 11)
            // 오토레이아웃 업데이트
            joinView.passwordInfoLabelCenterYConstraint?.update(offset: -13)
        }
        
        // 실제 레이아웃 변경은 애니메이션으로 줄꺼야
        UIView.animate(withDuration: 0.2) {
            self.joinView.stackView.layoutIfNeeded()
        }
    }
    
    
    // 텍스트필드 편집 종료되면 백그라운드 색 변경 (글자가 한개도 입력 안되었을때는 되돌리기)
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == joinView.emailTextField {
            joinView.emailTextFieldView.backgroundColor = .systemBackground
            // 빈칸이면 원래로 되돌리기
            if joinView.emailTextField.text == "" {
                joinView.emailInfoLabel.font = UIFont.systemFont(ofSize: 18)
                joinView.emailInfoLabelCenterYConstraint?.update(offset: -3)
            }
        }
        if textField == joinView.passwordTextField {
            joinView.passwordTextFieldView.backgroundColor = .systemBackground
            // 빈칸이면 원래로 되돌리기
            if joinView.passwordTextField.text == "" {
                joinView.passwordInfoLabel.font = UIFont.systemFont(ofSize: 18)
                joinView.passwordInfoLabelCenterYConstraint?.update(offset: -3)
            }
        }
        
        // 실제 레이아웃 변경은 애니메이션으로 줄꺼야
        UIView.animate(withDuration: 0.3) {
            self.joinView.stackView.layoutIfNeeded()
        }
    }
}

