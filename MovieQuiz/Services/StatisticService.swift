//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Максим Лозебной on 06.09.2025.
//

import Foundation

class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private var correct: Int {
        get {
            return storage.integer(forKey: "correctAnswers")
        }
        set {
            storage.set(newValue, forKey: "correctAnswers")
        }
    }
    
    private enum Keys: String {
        case correct,
             bestGame,
             gamesCount,
             bestGameDate,
             bestGameTotal
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGame.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGame.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        if gamesCount == 0 { return 0 }
        return (Double(correct)/(Double(gamesCount) * 10) * 100)
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGame = GameResult(correct: count, total: amount, date: Date())
        if newGame.isBetterThan(bestGame) {
            bestGame = newGame
        }
        correct += count
        gamesCount += 1
    }
    
    func store(currentGame: GameResult) {
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
        
        correct += currentGame.correct
        gamesCount += 1
    }
}

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private(set) var gamesCount: Int = 0
    private(set) var bestGame: GameResult = GameResult(correct: 0, total: 0, date: Date())
    private(set) var totalAccuracy: Double = 0.0
    
    func store(currentGame: GameResult) {
        gamesCount += 1
        
        let currentAccuracy = Double(currentGame.correct) / Double(currentGame.total) * 100
        totalAccuracy = ((totalAccuracy * Double(gamesCount - 1)) + currentAccuracy) / Double(gamesCount)
        
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
