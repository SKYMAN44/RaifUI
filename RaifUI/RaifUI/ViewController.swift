//
//  ViewController.swift
//  RaifUI
//
//  Created by Дмитрий Соколов on 02.06.2021.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var enterButtonTapped: UIButton!
    @IBOutlet var userTextField: UITextField!
    
    var user: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        enterButtonTapped.backgroundColor = .black
        userTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap) // Add gesture recognizer to background view
    }
    
    @objc func handleTap()
    {
        userTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! UINavigationController
        let dtvc = destination.topViewController as! DealTableViewController
        if let text = userTextField.text {
            dtvc.mainUser = text
        }
    }


}

