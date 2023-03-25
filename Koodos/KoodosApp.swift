//
//  KoodosApp.swift
//  Koodos
//
//  Created by Dimas on 20/03/23.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}


@main
struct KoodosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            //Sample Using viewModel
            ImageListView(viewModel: KoodosViewModel())

            //Original View
//            ContentView()
        }
    }
}
