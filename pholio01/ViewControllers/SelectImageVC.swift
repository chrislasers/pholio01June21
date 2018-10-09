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




class SelectImageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UploadImagesPresenterDelegate   {
    func uploadImagesPresenterDidScrollTo(index: Int) {
        func uploadImagesPresenterDidScrollTo(index: Int) {
            pageControl.currentPage = index
        }
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    @IBOutlet weak var pickImageBTN: UIButton!
    
    
    @IBOutlet weak var progressView: UIProgressView!
    
    private var uploadPresenter: UploadPresenter!

    private var uploadImagePresenter: UploadImagePresenter!
   
   
    var ref: DocumentReference? = nil
    var SelectedAssets = [PHAsset]()
    var PhotoArray = [UIImage]()
    
    
    let testVC = UploadimageCell()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        pickImageBTN.layer.borderWidth = 1
        pickImageBTN.layer.borderColor = UIColor.orange.cgColor
        pickImageBTN.setTitleColor(UIColor.white, for: .normal)
        pickImageBTN.layer.shadowColor = UIColor.white.cgColor
        pickImageBTN.layer.shadowRadius = 5
        pickImageBTN.layer.shadowOpacity = 0.3
        pickImageBTN.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        
        
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
        
        uploadPresenter = UploadPresenter(viewController: self)
        
        uploadImagePresenter = UploadImagePresenter()
        
        collectionView.dataSource = uploadImagePresenter
        collectionView.delegate = uploadImagePresenter
        

        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser?.uid != nil {
                print("Creation of profile SUCCESSFUL")
                
                
            }
                
            else {
                print("User Not Signed In")
                // ...
            }
        }


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
    
    @IBAction func cancelPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func savePressed(_ sender: Any) {
        
        guard uploadImagePresenter.images.count > 1, let images = uploadImagePresenter.images as? [UIImage] else
            
        {
            print("No Image Selected")
            
            
             let emailNotSentAlert = UIAlertController(title: "Photo Selection", message: "Please select at least one more photo to continue", preferredStyle: .alert)
              emailNotSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               self.present(emailNotSentAlert, animated: true, completion: nil)
            
            return
        }
        
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





