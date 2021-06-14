//
//  AddDealTableViewController.swift
//  RaifUI
//
//  Created by Дмитрий Соколов on 03.06.2021.
//

import UIKit
import Foundation

class AddDealTableViewController: UITableViewController,UITextFieldDelegate {
    
    var model = Model(environment: Environment.current, user: "postgres", password: "postgres1")
    
    let loadingView = UIView()
    let spinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    @IBOutlet var doneDismissButton: UIBarButtonItem!
    
    @IBOutlet var idTextField: UITextField!
    @IBOutlet var kindTextField: UITextField!
    @IBOutlet var statusTextField: UITextField!
    @IBOutlet var remarkTextField: UITextField!
    @IBOutlet var versionTextField: UITextField!
    @IBOutlet var datalinkTextField: UITextField!
    @IBOutlet var ownerTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.idTextField.delegate = self
        self.kindTextField.delegate = self
        self.statusTextField.delegate = self
        self.remarkTextField.delegate = self
        self.versionTextField.delegate = self
        self.datalinkTextField.delegate = self
        self.ownerTextField.delegate = self
        doneDismissButton.isEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap) // Add gesture recognizer to background view
        [idTextField, kindTextField, statusTextField,remarkTextField,versionTextField,datalinkTextField,ownerTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
    }

    @IBAction func executeAction(_ sender: Any)
    {
        let id = Int(idTextField.text!)
        let kind = kindTextField.text!
        let status = statusTextField.text!
        let remark = remarkTextField.text!
        let version = versionTextField.text!
        let datalink = datalinkTextField.text!
        let owner = ownerTextField.text!
        var deal = Model.Deal(id: id!, kind: kind, status: status, remark: remark, version: version, datalink: datalink, owner: owner,validation: "false")
        self.setLoadingScreen()
        model.addDealForUser(deal: deal) { result in
            do{
                print(result)
                let deal = try result.get()
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.loadingLabel.text = "sucessfully added"
            }
            catch{
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.loadingLabel.text = "failed"
            }
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(goBack) )
        self.navigationItem.setLeftBarButton(nil, animated: true)
    }
    
    @objc func goBack()
    {
        performSegue(withIdentifier: "backfromadd", sender: self)
    }
    
    @objc func handleTap()
    {
        idTextField.resignFirstResponder() // dismiss keyoard
        kindTextField.resignFirstResponder() // dismiss keyoard
        statusTextField.resignFirstResponder()
        remarkTextField.resignFirstResponder()
        versionTextField.resignFirstResponder()
        datalinkTextField.resignFirstResponder()
        ownerTextField.resignFirstResponder()
    }
    
    @objc func editingChanged(_ textField: UITextField)
    {
        guard
            let id = idTextField.text, !id.isEmpty,
            let kind = kindTextField.text, !kind.isEmpty,
            let status = statusTextField.text, !status.isEmpty,
            let remark = remarkTextField.text, !remark.isEmpty,
            let version = versionTextField.text, !version.isEmpty,
            let datalink = datalinkTextField.text, !datalink.isEmpty,
            let owner = ownerTextField.text, !owner.isEmpty
        else {
            doneDismissButton.isEnabled = false
            return
        }
        doneDismissButton.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    
    private func setLoadingScreen()
    {
        let width: CGFloat = tableView.frame.width
        let height: CGFloat = tableView.frame.height
        loadingView.frame = CGRect(x: 0,y: 0,width: width, height: height)

            // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        let x = (tableView.frame.width / 2) - (120 / 2)
        let y = (tableView.frame.height / 2) - (30 / 2) - (navigationController?.navigationBar.frame.height)!
        loadingLabel.frame = CGRect(x: x, y: y, width: 140, height: 30)

        spinner.style =  .medium
        spinner.frame = CGRect(x: x, y: y, width: 30, height: 30)
        spinner.startAnimating()

        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        loadingView.backgroundColor = .systemBackground
        
        self.tableView.addSubview(loadingView)
    }
    
    private func removeLoadingScreen() {

            // Hides and stops the text and the spinner
            spinner.stopAnimating()
            spinner.isHidden = true
            loadingLabel.isHidden = true

    }

}
