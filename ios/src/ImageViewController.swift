//
//  ImageViewController.swift
//  InfiniteProduce
//
//  Created by Malak Sadek on 8/25/19.
//  Copyright © 2019 Malak Sadek. All rights reserved.
//

import UIKit
import FirebaseStorage

class ImageViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let storage = Storage.storage()
        let storageRef = storage.reference()
        let randomInt = Int.random(in: 1..<24)
        
        let photoRef = storageRef.child(String(randomInt)+".jpg")
        
        photoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                self.image.image = UIImage(data: data!)
                self.indicator.isHidden = true
            }
        // Do any additional setup after loading the view.
    }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
