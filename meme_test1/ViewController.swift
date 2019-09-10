//
//  ViewController.swift
//  meme_test1
//
//  Created by Dustin Mahone on 9/7/19.
//  Copyright © 2019 Dustin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var upperTextField: UITextField!
    @IBOutlet weak var lowerTextField: UITextField!
    @IBOutlet weak var lowerToolBar: UIToolbar!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0
    ]
    
    struct Meme {
        var upperText: String
        var lowerText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imagePickerView.backgroundColor = UIColor.gray
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        upperTextField.backgroundColor = UIColor.clear
        upperTextField.defaultTextAttributes = memeTextAttributes
        upperTextField.textAlignment = .center
        upperTextField.text = "TOP"
        
        lowerTextField.backgroundColor = UIColor.clear
        lowerTextField.defaultTextAttributes = memeTextAttributes
        lowerTextField.textAlignment = .center
        lowerTextField.text = "BOTTOM"
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.upperTextField.delegate = self
        //upperTextField.text = "TOP"
        
        self.lowerTextField.delegate = self
        //lowerTextField.text = "BOTTOM"

    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
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
            fatalError("this didn't work")
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
        if textField.text! == "TOP" {
            upperTextField.text! = ""
        } else if textField.text! == "BOTTOM" {
            lowerTextField.text! = ""
        } else {
            //textField has characters
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if upperTextField.text! == "" {
            upperTextField.text! = "TOP"
        } else if lowerTextField.text! == "" {
            lowerTextField.text! = "BOTTOM"
        } else {
            //textField has characters
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
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notifcation:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        lowerToolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        lowerToolBar.isHidden = false
        
        
        return memedImage
    }
    
    func save() {
        let meme = Meme(upperText: upperTextField.text!, lowerText: lowerTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
}

