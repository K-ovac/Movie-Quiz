import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Properties
    
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Outlets
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButtonOutlets: UIButton!
    @IBOutlet weak private var yesButtonOutlets: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = Constants.CornerRadius.radius16
        imageView.clipsToBounds = true
        
        imageView.accessibilityIdentifier = Constants.AccessibilityIdentifier.imageView
        counterLabel.accessibilityIdentifier = Constants.AccessibilityIdentifier.counterLabel
        yesButtonOutlets.accessibilityIdentifier = Constants.AccessibilityIdentifier.yesButtonOutlets
        noButtonOutlets.accessibilityIdentifier = Constants.AccessibilityIdentifier.noButtonOutlets
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter?.didAnswer(isYes: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter?.didAnswer(isYes: false)
    }
    
    // MARK: - Factory Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Constants.CornerRadius.radius20
        imageView.layer.borderWidth = Constants.Sizes.size8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
    }
    
    func showResults(quiz result: QuizResultViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = Constants.AccessibilityIdentifier.gameResultAlert
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.presenter?.restartGame()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateButtonsState(isEnabled: Bool) {
        noButtonOutlets.isEnabled = isEnabled
        yesButtonOutlets.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
            self?.presenter?.restartGame(dueTo: .errorWithData)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}
