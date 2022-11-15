//
//  AppDelegate.swift
//  ClassToday
//
//  Created by 박태현 on 2022/03/29.
//

import UIKit
import FirebaseCore
import NaverThirdPartyLogin
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        LocationManager.shared.requestAuthorization()
        
        if let uid = UserDefaultsManager.shared.isLogin() {
            // 로그인 상태인 경우 유저 정보를 UserDefaults에 새로 저장한다(갱신)
            FirestoreManager.shared.readUser(uid: uid) { result in
                switch result {
                case .success(let user):
                    UserDefaultsManager.shared.initUserData(user: user)
                case .failure(let error):
                    print("ERROR \(error.localizedDescription)👩🏻‍🦳")
                }
            }
        }
        
        // MARK: - Naver Login
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.isNaverAppOauthEnable = true // 네이버 앱으로 인증 방식 활성화
        instance?.isInAppOauthEnable = true // SafariViewController로 인증 방식 활성화
        instance?.isOnlyPortraitSupportedInIphone() // 아이폰에서 인증 화면을 세로모드에서만 적용
        instance?.serviceUrlScheme = kServiceAppUrlScheme
        instance?.consumerKey = kConsumerKey
        instance?.consumerSecret = kConsumerSecret
        instance?.appName = kServiceAppName
        
        // MARK: - Kakao Login
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            fatalError()
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        if let key = plist?.object(forKey: "Kakao_Native_App_key") as? String {
            KakaoSDK.initSDK(appKey: key)
        }

        // Launch Screen 호출 시간
        debugPrint("Launch Screen Delay start")
        sleep(3)
        debugPrint("Launch Screen Delay end")
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print(#function)
    }
    
    // MARK: - Naver Login
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
        return true
    }
    
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

