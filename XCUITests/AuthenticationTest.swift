//
//  AuthenticationTest.swift
//  Client
//
//  Created by mozilla on 12/20/16.
//  Copyright © 2016 Mozilla. All rights reserved.
//

import XCTest

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}

class AuthenticationTest: BaseTestCase {
        
    override func setUp() {
        super.setUp()
        dismissFirstRunUI()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private func openAuthenticationManager() {
        let app = XCUIApplication()
        app.buttons["TabToolbar.menuButton"].tap()
        app.collectionViews.cells["SettingsMenuItem"].tap()
        
        let appsettingstableviewcontrollerTableviewTable = app.tables["AppSettingsTableViewController.tableView"]
        waitforExistence(appsettingstableviewcontrollerTableviewTable.cells["TouchIDPasscode"])
        appsettingstableviewcontrollerTableviewTable.cells["TouchIDPasscode"].tap()
        waitforExistence(app.staticTexts["Passcode"])
    }

    private func closeAuthenticationManager() {
        let app = XCUIApplication()

        app.navigationBars["Passcode"].buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["AppSettingsTableViewController.navigationItem.leftBarButtonItem"].tap()
    }
    
    private func disablePasscode(passCode: String) {
        let app = XCUIApplication()
        
        app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode Off"].tap()
        waitforExistence(app.staticTexts["Enter passcode"])
        app.keys[passCode[0]].tap()
        app.keys[passCode[1]].tap()
        app.keys[passCode[2]].tap()
        app.keys[passCode[3]].tap()
        waitforExistence(app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode On"])
    }
    
    private func enablePasscode(passCode: String) {
        let app = XCUIApplication()
        
        app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode On"].tap()
        waitforExistence(app.staticTexts["Enter a passcode"])
        app.keys[passCode[0]].tap()
        app.keys[passCode[1]].tap()
        app.keys[passCode[2]].tap()
        app.keys[passCode[3]].tap()
        waitforExistence(app.staticTexts["Re-enter passcode"])
        app.keys[passCode[0]].tap()
        app.keys[passCode[1]].tap()
        app.keys[passCode[2]].tap()
        app.keys[passCode[3]].tap()
        waitforExistence(app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode Off"])
     }

    // Sets the passcode and interval (set to immediately)
    func testTurnOnOff() {
        let app = XCUIApplication()

        openAuthenticationManager()
        enablePasscode("1337")
        XCTAssertTrue(app.staticTexts["Immediately"].exists)
        
        disablePasscode("1337")
        closeAuthenticationManager()
    }
    
    func testChangePassCode() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        app.staticTexts["Change Passcode"].tap()
        waitforExistence(app.staticTexts["Enter passcode"])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Enter a new passcode"])
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Re-enter passcode"])
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode Off"])

        disablePasscode("2337")
        closeAuthenticationManager()
    }
    
    func testChangePasscodeShowsErrorStates() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        app.staticTexts["Change Passcode"].tap()
        waitforExistence(app.staticTexts["Enter passcode"])
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Incorrect passcode. Try again (Attempts remaining: 2)."])
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Incorrect passcode. Try again (Attempts remaining: 1)."])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Enter a new passcode"])
        
        // Enter same passcode as new one
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["New passcode must be different than existing code."])
        
        // Enter mismatched passcode
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Re-enter passcode"])
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Passcodes didn't match. Try again."])
        XCTAssertTrue(app.staticTexts["Enter a new passcode"].exists)
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Re-enter passcode"])
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode Off"])
        
        disablePasscode("2337")
        closeAuthenticationManager()
    }
    
    func testChangeRequirePasscodeInterval() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        let authenticationmanagerSettingstableviewTable = app.tables["AuthenticationManager.settingsTableView"]
        authenticationmanagerSettingstableviewTable.staticTexts["Require Passcode"].tap()
        
        waitforExistence(app.staticTexts["Enter Passcode"])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Immediately"])
        XCTAssertTrue(app.staticTexts["After 1 minute"].exists)
        XCTAssertTrue(app.staticTexts["After 5 minutes"].exists)
        XCTAssertTrue(app.staticTexts["After 10 minutes"].exists)
        XCTAssertTrue(app.staticTexts["After 15 minutes"].exists)
        XCTAssertTrue(app.staticTexts["After 1 hour"].exists)
        
        app.staticTexts["After 15 minutes"].tap()
        app.navigationBars["Require Passcode"].buttons["Passcode"].tap()
        waitforExistence(authenticationmanagerSettingstableviewTable.staticTexts["After 15 minutes"])
        
        // Since we set to 15 min, won't ask for password again, set to immediately
        // Currently it asks for passcode, raised Bug 1325439
        authenticationmanagerSettingstableviewTable.staticTexts["Require Passcode"].tap()
        waitforExistence(app.staticTexts["Immediately"])
        XCTAssertTrue(app.staticTexts["After 1 minute"].exists)
        XCTAssertTrue(app.staticTexts["After 5 minutes"].exists)
        XCTAssertTrue(app.staticTexts["After 10 minutes"].exists)
        XCTAssertTrue(app.staticTexts["After 15 minutes"].exists)
        XCTAssertTrue(app.staticTexts["After 1 hour"].exists)
        app.navigationBars["Require Passcode"].buttons["Passcode"].tap()
        
        disablePasscode("1337")
        closeAuthenticationManager()
    }
    
    func  testEnteringLoginsUsingPasscode() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        app.navigationBars["Passcode"].buttons["Settings"].tap()

        // Enter login
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"].tap()
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.tables["Login List"])
        app.navigationBars["Logins"].buttons["Settings"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        
        // Trying again should display passcode screen since we've set the interval to be immediately.
        app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"].tap()
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.tables["Login List"])
        app.navigationBars["Logins"].buttons["Settings"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.navigationBars["Settings"].buttons["AppSettingsTableViewController.navigationItem.leftBarButtonItem"].tap()
    }

    func testEnteringLoginsUsingPasscodeWithFiveMinutesInterval() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        app.tables["AuthenticationManager.settingsTableView"].staticTexts["Require Passcode"].tap()
        
        waitforExistence(app.staticTexts["Enter Passcode"])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["After 5 minutes"])
        app.staticTexts["After 5 minutes"].tap()
        app.navigationBars["Require Passcode"].buttons["Passcode"].tap()
        waitforExistence(app.tables["AuthenticationManager.settingsTableView"].staticTexts["After 5 minutes"])
        app.navigationBars["Passcode"].buttons["Settings"].tap()
        
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"].tap()
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.tables["Login List"])
        app.navigationBars["Logins"].buttons["Settings"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        
        // Trying again should not display the passcode screen since the interval is 5 minutes
        app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"].tap()
        waitforExistence(app.tables["Login List"])
        app.navigationBars["Logins"].buttons["Settings"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.navigationBars["Settings"].buttons["AppSettingsTableViewController.navigationItem.leftBarButtonItem"].tap()
    }

    func testEnteringLoginsWithNoPasscode() {
        let app = XCUIApplication()
        
        // it is disabled
        openAuthenticationManager()
        waitforExistence(app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode On"])
        app.navigationBars["Passcode"].buttons["Settings"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        
        app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"].tap()
        waitforExistence(app.tables["Login List"])
        app.navigationBars["Logins"].buttons["Settings"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.navigationBars["Settings"].buttons["AppSettingsTableViewController.navigationItem.leftBarButtonItem"].tap()
    }

    func testWrongPasscodeDisplaysAttemptsAndMaxError() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        app.tables["AuthenticationManager.settingsTableView"].staticTexts["Require Passcode"].tap()
        
        waitforExistence(app.staticTexts["Enter Passcode"])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["After 5 minutes"])
        app.staticTexts["After 5 minutes"].tap()
        app.navigationBars["Require Passcode"].buttons["Passcode"].tap()
        waitforExistence(app.tables["AuthenticationManager.settingsTableView"].staticTexts["After 5 minutes"])
        app.navigationBars["Passcode"].buttons["Settings"].tap()
 
        // Enter wrong passcode
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"].tap()
        waitforExistence(app.staticTexts["Enter Passcode"])
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Incorrect passcode. Try again (Attempts remaining: 2)."])
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Incorrect passcode. Try again (Attempts remaining: 1)."])
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Maximum attempts reached. Please try again later."])
        app.navigationBars["Enter Passcode"].buttons["Cancel"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.navigationBars["Settings"].buttons["AppSettingsTableViewController.navigationItem.leftBarButtonItem"].tap()
      }

    func testWrongPasscodeAttemptsPersistAcrossEntryAndConfirmation() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        app.navigationBars["Passcode"].buttons["Settings"].tap()
        
        // Enter wrong passcode on Logins
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"].tap()
        waitforExistence(app.staticTexts["Enter Passcode"])
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Incorrect passcode. Try again (Attempts remaining: 2)."])
        app.navigationBars["Enter Passcode"].buttons["Cancel"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        
        // Go back to Passcode, and enter a wrong passcode, notice the error count
        let appsettingstableviewcontrollerTableviewTable = app.tables["AppSettingsTableViewController.tableView"]
        waitforExistence(appsettingstableviewcontrollerTableviewTable.cells["TouchIDPasscode"])
        appsettingstableviewcontrollerTableviewTable.cells["TouchIDPasscode"].tap()
        waitforExistence(app.staticTexts["Passcode"])
        app.staticTexts["Change Passcode"].tap()
        waitforExistence(app.staticTexts["Enter passcode"])
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Incorrect passcode. Try again (Attempts remaining: 1)."])
        app.navigationBars["Change Passcode"].buttons["Cancel"].tap()
        closeAuthenticationManager()
    }

    func testChangedPasswordMustBeNew() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        app.staticTexts["Change Passcode"].tap()
        waitforExistence(app.staticTexts["Enter passcode"])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Enter a new passcode"])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["New passcode must be different than existing code."])
        app.navigationBars["Change Passcode"].buttons["Cancel"].tap()
        
        disablePasscode("1337")
        closeAuthenticationManager()
    }

    func testPasscodesMustMatchWhenCreating() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode On"].tap()
        waitforExistence(app.staticTexts["Enter a passcode"])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Re-enter passcode"])
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Passcodes didn't match. Try again."])
        waitforExistence(app.staticTexts["Enter a passcode"])
        app.navigationBars["Set Passcode"].buttons["Cancel"].tap()
        closeAuthenticationManager()
    }

    func testPasscodeMustBeCorrectWhenRemoving() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        XCTAssertTrue(app.staticTexts["Immediately"].exists)
        app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode Off"].tap()
        waitforExistence(app.staticTexts["Enter passcode"])
        app.keys["2"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Incorrect passcode. Try again (Attempts remaining: 2)."])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.tables["AuthenticationManager.settingsTableView"].staticTexts["Turn Passcode On"])
        closeAuthenticationManager()
    }

    func testChangingIntervalResetsValidationTimer() {
        let app = XCUIApplication()
        
        openAuthenticationManager()
        enablePasscode("1337")
        app.navigationBars["Passcode"].buttons["Settings"].tap()
        
        // Enter login
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"].tap()
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.tables["Login List"])
        app.navigationBars["Logins"].buttons["Settings"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        
        let appsettingstableviewcontrollerTableviewTable = app.tables["AppSettingsTableViewController.tableView"]
        waitforExistence(appsettingstableviewcontrollerTableviewTable.cells["TouchIDPasscode"])
        appsettingstableviewcontrollerTableviewTable.cells["TouchIDPasscode"].tap()
        waitforExistence(app.staticTexts["Passcode"])
        
        let authenticationmanagerSettingstableviewTable = app.tables["AuthenticationManager.settingsTableView"]
        authenticationmanagerSettingstableviewTable.staticTexts["Require Passcode"].tap()
        
        waitforExistence(app.staticTexts["Enter Passcode"])
        app.keys["1"].tap()
        app.keys["3"].tap()
        app.keys["3"].tap()
        app.keys["7"].tap()
        waitforExistence(app.staticTexts["Immediately"])
        app.staticTexts["After 15 minutes"].tap()
        app.navigationBars["Require Passcode"].buttons["Passcode"].tap()
        waitforExistence(authenticationmanagerSettingstableviewTable.staticTexts["After 15 minutes"])
        app.navigationBars["Passcode"].buttons["Settings"].tap()
        
        // Enter login
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])
        app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"].tap()
        waitforExistence(app.navigationBars["Enter Passcode"])
        app.navigationBars["Enter Passcode"].buttons["Cancel"].tap()
        waitforExistence(app.tables["AppSettingsTableViewController.tableView"].staticTexts["Logins"])

        appsettingstableviewcontrollerTableviewTable.cells["TouchIDPasscode"].tap()
        waitforExistence(app.staticTexts["Passcode"])
        disablePasscode("1337")
        closeAuthenticationManager()
    }
}
