//
//  SelectImageVC.swift
//  pholio01
//
//  Created by Chris  Ransom on 6/3/18.
//  Copyright © 2018 Chris Ransom. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseStorage
import SwiftValidator
import Photos
import FirebaseFirestore
import Alamofire
import FirebaseCore
import BSImagePicker




class SelectImageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UploadImagesPresenterDelegate   {
    
    
    
   
    
    
    @IBOutlet weak var collectionView: UICollectionView!
        
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet weak var pickImageBTN: UIButton!
    
    
    @IBOutlet weak var progressView: UIProgressView!
    
    private var uploadPresenter: UploadPresenter!

    private var uploadImagePresenter: UploadImagePresenter!
    
    
    
   
   
    //var ref: DocumentReference? = nil
    var SelectedAssets = [PHAsset]()
    var PhotoArray = [UIImage]()
    
    
    let testVC = UploadimageCell()
    
    
    func uploadImagesPresenterDidScrollTo(index: Int) {
        func uploadImagesPresenterDidScrollTo(index: Int) {
            pageControl.currentPage = index
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        
        uploadPresenter = UploadPresenter(viewController: self)
        uploadImagePresenter = UploadImagePresenter()
        uploadImagePresenter.delegate = self
        collectionView.dataSource = uploadImagePresenter
        collectionView.delegate = uploadImagePresenter
        
        
        
        
        let button = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "back"), for: .normal)
        //add function for button
        button.addTarget(self, action: #selector(fbButtonPressed), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
        
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 21)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 21)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
        
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser != nil
            {
                print("User Signed In")
                //self.performSegue(withIdentifier: "homepageVC", sender: nil)    }
                
            }  else {
                
                
                print("User Not Signed In")
            }
        }
        
       
        
        pickImageBTN.backgroundColor = UIColor.orange
        pickImageBTN.setTitle("Press Here To Select Image", for: .normal)
        pickImageBTN.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        pickImageBTN.layer.borderWidth = 1.5
       // pickImageBTN.layer.cornerRadius = 4
        pickImageBTN.setTitleColor(UIColor.white, for: .normal)
        //signUp.layer.shadowColor = UIColor.white.cgColor
        // signUp.layer.shadowRadius = 5
        pickImageBTN.layer.shadowOpacity = 0.5
        pickImageBTN.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        
        
        // pickImageBTN.frame = CGRect(x: 300, y: 100, width: 50, height: 50)
        
        //Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            
          //  if error != nil {
                
            //    let emailNotSentAlert = UIAlertController(title: "Email Verification", message: "Verification failed to send: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
            //    emailNotSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            //    self.present(emailNotSentAlert, animated: true, completion: nil)
                
            //    print("Email Not Sent")
           // }
                
           // else {
                
           //     let emailSentAlert = UIAlertController(title: "Email Verification", message: "Verification email has been sent. Please tap on the link in the email to verify your account before you can use the features assoicited within the app", preferredStyle: .alert)
                //emailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
               // self.present(emailSentAlert, animated: true, completion: nil)//
                
             //   print("Email Sent")
            //}
       // })


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // sender object is an instance of UITouch in this case
        let touch = sender as! UITouch
        
        // Access the circleOrigin property and assign preferred CGPoint
        (segue as! OHCircleSegue).circleOrigin = touch.location(in: view)
    }
    
    @objc func fbButtonPressed() {
        
        dismiss(animated: true, completion: nil)

        
        print("Bar Button Pressed")
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func postToken(Token: [String : AnyObject]){
        
        print("FCM Token: \(Token)")
        
        
        ref.child("Users").child((Auth.auth().currentUser?.uid)!).child("fcmToken").child(Messaging.messaging().fcmToken!).updateChildValues(Token)
        
        // self.ref.child("Users").child(self.userID!).setValue(["tokenid":Token])
        
    }
    
    
    
    @IBAction func savePressed(_ sender: Any) {
        
        guard uploadImagePresenter.images.count > 0, let images = uploadImagePresenter.images as? [UIImage] else
            
        {
            print("No Image Selected")
            
            
             let emailNotSentAlert = UIAlertController(title: "More Photos Needed", message: "Please select at least one more photo to continue", preferredStyle: .alert)
              emailNotSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               self.present(emailNotSentAlert, animated: true, completion: nil)
            
            return
        }
        
        let token: [String: AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]

        
        self.postToken(Token: token)

        
performSegue(withIdentifier: "toAddPhoto", sender: self)
       uploadPresenter.createCar(with: images)
       
    }
    
    
    

    func addButton() -> UIBarButtonItem {
        
        return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed(_:)))
    }
    
    func updateProgressView(with percentage: Float) {
        progressView.progress = percentage
    }
    
    func handleError(_ error: String) {
        let alertViewController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertViewController, animated: true, completion: nil)
    }

    
    func userSelectedimage(_ image: UIImage) {
        
        uploadImagePresenter.add(image: image)
        collectionView.reloadData()
        
        let offsetX = collectionView.frame.width * CGFloat(uploadImagePresenter.images.count-1)
        
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0.00), animated: true)
        
        pageControl.numberOfPages = uploadImagePresenter.images.count
        pageControl.currentPage = uploadImagePresenter.images.count-1
    }
    
    
    
    @IBAction func selectImage(_ sender: Any) {
        
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) in
                
            })
        } else {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                
                userSelectedimage(image)
            }
            picker.dismiss(animated: true, completion: nil)
            
        }
    }
    
}


