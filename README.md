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
4. 로그인 여부는 userDefault에 저장해서 확인한다.

<img width="350" alt="image" src="[https://github.com/Jimmy-Jung/RxSwift-MVVM-/assets/115251866/eec171ba-6bf1-4ef6-82db-621f60221917](https://github.com/Jimmy-Jung/Login-RxSwift-MVVM-/assets/115251866/e449e721-20b7-48bf-8342-0c0809de9f6f)">
<img width="350" alt="image" src="[https://github.com/Jimmy-Jung/RxSwift-MVVM-/assets/115251866/eec171ba-6bf1-4ef6-82db-621f60221917](https://github.com/Jimmy-Jung/Login-RxSwift-MVVM-/assets/115251866/172f4b74-f1c7-4146-8d70-0d79aa0ce95f)">

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
