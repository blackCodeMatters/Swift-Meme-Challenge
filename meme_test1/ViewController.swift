//
//  ViewController.swift
//  meme_test1
//
//  Created by Dustin Mahone on 9/7/19.
//  Copyright © 2019 Dustin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {

    //Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var upperTextField: UITextField!
    @IBOutlet weak var lowerTextField: UITextField!
    @IBOutlet weak var upperNavigationBar: UINavigationBar!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lowerToolBar: UIToolbar!
    @IBOutlet weak var pinchLabel: UILabel!
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
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        configureTextField(textField: upperTextField, defaultText: upperTextDefault)
        configureTextField(textField: lowerTextField, defaultText: lowerTextDefault)
        
        subscribeToKeyboardNotifications()
        
        checkShare()
        checkBackground()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.upperTextField.delegate = self
        self.lowerTextField.delegate = self
        
        _ = viewForZooming(in: scrollView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //Methods    
    func configureTextField(textField: UITextField, defaultText: String) {
        textField.backgroundColor = UIColor.clear
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = defaultText
    }
    
    func checkBackground() {
        if imagePickerView.image == nil {
            imagePickerView.backgroundColor = UIColor.lightGray
            pinchLabel.isHidden = true
        } else {
            imagePickerView.backgroundColor = UIColor.black
            pinchLabel.isHidden = false
            UIView.animate(withDuration: 5.0, animations: { () -> Void in
                self.pinchLabel.alpha = 0
                self.pinchLabel.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            })
        }
    }
    
    func checkShare() {
        let isEnabled = imagePickerView.image != nil
        shareButton.isEnabled = isEnabled
        cancelButton.isEnabled = isEnabled
        upperTextField.isEnabled = isEnabled
        lowerTextField.isEnabled = isEnabled
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imagePickerView
    }
    
    func presentImagagePickerWith(sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        presentImagagePickerWith(sourceType: .camera)
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        presentImagagePickerWith(sourceType: .photoLibrary)
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
        if (textField.text! == upperTextDefault) || (textField.text! == lowerTextDefault) {
            textField.text! = ""
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
    
    func configureBars(_ isHidden: Bool) {
        upperNavigationBar.isHidden = isHidden
        lowerToolBar.isHidden = isHidden
    }
    
    func generateMemedImage() {
        configureBars(true)
        
        UIGraphicsBeginImageContextWithOptions(self.innerView.frame.size, innerView.isOpaque, 0.0)
        innerView.drawHierarchy(in: self.innerView.bounds, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        configureBars(false)
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
        upperTextField.text = upperTextDefault
        lowerTextField.text = lowerTextDefault
        imagePickerView.image = nil
        checkShare()
        checkBackground()
    }
    
}

