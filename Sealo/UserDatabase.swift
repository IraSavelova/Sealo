//
//  UserDataBase.swift
//  Sealo
//
//  Created by Ирина on 12.12.2025.
//

import Foundation
import CoreData
import UIKit

class UserDatabase {
    
    static let shared = UserDatabase()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error: \(error)")
            }
        }
        return container
    }()
    var currentBoardShape: BoardShape {
            get {
                let saved = UserDefaults.standard.string(forKey: "user_boardShape") ?? "cross"
                return saved == "triangle" ? .triangle : .cross
            }
            set {
                let shapeString = (newValue == .triangle) ? "triangle" : "cross"
                UserDefaults.standard.set(shapeString, forKey: "user_boardShape")
            }
        }
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: — Save user
    func createUser(username: String, password: String) {
        let user = UserData(context: context)
        user.username = username
        user.password = password
        user.balance = 500
        user.lastLoginDate = Date()
        user.lastFortuneDate = Date(timeIntervalSince1970: 0)
        save()
    }

    // MARK: — Login
    func fetchUser(username: String, password: String) -> UserData? {
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)

        return try? context.fetch(request).first
    }

    // MARK: — Update fields
    func updateLastLogin(user: UserData) {
        user.lastLoginDate = Date()
        save()
    }

    func updateLastFortuneGame(user: UserData) {
        user.lastFortuneDate = Date()
        save()
    }

    // MARK: — Save context
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
    // MARK: — Проверка, есть ли у пользователя предмет
    func ownsPegColor(_ color: String, user: UserData) -> Bool {
        let colors = user.ownedPegColors as? [String] ?? []
        return colors.contains(color)
    }

    func ownsBackgroundColor(_ color: String, user: UserData) -> Bool {
        let colors = user.ownedBackgroundColors as? [String] ?? []
        return colors.contains(color)
    }

    // MARK: — Добавление купленного предмета
    func addPegColor(_ color: String, to user: UserData) {
        var colors = user.ownedPegColors as? [String] ?? []
        guard !colors.contains(color) else { return }
        colors.append(color)
        user.ownedPegColors = colors as NSArray
        save()
    }

    func addBackgroundColor(_ color: String, to user: UserData) {
        var colors = user.ownedBackgroundColors as? [String] ?? []
        guard !colors.contains(color) else { return }
        colors.append(color)
        user.ownedBackgroundColors = colors as NSArray
        save()
    }

    // MARK: — Получение всех купленных предметов
    func getOwnedPegColors(for user: UserData) -> [String] {
        return user.ownedPegColors as? [String] ?? []
    }

    func getOwnedBackgroundColors(for user: UserData) -> [String] {
        return user.ownedBackgroundColors as? [String] ?? []
    }
}
