//
//  ViewController.swift
//  Meme Me
//
//  Created by Tigran Tshorokhyan on 4/14/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
        bottom.isHidden = false
        top.isHidden = false
        bottom.textAlignment = .center
        top.textAlignment = .center
    }


    @IBAction func camera(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }


    @IBAction func addImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }

    @IBOutlet weak var bottom: UITextField!
    @IBOutlet weak var top: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottom.isHidden = true
        top.isHidden = true
        bottom.defaultTextAttributes = memeTextAttributes
        top.defaultTextAttributes = memeTextAttributes
        bottom.backgroundColor = UIColor.clear
        top.backgroundColor = UIColor.clear
        shareButton.isEnabled = false
 
    }
    
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
        NSStrokeWidthAttributeName: -3.0,]
    
    
    
    // Sign up to be notified when the keyboard appears
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    // When the keyboardWillShow notification is received, shift the view's frame up
    
    func keyboardWillShow(_ notification:Notification) {
        if bottom.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if bottom.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        shareButton.isEnabled = true
        return true
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        toolBar.isHidden = true
        navBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        toolBar.isHidden = false
        navBar.isHidden = false
        
        return memedImage
    }
    
    func save() {
        // Create the meme
        let memedImage = generateMemedImage()
        _ = Meme(topText: top.text! as NSString, bottomText: bottom.text! as NSString, originalImage: imageView.image, memeImage: memedImage)
    }
 
    
    @IBAction func share(_ sender: Any) {
        
        let memedImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(activityView, animated: true, completion: nil)
    }
    

}

