//
//  AppDelegate.swift
//  taskapp
//
//  Created by Shousei  Murakami on 2020/05/22.
//  Copyright © 2020 shousei.murakami2. All rights reserved.
//

import UIKit
import UserNotifications    // Lesson6_7.2で追加

@UIApplicationMain

 // UNUserNotificationCenterDelegateをLesson6_7.5で追加
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // ユーザに通知の許可を求める --- ここからLesson6_7.2で追加 ---
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        // centerに対してrequestAuthorization(options:completionHandler:)メソッドで、通知、音を使うことを指定して呼び出し
        }
        // --- ここまでLesson6_7.2で追加 ---
        
        center.delegate = self     // Lesson6_7.5で追加
        
        return true
    }
    // アプリの初回起動時にユーザに許可を求めるアラートが表示されるようになる
    
    // アプリがフォアグラウンドの時に通知を受け取ると呼ばれるメソッド --- ここからLesson6_7.5で追加 ---
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    } // --- ここまでLesson6_7.5で追加 ---

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

