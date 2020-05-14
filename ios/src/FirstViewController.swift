//
//  FirstViewController.swift
//  InfiniteProduce
//
//  Created by Malak Sadek on 8/22/19.
//  Copyright © 2019 Malak Sadek. All rights reserved.
//

import UIKit
import FirebaseFirestore
import MessageUI

class FirstViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.bool(forKey: "First")) {
            performSegue(withIdentifier: "firstToMain", sender: nil)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear (_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "First")) {
            performSegue(withIdentifier: "firstToMain", sender: nil)
        }
    }
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        let db = Firestore.firestore();
        var unique = 1;
        db.collection("Users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print((document.data()["Username"]! as? String)!)
                    print(self.usernameTextField.text!)
                    if ((document.data()["Username"]! as? String)! == self.usernameTextField.text!) {
                        unique = 0;
                    }
                }
                
                if(unique == 1) {
                    var ref: DocumentReference? = nil
                    let newTodo:todo = todo(Name: "Sample Todo", Note: "This is just to show you how things look like, feel free to delete it!", State: "Off", Order: "1")
                    
                    ref = db.collection("Users").addDocument(data: [
                        "Username": self.usernameTextField.text as Any]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            var ref2: DocumentReference? = nil
                            ref2 = db.collection("Users").document(ref!.documentID).collection("Todos").addDocument(data: ["Name":newTodo.name, "Note":newTodo.note, "State":newTodo.state, "Order":newTodo.order]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                    db.collection("Users").document(ref!.documentID).collection("Todos").document(ref2!.documentID).setData(["ID": ref2!.documentID, "Name":newTodo.name, "Note":newTodo.note, "State":newTodo.state, "Order":newTodo.order]) { err in
                                        if let err = err {
                                            print("Error writing document: \(err)")
                                        } else {
                                            print("Document successfully written!")
                                            UserDefaults.standard.set(self.usernameTextField.text, forKey: "Username")
                                            UserDefaults.standard.set(true, forKey: "First")
                                            UserDefaults.standard.set(ref!.documentID, forKey: "ID")
                                            self.performSegue(withIdentifier: "firstToMain", sender: nil)
                                        }
                                    }
                                }
                        }
                    }
                }
                } else {
                    self.displayPopUp(title: "Try again!", body: "This username is already taken, please enter another one.")
                }
            }
        }
    }
    
    @IBAction func oldUserButtonPressed(_ sender: Any) {
        let db = Firestore.firestore();
        if(usernameTextField.text!.isEmpty) {
             self.displayPopUp(title: "Welcome back!", body: "Please enter your old username in the text box and press the button again.")
        } else {
            
            db.collection("Users").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if ((document.data()["Username"]! as? String)! == self.usernameTextField.text!) {
                            UserDefaults.standard.set(document.documentID, forKey: "ID")
                            UserDefaults.standard.set(self.usernameTextField.text, forKey: "Username")
                            UserDefaults.standard.set(true, forKey: "First")
                        }
                    }
                    self.performSegue(withIdentifier: "firstToMain", sender: nil)
                }
            }
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func displayPopUp(title:String, body:String) {
        let alertVC = UIAlertController(title: title, message: body, preferredStyle: .alert)
        
        let alertActionCancel = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertVC.addAction(alertActionCancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
