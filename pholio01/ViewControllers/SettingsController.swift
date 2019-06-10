//
//  SettingsController.swift
//  pholio01
//
//  Created by Chris  Ransom on 4/21/19.
//  Copyright © 2019 Chris Ransom. All rights reserved.
//

import UIKit
import JGProgressHUD
import SDWebImage
import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage


class CustomImagePickerController: UIImagePickerController {
    
    var imageButton: UIButton?
    
}

class SettingsController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // instance properties
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    @objc func handleSelectPhoto(button: UIButton) {
        print("Select photo with button:", button)
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        // how do i set the image on my buttons when I select a photo?
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        
        _ = storageReference.child("User-Gallery").child((Auth.auth().currentUser?.uid)!)
        
        let uid = Auth.auth().currentUser?.uid
        let imgName = NSUUID().uuidString + ".jpg"
        // storage/carImages/image.jpg
        let imagesReference = storageReference.child("User-Gallery").child((Auth.auth().currentUser?.uid)!).child("\(uid!)/photos/\(imgName)")
        
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.70) else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        ref.putData(uploadData, metadata: nil) { (nil, err) in
            if let err = err {
                hud.dismiss()
                print("Failed to upload image to storage:", err)
                return
            }
            
            print("Finished uploading image")
            ref.downloadURL(completion: { (url, err) in
                
                hud.dismiss()
                
                if let err = err {
                    print("Failed to retrieve download URL:", err)
                    return
                }
                
                
                print("Finished getting download url:", url?.absoluteString ?? "")
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                    
                   // self.uploadGalleryUrlToUserNode(contentType: "image", item: (url?.absoluteString)!)

                } else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                  //  self.uploadGalleryUrlToUserNode(contentType: "image", item: (url?.absoluteString)!)

                } else {
                    self.user?.imageUrl3 = url?.absoluteString
                 //   self.uploadGalleryUrlToUserNode(contentType: "image", item: (url?.absoluteString)!)

                }
            })
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imagesReference.putData(uploadData, metadata: metadata, completion: { (metadata, error) in
            guard metadata != nil else {
                //completionBlock(nil, "Error occured")
                
                return
            }
            
            imagesReference.downloadURL(completion: { (metadata, error) in
                if let downloadUrl = metadata {
                    // Make you download string
                    let downloadString = downloadUrl.absoluteString
                    print(downloadString)
                    self.uploadGalleryUrlToUserNode(contentType: "image", item: downloadString)
                    
                   // completionBlock(downloadUrl, nil)
                } else {
                    
                    print(error as Any)
                    // Do something if error
                  //  completionBlock(nil, "Error")
                }
            })
        })
        
    }
    
    
    
    func uploadGalleryUrlToUserNode(contentType: String, item: String) {
        let galleryDict = ["content": contentType,
                           "item": item]
        
        DBService.shared.currentUser.child("User-Gallery").childByAutoId().updateChildValues(galleryDict)
    }
    
    
    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

        
        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        
        fetchCurrentUser()
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    

    
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil else {
            return
        }
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -160
        } else {
            
            view.frame.origin.y = 0
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //textField.becomeFirstResponder
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    
    var user: Users?
    
     func fetchCurrentUser() {
        // fetch some Firestore Data
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("Users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            // fetched our user here
            guard let dictionary = snapshot?.data() else { return }
            self.user = Users(dictionary: dictionary)
            self.loadUserPhotos()
            
            self.tableView.reloadData()
        }
    }
    
     func loadUserPhotos() {
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        default:
            headerLabel.text = "Bio"
        }
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
           cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingDidBegin )
             cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingDidEnd)
             cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingDidEndOnExit )
        case 2:
            cell.textField.placeholder = "Enter Profession"
            cell.textField.text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingDidBegin )
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingDidEnd)
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingDidEndOnExit )
        case 3:
            cell.textField.placeholder = "Enter Age"
            cell.textField.addTarget(self, action: #selector(handleAgeChange)
                , for: .editingChanged)
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingDidBegin )
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingDidEnd)
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingDidEndOnExit )
            if let age = user?.age {
                cell.textField.text = String(age)
            }
        default:
            cell.textField.placeholder = "Enter Bio"
        }
        
        return cell
    }
    
    @objc  func handleNameChange(textField: UITextField) {
        self.user?.name = textField.text
    }
    
    @objc  func handleProfessionChange(textField: UITextField) {
        self.user?.profession = textField.text
    }
    
    @objc  func handleAgeChange(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "")
    }
    
    
    
     func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleCancel))
        ]
    }
    
    @objc  func handleSave() {
        print("Saving our settings data into Firestore")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData: [String: Any] = [
            "uid": uid,
            "fullName": user?.name ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "imageUrl2": user?.imageUrl2 ?? "",
            "imageUrl3": user?.imageUrl3 ?? "",
            "age": user?.age ?? -1,
            "profession": user?.profession ?? ""
        ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        Firestore.firestore().collection("Users").document(uid).setData(docData) { (err) in
            hud.dismiss()
            if let err = err {
                print("Failed to save user settings:", err)
                return
            }
            
            self.performSegue(withIdentifier: "toAddPhoto", sender: nil)
            
            print("Finished saving user info")
        }
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    
}
