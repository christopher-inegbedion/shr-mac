//
//  WelcomePage.swift
//  Shr
//
//  Created by Christopher Inegbedion on 14/02/2023.
//

import Cocoa

class WelcomePage: NSViewController {

    @IBOutlet weak var topLabel: NSTextField!
    @IBOutlet weak var bottomLabel: NSTextField!
    @IBOutlet weak var logoImageView: NSImageView!
    @IBOutlet weak var setupAccountBtn: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    var animation: NSViewAnimation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        topLabel.stringValue = "Welcome To"
        bottomLabel.stringValue = "The File Platform"
        
        topLabel.alphaValue = 0
        bottomLabel.alphaValue = 0
        logoImageView.alphaValue = 0
        setupAccountBtn.alphaValue = 0
        
        loadingIndicator.alphaValue = 0
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
//        playWelcomeSound()
        performWelcomeAnimation()
    }
    
    private func playWelcomeSound() {
        let audio = NSSound(named: "shr-intro.mp3")
        audio?.play()
    }
    
    private func performWelcomeAnimation() {
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            ctx.duration = 1
            
            topLabel.animator().alphaValue = 1
        } completionHandler: {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                ctx.duration = 1
                
                self.bottomLabel.animator().alphaValue = 1
                self.logoImageView.animator().alphaValue = 1
            } completionHandler: {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    NSAnimationContext.runAnimationGroup { ctx in
                        self.setupAccountBtn.animator().alphaValue = 1
                    }
                })
            }
        }
        
        
    }
    
    @IBAction
    func action(_ sender: NSButton) {
        self.loadingIndicator.startAnimation(self)
        
        NSAnimationContext.runAnimationGroup { context in
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            self.setupAccountBtn.animator().alphaValue = 0
            self.loadingIndicator.animator().alphaValue = 1
        }
        
        DispatchQueue.main.async {
            let isUserRegistered = Account.isUserRegistered()
            
            if isUserRegistered {
                let homePage = HomePage(nibName: "HomePage", bundle: nil)
                self.addChild(self)
                self.addChild(homePage)
                self.transition(from: self, to: homePage, options: .crossfade)
                
            } else {
                let registrationPage = RegistrationPage(nibName: "RegistrationPage", bundle: nil)
                self.addChild(self)
                self.addChild(registrationPage)
                self.transition(from: self, to: registrationPage, options: .crossfade)
                
            }
        }
    }
    
}
