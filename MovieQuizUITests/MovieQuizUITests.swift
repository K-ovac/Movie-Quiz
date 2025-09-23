//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Максим Лозебной on 23.09.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) {
        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Failed to find element \(element)")
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        waitForElement(firstPoster)
        
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let yesButton = app.buttons["Yes"]
        waitForElement(yesButton)
        yesButton.tap()
        
        let secondPoster = app.images["Poster"]
        waitForElement(secondPoster)
        
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        waitForElement(firstPoster)
        
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let noButton = app.buttons["No"]
        waitForElement(noButton)
        noButton.tap()
        
        let secondPoster = app.images["Poster"]
        waitForElement(secondPoster)
        
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        let yesButton = app.buttons["Yes"]
        let noButton = app.buttons["No"]
        
        // Ждём, пока кнопки появятся
        waitForElement(yesButton)
        waitForElement(noButton)
        
        // Проходим 10 вопросов
        for _ in 0..<10 {
            let buttonToTap = [yesButton, noButton].randomElement()!
            waitForElement(buttonToTap)
            buttonToTap.tap()
        }
        
        // Проверяем появление алерта
        let alert = app.alerts["GameResultsAlert"]
        waitForElement(alert, timeout: 10) // увеличиваем таймаут, на случай задержки
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        let yesButton = app.buttons["Yes"]
        let noButton = app.buttons["No"]
        
        waitForElement(yesButton)
        waitForElement(noButton)
        
        // Проходим 10 вопросов
        for _ in 0..<10 {
            let buttonToTap = [yesButton, noButton].randomElement()!
            waitForElement(buttonToTap)
            buttonToTap.tap()
        }
        
        // Ожидаем алерт
        let alert = app.alerts["GameResultsAlert"]
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: alert)
        waitForExpectations(timeout: 10)
        
        XCTAssertTrue(alert.exists)
        
        // Закрываем алерт
        alert.buttons.firstMatch.tap()
        
        // Ждём, пока алерт исчезнет
        let notExistsPredicate = NSPredicate(format: "exists == false")
        expectation(for: notExistsPredicate, evaluatedWith: alert)
        waitForExpectations(timeout: 5)
        
        // Проверяем, что счетчик сбросился
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
