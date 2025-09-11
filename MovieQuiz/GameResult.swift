//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Максим Лозебной on 06.09.2025.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        return self.correct > another.correct
    }
}
