//
//  FirstViewController.swift
//  Login + RxSwift + MVVM
//
//  Created by 정준영 on 2023/07/06.
//

import UIKit
import FirebaseAuth

final class FirstViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ⭐️ 로그인화면 띄우기
        
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let name = Auth.auth().currentUser?.displayName
        let dispalyName = name ?? "닉네임 없음"
        let email = Auth.auth().currentUser?.email ?? "고객"
        welcomeLabel.text = """
        환영합니다.
        \(email)님
        \(dispalyName)
        """
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func reset(_ sender: Any) {
        let email = Auth.auth().currentUser?.email ?? ""
        Auth.auth().sendPasswordReset(withEmail: email)
    }
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.welcomeLabel.text = "로그아웃"
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        } catch {
            let error = error as NSError
            defaultAlert(title: DV.LogoutErrorText.title, message: error.localizedDescription)
        }
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
