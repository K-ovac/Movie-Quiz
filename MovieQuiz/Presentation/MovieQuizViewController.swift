import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButtonOutlets: UIButton!
    @IBOutlet weak private var yesButtonOutlets: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad called")
        
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        statisticService = StatisticService()
        self.alertPresenter = AlertPresenter(delegate: self)
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.updateButtonsState(isEnabled: true)
            self?.imageView.layer.borderWidth = 0
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didAlertPresent(alert: UIAlertController) {
        present(alert, animated: true)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        updateButtonsState(isEnabled: false)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        updateButtonsState(isEnabled: false)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        hideLoadingIndicator()
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        
        self.showLoadingIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let game = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
            statisticService?.store(currentGame: game)
            
            let viewModel = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            showResults(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showResults(quiz result: QuizResultViewModel) {
        let statisticText = statisticService?.getStatisticsText(correct: correctAnswers, total: questionsAmount) ?? "Статистики нет"
        let alertModel = AlertModel(
            title: result.title,
            message: statisticText,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = .zero
                self.correctAnswers = .zero
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.displayAlert(model: alertModel)
    }
    
    private func updateButtonsState(isEnabled: Bool) {
        noButtonOutlets.isEnabled = isEnabled
        yesButtonOutlets.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: nil)
        alertPresenter?.displayAlert(model: alertModel)
    }
}
