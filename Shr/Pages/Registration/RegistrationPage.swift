//
//  RegistrationPage.swift
//  Shr
//
//  Created by Christopher Inegbedion on 15/02/2023.
//

import Cocoa

class RegistrationPage: NSViewController {

    @IBOutlet weak var fullNameTextField: NSTextField!
    @IBOutlet weak var nicknameTextField: NSTextField!
    @IBOutlet weak var fullNameErrorText: NSTextField!
    @IBOutlet weak var nicknameErrorText: NSTextField!
    var fullnameDelegate = TextFieldDelegate { value in
        return !value.isEmpty
    }
    var nicknameDelegate = TextFieldDelegate { value in
        return !value.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = .white
        
        fullNameErrorText.stringValue = "Full name"
        nicknameErrorText.stringValue = "Nickname"

        fullnameDelegate.onError {
            DispatchQueue.main.async(qos: .userInteractive) { [self] in
                self.fullNameErrorText.stringValue = "Please enter your full name"
                self.fullNameErrorText.textColor = .red

                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.fullNameErrorText.stringValue = "Full name"
                    self.fullNameErrorText.textColor = .gray
                }
            }
        }
        nicknameDelegate.onError {
            self.nicknameErrorText.stringValue = "Please enter a nickname"
            self.nicknameErrorText.textColor = .red

            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.nicknameErrorText.stringValue = "Nickname"
                self.nicknameErrorText.textColor = .gray
            }
        }
        fullNameTextField.delegate = fullnameDelegate
        
        nicknameTextField.delegate = nicknameDelegate
        
    }
    
    func showFullnameError() {
        
    }
    
    func showNicknameError() {
    }
    
    @IBAction func completeAction(_ sender: NSButton) {
        let fullnameValid = self.fullnameDelegate.validate()
        let nicknameValid = self.nicknameDelegate.validate()
        
        if fullnameValid && nicknameValid {
            self.view.window?.setFrame(NSRect(origin: (self.view.window?.frame.origin)!, size: CGSize(width: 1400, height: 600)), display: false, animate: true)
            
            let homepage = HomePage(nibName: "HomePage", bundle: nil)
            self.addChild(self)
            self.addChild(homepage)
            self.transition(from: self, to: homepage, options: .crossfade)
        }
    }
    
}

class TextFieldDelegate: NSObject, NSTextFieldDelegate {
    private var errorAction: (() -> Void)?
    private var validateFunc: ((String) -> Bool)?
    private var value: String = ""
    
    init(validateFunc: @escaping (String) -> Bool) {
        self.validateFunc = validateFunc
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {
            return
        }
        value = textField.stringValue
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {
            return
        }
        value = textField.stringValue
        
        if textField.stringValue.isEmpty {
            (self.errorAction ?? {})()
        }
    }
    
    func validate() -> Bool {
        guard self.validateFunc != nil else {
            return true
        }
        
        if !validateFunc!(value) {
            if self.errorAction != nil {
                self.errorAction!()
            }
            
            return false
        }
        
        return true
    }
    
    func onError(action: @escaping () -> Void) {
        self.errorAction = action
    }
}
