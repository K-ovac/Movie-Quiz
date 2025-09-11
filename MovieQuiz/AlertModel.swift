//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Максим Лозебной on 27.08.2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
