import UIKit
import FirebaseFirestore

class NotesViewViewController: UIViewController {
    
    var noteIndex:Int = 0;
    var notes:String = "";
    var todo:String = ""
    let db = Firestore.firestore();
    @IBOutlet weak var notesBox: UITextView!
    @IBOutlet weak var todoTitleLabel: UILabel!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        var editID:String = ""
        var editID2:String = ""
        db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if ((document.data()["Name"]! as? String)! == self.todo) {
                        editID = document.documentID
                    }
                }
            }
        }
        
        db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if(document.data()["ID"] != nil) {
                        if ((document.data()["ID"]! as? String)! == editID) {
                            editID2 = document.documentID
                        }
                    } else {
                        let alert = UIAlertController(title: "Something went wrong!", message: "Please check your internet connection.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
           
                if (editID2 != "") {
                    self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").document(editID2).updateData(["Note": self.notesBox.text!])
                    
                        self.performSegue(withIdentifier: "goBack", sender: nil)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        notesBox.text = notes;
        todoTitleLabel.text = todo
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
