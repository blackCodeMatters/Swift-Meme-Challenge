//
//  ViewController.swift
//  meme_test1
//
//  Created by Dustin Mahone on 9/7/19.
//  Copyright © 2019 Dustin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var upperTextField: UITextField!
    @IBOutlet weak var lowerTextField: UITextField!
    @IBOutlet weak var upperNavigationBar: UINavigationBar!
    @IBOutlet weak var lowerToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //Variables and Constants
    var memedImage: UIImage!
    var activeTextField: UITextField?
    
    let upperTextDefault = "ADD IMAGE"
    let lowerTextDefault = "TO BEGIN"
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "impact", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0
    ]
    
    //Lifecycle methods
    override func viewWillAppear(_ animated: Bool) {
        imagePickerView.backgroundColor = UIColor.lightGray
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        upperTextField.backgroundColor = UIColor.clear
        upperTextField.defaultTextAttributes = memeTextAttributes
        upperTextField.textAlignment = .center
        upperTextField.text = upperTextDefault
        
        lowerTextField.backgroundColor = UIColor.clear
        lowerTextField.defaultTextAttributes = memeTextAttributes
        lowerTextField.textAlignment = .center
        lowerTextField.text = lowerTextDefault
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        checkShare()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.upperTextField.delegate = self
        self.lowerTextField.delegate = self

    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //Methods
    func checkShare() {
        if imagePickerView.image == nil {
            shareButton.isEnabled = false
            cancelButton.isEnabled = false
            upperTextField.isEnabled = false
            lowerTextField.isEnabled = false
            
        } else {
            shareButton.isEnabled = true
            cancelButton.isEnabled = true
            upperTextField.isEnabled = true
            lowerTextField.isEnabled = true
        }
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Image selection failed")
        }
        
        imagePickerView.image = image
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        if textField.text! == upperTextDefault {
            upperTextField.text! = ""
        } else if textField.text! == lowerTextDefault {
            lowerTextField.text! = ""
        }
    }
        
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if activeTextField == self.lowerTextField! {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notifcation:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() {
        
        lowerToolBar.isHidden = true
        upperNavigationBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        lowerToolBar.isHidden = false
        upperNavigationBar.isHidden = false

    }
    
    func save() {
        _ = Memes.Meme(upperText: upperTextField.text!, lowerText: lowerTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        generateMemedImage()
        
        let controller = UIActivityViewController(activityItems: [memedImage as Any], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                self.save()
                self.dismiss(animated: false, completion: nil)
            } else {
                //share cancelled
            }
            if let shareError = error {
                print("error while sharing: \(shareError.localizedDescription)")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        upperTextField.text = "ADD IMAGE"
        lowerTextField.text = "TO BEGIN"
        imagePickerView.image = nil
        checkShare()
    }
    
}

