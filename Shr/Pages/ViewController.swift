//
//  ViewController.swift
//  Shr
//
//  Created by Christopher Inegbedion on 13/02/2023.
//

import Cocoa

class ViewController: NSViewController {

    var welcomePageVC: WelcomePage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomePageVC = WelcomePage(nibName: "WelcomePage", bundle: nil)
        welcomePageVC.view.wantsLayer = true
        welcomePageVC.view.layer?.backgroundColor = .white
        self.view.addSubview(welcomePageVC.view)
        welcomePageVC.view.frame = self.view.frame
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func action(_ sender: NSButton) {
        print("sdfsd")
//        let vc = HomePage(nibName: "HomePage", bundle: nil)
////        print(self.nibName)
//        self.addChild(self)
//        self.addChild(vc)
//        self.transition(from: self, to: vc, options: .slideDown)
    }

}

