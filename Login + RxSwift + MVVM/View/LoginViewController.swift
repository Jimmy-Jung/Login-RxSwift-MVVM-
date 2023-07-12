//
//  ViewController.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/04.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import Crypto

final class LoginViewController: UIViewController {
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    private var loginView = LoginView()
    private lazy var viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    private lazy var textFields = [loginView.emailTextField, loginView.passwordTextField]
    
    override func loadView() {
        view = loginView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //        navigationController?.navigationBar.isHidden = true
        setupAddTarget()
        setupBindings()
        autoLogin()
        
        
    }
    private func autoLogin() {
        loginView.emailTextField.text = DV.Account.defaultEmail
        loginView.passwordTextField.text = DV.Account.defaultPassword
        loginView.emailTextField.becomeFirstResponder()
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
        
        loginView.loginButton.rx.tap
            .bind(to: viewModel.loginTapped)
            .disposed(by: disposeBag)
        
        loginView.loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.3) {
                    self?.loginView.loginButton.backgroundColor = .kakaoLightBrown
                    self?.loginView.loginButton.layoutIfNeeded()
                }
                UIView.animate(withDuration: 0.3) {
                    self?.loginView.loginButton.backgroundColor = .kakaoBrown
                    self?.loginView.loginButton.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        
        loginView.joinButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.moveToJoinView()
            })
            .disposed(by: disposeBag)
        
        loginView.joinButton.rx.tap
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.3) {
                    self?.loginView.joinButton.backgroundColor = .kakaoLightBrown
                    self?.loginView.joinButton.layoutIfNeeded()
                }
                UIView.animate(withDuration: 0.3) {
                    self?.loginView.joinButton.backgroundColor = .kakaoBrown
                    self?.loginView.joinButton.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        loginView.googleButton.rx.tap
            .subscribe(onNext:  { [weak self] in
                self?.handleGoogleLogin()
            })
            .disposed(by: disposeBag)
        
        loginView.appleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.startSignInWithAppleFlow()
            })
            .disposed(by: disposeBag)
        
        loginView.passwordResetButton.rx.tap
            .subscribe(onNext: {
                // 비밀번호 재설정 버튼 클릭 시 동작하는 코드 구현
            })
            .disposed(by: disposeBag)
        
            
    }
    
    private func setupBindings() {
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
        
        viewModel.loginSuccess
            .subscribe(onNext: { [weak self] in
                IsLogin.launchedBefore = true
                self?.dismiss(animated: true)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.emailErrorMessage
            .subscribe(onNext: { [weak self] in
                self?.loginView.emailInfoLabel.shake(with: $0)
            })
            .disposed(by: disposeBag)
        
        viewModel.passwordErrorMessage
            .subscribe(onNext: { [weak self] in
                self?.loginView.passwordInfoLabel.shake(with: $0)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func moveToJoinView() {
        let vc = JoinViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleGoogleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                // ...
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                // ...
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            // ...
            Auth.auth().signIn(with: credential) { user,_ in
                print(user?.user.displayName)
                self.dismiss(animated: true)
            }
        }
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
            loginView.emailInfoLabel.text = DV.LabelText.emailInfoLabel
            loginView.emailTextFieldView.backgroundColor = .systemBackground
            // 빈칸이면 원래로 되돌리기
            if loginView.emailTextField.text == "" {
                loginView.emailInfoLabel.font = UIFont.systemFont(ofSize: 18)
                loginView.emailInfoLabelCenterYConstraint?.update(offset: -3)
            }
        }
        if textField == loginView.passwordTextField {
            loginView.passwordInfoLabel.text = DV.LabelText.passwordInfoLabel
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

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential, including the user's full name.
      let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                        rawNonce: nonce,
                                                        fullName: appleIDCredential.fullName)
      // Sign in with Firebase.
      Auth.auth().signIn(with: credential) { (authResult, error) in
        if let error = error {
          // Error. If error.code == .MissingOrInvalidNonce, make sure
          // you're sending the SHA256-hashed nonce as a hex string with
          // your request to Apple.
          print(error.localizedDescription)
          return
        }
        // User is signed in to Firebase with Apple.
        // ...
          print(authResult?.user.displayName)
          
          self.dismiss(animated: true)
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}

