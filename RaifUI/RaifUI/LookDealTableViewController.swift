//
//  LookDealTableViewController.swift
//  RaifUI
//
//  Created by Дмитрий Соколов on 02.06.2021.
//

import UIKit

class LookDealTableViewController: UITableViewController, UITextFieldDelegate {

    var model = Model(environment: Environment.current, user: "postgres", password: "postgres1")
    
    var deal : Model.Deal?
    
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var kindLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var remarkLabel: UILabel!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var datalinkLabel: UILabel!
    @IBOutlet var ownerLabel: UILabel!
    
    @IBOutlet var bankParameterUITextField: UITextField!
    
    @IBOutlet var updateStatusButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updateStatusButton.backgroundColor = .systemYellow
        idLabel.text = String((deal?.id)!)
        kindLabel.text = deal?.kind
        statusLabel.text = deal?.status
        remarkLabel.text = deal?.remark
        versionLabel.text = deal?.version
        datalinkLabel.text = deal?.datalink
        ownerLabel.text = deal?.owner
        bankParameterUITextField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap) // Add gesture recognizer to background view
        [bankParameterUITextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
    }
    
    init?(coder: NSCoder, deal: Model.Deal?) {
        self.deal = deal
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTap()
    {
        bankParameterUITextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func updateStatusButtonTapped(_ sender: Any)
    {
        model.updateStatus(id: deal!.id, bankParameter: bankParameterUITextField.text!) { result in
            do{
                //no backend provided
            }
            catch{
                //no backend provided
            }
            
        }
    }
    
    @objc func editingChanged(_ textField: UITextField)
    {
        guard
            let bankParam = bankParameterUITextField.text, !bankParam.isEmpty
        else {
            self.updateStatusButton.isEnabled = false
            return
        }
        self.updateStatusButton.isEnabled = true
    }
    
}
