//
//  CreateServiceViewController.swift
//  bonjour-project
//

import UIKit
import FTIndicator

class CreateServiceViewController: UIViewController {

    var hostServer = BonjourServer()
    var bonjourService: BonjourService?
    @IBOutlet var userNameTF: UITextField!
    @IBOutlet var serviceNameTF: UITextField!
    @IBOutlet var createService: UIButton!
    var username: String?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func createNewService() {
        let service = serviceNameTF.text!
        username = userNameTF.text!

        if(username!.isEmpty) {
            showAlert(title: "Error", message: "Please enter username")
            return
        }

        if(service.isEmpty) {
            showAlert(title: "Error", message: "Please enter service name")
            return
        }

        bonjourService = BonjourService(type: "_samplehttp._tcp", port: 8080, userName: username ?? "", serviceName: service)
        self.bonjourService!.delegate = self.hostServer
        self.bonjourService!.stop()
        self.bonjourService!.start()
        
        moveToCreateService()
    }
    
    func moveToCreateService() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        let vm = ChatViewModel()
        vm.host = true
        vm.hostServer = hostServer
        vm.bonjourService = bonjourService
        vm.hostName = username ?? ""
        controller.viewModel = vm
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String, completionHandler: (() -> Void)? = nil, okButtonText: String = "Okay") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButtonText, style: .default, handler: {(_)  in
            if let handler = completionHandler {
                handler()
            }}
        ))
        self.present(alert, animated: true)
    }
}
