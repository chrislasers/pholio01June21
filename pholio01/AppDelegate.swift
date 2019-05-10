//
//  AppDelegate.swift
//  pholio01
//
//  Created by Chris  Ransom on 4/9/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage
import SwiftValidator
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation
import FirebaseFirestore
import UserNotifications
import FacebookShare
import FacebookCore
import FacebookLogin
import FirebaseInstanceID
import FirebaseMessaging



enum GenderFilter: String {
    case male = "Male"
    case female = "Female"
    case both = "Both"
}

enum PairingFilter: String {
    case photographer = "Photographer"
    case model = "Model"
    case guest = "Guest"
    
    case photographerAndModel = "PhotographerAndModel"
    case photographerAndGuest = "PhotographerAndGuest"
    case modelAndGuest = "ModelAndGuest"
    
    case all = "All"
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var ref: DatabaseReference!
    var firebasetorage: Storage?
    let gcmMessageIDKey = "gcm.message_id"
   

    
    weak var viewController: SignInVC?
    
    
    init(viewController: SignInVC?) {
        self.viewController = viewController
    }
    
    
    
    var locationManager: CLLocationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
    
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true

        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        
        DispatchQueue.main.async {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification(notification:)), name :NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        
        // [END register_for_notifications]

        
        
        // Override point for customization after application launch.
        
        //FirebaseApp.configure()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        Database.database().isPersistenceEnabled = true

        
        Auth.auth().addStateDidChangeListener { auth, user in
            
            if user != nil {
                
                print("User Signed In")
                
            } else {
                
                print("User Not Signed In")
            }
        }
        
        
        locationManager = CLLocationManager()
        
        locationManager?.requestWhenInUseAuthorization()
        
        _ = Validator()
        
        //Facebook Login
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    override init() {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    //func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    //    let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    
    //   return handled
    // }
    
    func connectToFcm() {
        // Won't connect since there is no token
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
            Messaging.messaging().shouldEstablishDirectChannel = true
            print("Disconnected from FCM.")
        }
    }
    
    @objc func tokenRefreshNotification(notification: NSNotification) {
        //  print("refresh token call")
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                
                self.connectToFcm()
                
                

                print("Remote instance ID token: \(result.token)")
            }
        }
        // let refreshedToken = FIRInstanceID.instanceID().token()!
        // UserDefaults.standardUserDefaults().set(contents, forKey: "deviceToken");
        // Connect to FCM since connection may have failed when attempted before having a token.
        
        //connectToFcm()
        
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url as URL,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    public func application(_ application: UIApplication, open url: URL,     sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //func applicationDidEnterBackground(_ application: UIApplication) {
        //    Messaging.messaging().shouldEstablishDirectChannel = false
        //    print("Disconnected from FCM.")//
       // }
        
        connectToFcm()

    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connectToFcm()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
  
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID1: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID2: \(messageID)")
        }
        
        
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        
        #if DEVELOPMENT
        //Production
        Messaging.messaging().setAPNSToken(deviceToken as Data, type: .prod)
        #else
        //Develop
        Messaging.messaging().setAPNSToken(deviceToken as Data, type: .sandbox)
        #endif

        
        // With swizzling disabled you must set the APNs token here.
         Messaging.messaging().apnsToken = deviceToken
        
        var token = ""
        
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        print("Registration succeeded!")
        print("Token: ", token)
        
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
         Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            
            
            // Reading message body
            let dict = notification.request.content.userInfo["aps"] as! NSDictionary
            
            var messageBody:String?
            var messageTitle:String = "Alert"
            
            if let alertDict = dict["alert"] as? Dictionary<String, String> {
                messageBody = alertDict["body"]!
                if alertDict["title"] != nil { messageTitle  = alertDict["title"]! }
                
            } else {
                messageBody = dict["alert"] as? String
            }
            
            print("(3)Message body is \(messageBody!) ")
            print("(3)Message messageTitle is \(messageTitle) ")
            
            print("Message ID3: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID4: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        let VC = SignInVC()
        
        
        let token: [String: AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]
        
        VC.postToken(Token: token)
        
        
        
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        Messaging.messaging().shouldEstablishDirectChannel = true

        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
