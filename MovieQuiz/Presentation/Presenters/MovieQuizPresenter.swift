//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Максим Лозебной on 23.09.2025.
//

import UIKit

// MARK: - MovieQuizViewControllerProtocol

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResults(quiz result: QuizResultViewModel)
    func showAnswerResult(isCorrect: Bool)
    func updateButtonsState(isEnabled: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}

// MARK: - MovieQuizPresenter: QuestionFactoryDelegate

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    
    private let statisticService: StatisticServiceProtocol
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    // MARK: - Init
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Private Methods
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        
        viewController?.showAnswerResult(isCorrect: isCorrect)
        viewController?.updateButtonsState(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            let game = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
            statisticService.store(currentGame: game)
            
            let text = statisticService.getStatisticsText(correct: correctAnswers, total: questionsAmount)
            
            let result = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            viewController?.showResults(quiz: result)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Public Methods
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.updateButtonsState(isEnabled: true)
        }
    }
    
    func restartGame(dueTo reason: ReasonForAlert? = nil) {
        currentQuestionIndex = 0
        correctAnswers = 0
        switch reason {
        case .errorWithData:
            questionFactory?.loadData()
        default:
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = isYes == currentQuestion.correctAnswer
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
