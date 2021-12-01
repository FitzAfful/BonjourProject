//
//  ViewController.swift
//  bonjour-project

import UIKit
import FTIndicator

class ServiceListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var createServiceButton: UIButton!
    
    var browser = BonjourBrowser("_samplehttp._tcp")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ServiceCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        //Search for available services
        browser.start()
        
        browser.services.bind { _ in
            self.tableView.reloadData()
        }
    }
    
    @IBAction func createService() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateService") as! CreateServiceViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ServiceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath)
        cell.textLabel?.text = browser.services.value[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return browser.services.value.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Enter your name", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Connect to service", style: .default) { action in
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            controller.viewModel.service = self.browser.services.value[indexPath.row]
            if let clientName = textField.text {
                controller.viewModel.username = clientName
            } else {
                FTIndicator.showToastMessage("Enter name")
                return
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addTextField { txtField in
            txtField.placeholder = "Name"
            textField = txtField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

