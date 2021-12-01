//
//  ChatViewController.swift
//  bonjour-project

import UIKit
import Photos
import PhotosUI
import DTPhotoViewerController
import AVKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTF: UITextField!
    let imagePicker = UIImagePickerController()

    var viewModel: ChatViewModel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView()
        self.imagePicker.delegate = self
        
        if !viewModel.host {
            connectToService()
        }
        
        viewModel.hostServer?.message.bind({ message in
            if let msg = message {
                self.viewModel.messagesList.value.append(msg)
            }
        })
        
        viewModel.client.message.bind({ message in
            if let msg = message {
                self.viewModel.messagesList.value.append(msg)
            }
        })

        viewModel.messagesList.bind { _ in
            self.tableView.reloadData()
        }
        
        tableView.reloadData()
    }

    func connectToService() {
        viewModel.connectToService()
    }
    
    @IBAction func sendMessage() {
        if let txtMessage = messageTF.text {
            let message = Message(sender: (viewModel.username ?? viewModel.hostName) ?? "", message: txtMessage, timestamp: Date(), type: MESSAGE_TYPE.TEXT)
            !viewModel.host ? viewModel.sendMessageFromClient(message) : viewModel.sendMessageFromServer(message)
            self.messageTF.text = ""
        } else {
            showAlert(title: "Error", message: "Please enter a message")
            return
        }
    }

    @IBAction func sendMedia() {
        self.imagePicker.allowsEditing = true
        let alert = UIAlertController(title: "What do you want to send", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Send Video", style: .default) { action in
            self.imagePicker.mediaTypes = [UTType.movie.identifier]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let imageAction = UIAlertAction(title: "Send Image", style: .default) { action in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(action)
        alert.addAction(imageAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)

    }
}

//TableView Delegate methods
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = viewModel.messagesList.value[indexPath.row]
        cell.nameLabel.text = message.sender + " @ \(message.timestamp.formatted())"
        cell.messageLabel.text = message.message
        if let msgImage = message.mediaData {
            if let image = UIImage(data: msgImage) {
                cell.messageImageView.image = image
            } else {
                cell.messageImageView.image = UIImage(named: "video")
            }
        } else {
            cell.messageImageView.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messagesList.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = viewModel.messagesList.value[indexPath.row]
        if message.type == .VIDEO {
            if let av = message.mediaData {
                let asset = av.getAVAsset()
                let item = AVPlayerItem(asset: asset)

                let playerAV = AVPlayer(playerItem: item)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = playerAV
                self.navigationController?.pushViewController(playerViewController, animated: true)
            }
        }

        if message.type == .IMAGE {
            if let msgImage = UIImage(data: message.mediaData!) {
                let viewController = DTPhotoViewerController(referencedView: tableView, image: msgImage)
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
}

//ImagePicker
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let imageData: Data = pickedImage.pngData()!
            let message = Message(sender: (viewModel.username ?? viewModel.hostName) ?? "", message: "", timestamp: Date(), type: MESSAGE_TYPE.IMAGE, mediaData: imageData)
            !viewModel.host ? viewModel.sendDataFromClient(message) : viewModel.sendDataFromServer(message)
        }
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if let data = try? Data(contentsOf: videoUrl) {
                let message = Message(sender: (viewModel.username ?? viewModel.hostName) ?? "", message: "", timestamp: Date(), type: MESSAGE_TYPE.VIDEO, mediaData: data)
                !viewModel.host ? viewModel.sendDataFromClient(message) : viewModel.sendDataFromServer(message)
            }
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
