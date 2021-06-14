//
//  DealTableViewController.swift
//  RaifUI
//
//  Created by Дмитрий Соколов on 02.06.2021.
//

import UIKit
import PostgresClientKit
import Foundation

class DealTableViewController: UITableViewController
{
    var model = Model(environment: Environment.current, user: "postgres", password: "postgres1")
    
    var DealsH = [Model.Deal]()
    
    var mainUser: String?
    
    let errorView = UIView()
    let errorLabel = UILabel()
    let goBackButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshDeals(self)
    }

    @IBAction func refreshDeals(_ sender: Any)
    {
        if let owner = mainUser, owner == "Steve"
        {
            tableView.dataSource = self
            model.dealsForUser(owner) { result in
                do {
                    self.DealsH = try result.get()
                    self.tableView.reloadData()
                } catch {
                // Better error handling goes here...
                    Postgres.logger.severe("Error getting deals: \(String(describing: error))")
                }
            }
        }
        else
        {
            setErrorScreen()
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DealsH.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Id                                                                   Status"
    }
    
    @IBSegueAction func lookDeal(_ coder: NSCoder, sender: Any?) -> LookDealTableViewController? {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            let deal = DealsH[indexPath.row]
            return LookDealTableViewController(coder: coder, deal: deal)
        }else
        {
            return LookDealTableViewController(coder: coder, deal: nil)
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Deal", for: indexPath)

        let deal = DealsH[indexPath.row]
        let text = String(describing: deal.id)
        let detailText = deal.status

        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
    
    @IBAction func unwindToDealsTableView(segue: UIStoryboardSegue) {
    
    }
    
    @IBAction func unwindToDealsTableViewFromAdd(segue: UIStoryboardSegue)
    {
        
    }
    
    // MARK: - ErrorView
    
    private func setErrorScreen()
    {
        let width: CGFloat = self.tableView.frame.width
        let height: CGFloat = self.tableView.frame.height
        print(height)
        errorView.frame = CGRect(x: 0,y: 0,width: width, height: height)
        self.navigationItem.setLeftBarButton(nil, animated: true)
        self.navigationItem.setRightBarButton(nil, animated: true)
        errorLabel.textColor = .yellow
        errorLabel.textAlignment = .center
        errorLabel.text = "Wrong Client"
        let x = (tableView.frame.width / 2) - (120 / 2)
        let y = (tableView.frame.height / 2) - (30 / 2) - (navigationController?.navigationBar.frame.height)!
        errorLabel.frame = CGRect(x: x, y: y, width: 140, height: 30)
        goBackButton.backgroundColor = .yellow
        goBackButton.frame = CGRect(x: x, y: (y + 40), width: 140, height:30)
        goBackButton.setTitle("Go back", for: .normal)
        goBackButton.setTitleColor(.black, for: .normal)
        goBackButton.addTarget(self, action: #selector(goBackTapped), for: .touchUpInside)

        errorView.addSubview(errorLabel)
        errorView.addSubview(goBackButton)
        errorView.backgroundColor = .systemBackground
        
        self.tableView.addSubview(errorView)
    }
    
    @objc func goBackTapped(_ sender: UIButton)
    {
         self.performSegue(withIdentifier: "goToUser", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
