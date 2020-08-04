//
//  InputViewController.swift
//
//
//  Created by Shousei  Murakami on 2020/05/24.
//  Copyright © 2020 shousei.murakami2. All rights reserved.
//

import UIKit
import RealmSwift    // Lesson6_6.10で追加する
import UserNotifications    // Lesson6_7.2で追加する

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()    // Lesson6_6.10で追加する
    var task: Task!  // Lesson6_6.8で追加する
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        categoryTextField.text = task.category
        datePicker.date = task.date
    }
    
    // --- Lesson6_6.10で追加する ---
    override func viewWillDisappear(_ animated: Bool) {

        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.category = self.categoryTextField.text!
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified) // 8/4のメンタリングで{}内に修正
        }
        // --- ここまで追加 ---
        
        setNotification(task: task)    // Lesson6_7.2で追加する
        super.viewWillDisappear(animated)  // Lesson6_6.10で追加する
    }
    
    // タスクのローカル通知を登録する --- ここからLesson6_7.2で追加 ---
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        
        // タイトルと内容を設定　(中身がない場合、メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)" // タイトルがない場合メッセージ無しで音だけの通知になるので「(タイトルなし)」を表示する)
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"     // 中身のメッセージがない。メッセージ無しで音だけの通知になるので「(内容なし)」を表示する)
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    } // --- ここまでLesson6_7.2で追加 ---
    
    
    // Lesson6_6.10で追加する
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}
