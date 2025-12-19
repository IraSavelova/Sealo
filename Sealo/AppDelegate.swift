//
//  AppDelegate.swift
//  Sealo
//
//  Created by Ирина on 06.12.2025.
//
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Создаем окно
        window = UIWindow(frame: UIScreen.main.bounds)

        // Устанавливаем StartViewController как стартовый экран
        let startVC = StartViewController()
        window?.rootViewController = startVC
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // пауза игры, если нужно
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // сохраняем данные
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // подготовка к возврату в активное состояние
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // возобновляем задачи
    }
}
