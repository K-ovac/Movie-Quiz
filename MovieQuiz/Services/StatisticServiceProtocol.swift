//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Максим Лозебной on 06.09.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(currentGame: GameResult)
}

extension StatisticServiceProtocol {
    func getStatisticsText(correct count: Int, total amount: Int) -> String {
        let statistics = [
            "Ваш результат: \(count)/\(amount)",
            "Количество сыгранных квизов: \(gamesCount)",
            "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))",
            "Средняя точность: \(String(format: "%.2f", totalAccuracy))%"
        ]
        return statistics.joined(separator: "\n")
    }
}
