import UIKit
import Foundation

// MARK: - Контроллер логики ежедневного приза
class DailyPrizeController {

    private let user: UserData

    init(user: UserData) {
        self.user = user
    }

    /// Выдаёт ежедневный приз. Возвращает сумму награды
    func claimDailyPrize() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Получаем дату последнего получения приза
        let lastPrizeDay: Date
        if let last = user.lastDailyPrizeDate {
            lastPrizeDay = calendar.startOfDay(for: last)
        } else {
            lastPrizeDay = Date.distantPast
        }

        // Если пользователь уже получил приз сегодня
        if lastPrizeDay == today {
            return 0
        }

        // Вычисляем серию подряд дней
        var streak = Int(user.dailyStreak)
        if let dayDiff = calendar.dateComponents([.day], from: lastPrizeDay, to: today).day {
            streak = dayDiff == 1 ? streak + 1 : 1
        } else {
            streak = 1
        }

        // Обновляем серию и дату последнего получения приза
        user.dailyStreak = Int64(streak)
        user.lastDailyPrizeDate = Date()

        // Вычисляем приз
        let prize = prizeForStreak(streak: streak)
        user.balance += Int64(prize)

        // Сохраняем данные
        UserDatabase.shared.save()

        return prize
    }

    /// Размер приза в зависимости от серии
    private func prizeForStreak(streak: Int) -> Int {
        switch streak {
        case 1: return 50
        case 2: return 75
        case 3: return 100
        case 4: return 150
        case 5: return 200
        default: return 250
        }
    }
}

