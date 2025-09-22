//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Максим Лозебной on 27.08.2025.
//

import UIKit
import Foundation

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }
    
    func displayAlert (model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in  model.completion?()
        }
        
        alert.addAction(action)
        delegate?.didAlertPresent(alert:alert)
    }
}
