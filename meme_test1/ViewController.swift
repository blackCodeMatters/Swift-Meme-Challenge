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
    @IBOutlet weak var upperNavigationBar: UINavigationBar!
    @IBOutlet weak var lowerToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var memedImage: UIImage!
    var activeTextField = UITextField()
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0
    ]
    
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
    
    func checkShare() {
        //test if image is empty
        if imagePickerView.image == nil {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true
            Memes.Meme(upperText: "", lowerText: "", originalImage: imagePickerView.image!, memedImage: imagePickerView.image!)
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
        self.activeTextField = textField
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
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        lowerToolBar.isHidden = true
        upperNavigationBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        lowerToolBar.isHidden = false
        upperNavigationBar.isHidden = false
        
        return memedImage
    }
    
    func save() {
        let meme = Memes.Meme(upperText: upperTextField.text!, lowerText: lowerTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        generateMemedImage()
        save()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        //controller.completionWithItemsHandler
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        upperTextField.text = "TOP"
        lowerTextField.text = "BOTTOM"
        shareButton.isEnabled = false
        imagePickerView.image = nil
    }
    
}

