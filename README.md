# Login-RxSwift-MVVM-
Firebase + Google + Apple 로그인 구현
# 목적

RxSwift + MVVM 기능 학습

SnapKit + Then 기능 학습

---

## 1.  SnapKit + Then 조합으로 UI구현

1. 텍스트와 텍스트크기를 프로퍼티로 따로 관리해준다.
2. UI객체는 Then으로 구현해준다
3. AutoLayout은 SnapKit으로 구현해준다.

<img width="350" alt="image" src="https://github.com/Jimmy-Jung/Login-RxSwift-MVVM-/assets/115251866/f2674b84-3ba9-437f-86d8-67b73656dad7">

- Text와 Size를 구조체에 별도로 생성하고 관리해준다.
```swift
struct DV {
    enum TextSize {
        static let loginTextViewHeight: CGFloat = 48
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
```
- SnapKit과 Then으로 View를 생성해준다
```swift
lazy var emailInfoLabel = UILabel().then {
    $0.text = DV.LabelText.emailInfoLabel
    $0.font = UIFont.systemFont(ofSize: 18)
    $0.textColor = .kakaoLightBrown
}

emailInfoLabel.snp.makeConstraints {
    $0.leading.equalTo(emailTextFieldView).offset(8)
    $0.trailing.equalTo(emailTextFieldView).offset(-8)
    self.emailInfoLabelCenterYConstraint =  $0.centerY.equalTo(emailTextFieldView).offset(-3).constraint
}
```

---

## 2. RxSwift + MVVM

1. TextLabel을 선택하면 PlaceHolderLabel이 애니메이션 효과와 함께 작아진다.
2. email과 password 양식 검사를 통해 PlaceHolderLabel에 표시해준다.
3. email과 password가 맞으면 다음 화면으로 넘어간다.
4. 로그인 여부는 Auth.auth().currentUser?를 통해 확인한다.

<img width="350" alt="image" src="https://github.com/Jimmy-Jung/RxSwift-MVVM-/assets/115251866/eec171ba-6bf1-4ef6-82db-621f60221917">
<img width="350" alt="image" src="https://github.com/Jimmy-Jung/Login-RxSwift-MVVM-/assets/115251866/5cff6347-9c38-4054-aa1c-c1621457464d">

## 로직

- LoginViewController & LoginViewModel
1. 화면을 터치하면 편집을 종료한다.
2. 텍스트필드를 터치를 인식할 수 있게 한다.
3. 텍스트필드와 ViewModel의 email프로퍼티와 바인딩 한다.
4. ViewModel에서 email양식을 검사한다.
5. 양식이 맞으면 플레이스홀더의 색상을 변경한다.

### LoginViewController

```swift
//LoginViewController
private let viewModel = LoginViewModel()
private let disposeBag = DisposeBag()
private lazy var textFields = [loginView.emailTextField, loginView.passwordTextField]

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

loginView.emailTextField.rx.text.orEmpty
                .bind(to: viewModel.email)
                .disposed(by: disposeBag)

viewModel.emailValid
                .map { $0 ? UIColor.systemGreen : UIColor.kakaoLightBrown}
                .bind(to: loginView.emailInfoLabel.rx.textColor)
                .disposed(by: disposeBag)
```

- 텍스트필드를 편집하기 시작하면 플레이스홀더의 위치와 크기를 변경해준다

```swift
//LoginViewController
// MARK: - 텍스트필드 델리게이트
//텍스트필드 편집 시작할때의 설정 - 문구가 위로올라가면서 크기 작아지고, 오토레이아웃 업데이트
func textFieldDidBeginEditing(_ textField: UITextField) {
    
    if textField == loginView.emailTextField {
        loginView.emailTextFieldView.backgroundColor = .systemGray6
        loginView.emailInfoLabel.font = UIFont.systemFont(ofSize: 11)
        // 오토레이아웃 업데이트
        loginView.emailInfoLabelCenterYConstraint?.update(offset: -13)
    }
}
```

### LoginViewModel

- email의 양식을 검사하고 검사한 값을 emailValid와 바인딩 해준다.

```swift
//LoginViewModel
let email = BehaviorRelay<String>(value: "")
let emailValid = BehaviorRelay<Bool>(value: false)
private let disposeBag = DisposeBag()

email
    .map { $0.isValidEmail() }
    .bind(to: emailValid)
    .disposed(by: disposeBag)
```

### UserDefault + PropertyWrapper
- 소셜로그인을 플러그인 하기 전에 사용했던 로그인 상태 확인 방법으로 사용

- 프로퍼티래퍼로 UserDefault 구조체를 감싸서 사용하기 쉽게 만들어준다.

```swift
viewModel.loginSuccess
    .subscribe(onNext: { [weak self] in
        IsLogin.launchedBefore = true
        self?.dismiss(animated: true)
        
    })
    .disposed(by: disposeBag)
```

```swift
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
```

### Google Login

- Firebase를 활용해 구글 계정 연동
  
<img width="759" alt="image" src="https://github.com/Jimmy-Jung/Login-RxSwift-MVVM-/assets/115251866/2b490d98-b2b8-409d-87a5-7d721998ff57">
<img width="953" alt="image" src="https://github.com/Jimmy-Jung/Login-RxSwift-MVVM-/assets/115251866/fc7687d1-6c2c-4507-a5ba-33ed4058cf0d">

- 로그인 성공시 LoginViewController를 dismiss한다.
  
```swift
loginView.googleButton.rx.tap
            .subscribe(onNext:  { [weak self] in
                self?.handleGoogleLogin()
            })
            .disposed(by: disposeBag)

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
            Auth.auth().signIn(with: credential) { _,_ in
                self.dismiss(animated: true)
            }
        }
    }
```

### Apple Login
- 애플 Certificates를 활용해 로그인
- Apple Developer에 접속해 Services IDs애 둥록해준다.

  <img width="1083" alt="image" src="https://github.com/Jimmy-Jung/Login-RxSwift-MVVM-/assets/115251866/eb22bac2-d546-407c-8487-0f21a1f2e141">

- Xcode의 Project에서 +Capability를 클릭해 sign in with Apple을 추가해준다

  <img width="749" alt="image" src="https://github.com/Jimmy-Jung/Login-RxSwift-MVVM-/assets/115251866/35e59150-bb68-4cd7-a1bf-c15c412fcb13">
  <img width="633" alt="image" src="https://github.com/Jimmy-Jung/Login-RxSwift-MVVM-/assets/115251866/9e16bcb6-ed5f-4a41-869d-c07656a799e5">

- 아래 코드를 추가해주면 완성
  
```swift

import AuthenticationServices
import Crypto

// Unhashed nonce.
fileprivate var currentNonce: String?

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
          
          self.dismiss(animated: true)
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}


```
