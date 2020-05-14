import UIKit
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var arrayOfTodos:[todo] = []
    var noteIndex:Int = 0;
    var mode:Int = 0;
    var editIndex:Int = 0;
    var totalTodos:Int = 0
    let db = Firestore.firestore();
    
    @IBOutlet weak var test: UILabel!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var newToDo: UITextField!
    @IBOutlet weak var AddButton2: UIButton!
    @IBOutlet weak var dimmer: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var ToDos: UITableView!
    @IBOutlet weak var doneText: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func inspirationButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewToImage", sender: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        newToDo.isHidden = true;
        AddButton2.isHidden = true;
        dimmer.isHidden = true;
        label.isHidden = true;
        cancelButton.isHidden = true;
        ToDos.isHidden = false;
    }
    
    @IBAction func AddButtonPressed(_ sender: Any) {
        newToDo.isHidden = false;
        AddButton2.isHidden = false;
        dimmer.isHidden = false;
        label.isHidden = false;
        doneText.isHidden = true;
        ToDos.isHidden = true;
        cancelButton.isHidden = false;
        newToDo.text = ""
    }
    
    @IBAction func AddButton2Pressed(_ sender: Any) {
        newToDo.isHidden = true;
        AddButton2.isHidden = true;
        dimmer.isHidden = true;
        label.isHidden = true;
        ToDos.isHidden = false;
        cancelButton.isHidden = true;
        var ref: DocumentReference? = nil
        var editID:String = ""
        
        if (newToDo.hasText) {
            if (mode == 0) {
            
            let newTodo:todo = todo(Name: newToDo.text!, Note: "No notes yet!", State: "Off", Order: String(totalTodos+1))
                
                ref = db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").addDocument(data: ["Name":newTodo.name, "Note":newTodo.note, "State":newTodo.state, "Order":newTodo.order]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                    self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").document(ref!.documentID).setData(["ID": ref!.documentID, "Name":newTodo.name, "Note":newTodo.note, "State":newTodo.state, "Order":newTodo.order])
                                    
                                    self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
                                        if let err = err {
                                            print("Error getting documents: \(err)")
                                        } else {
                                            self.arrayOfTodos.removeAll()
                                            for document in querySnapshot!.documents {
                                                var tempTodo = todo(Name: document.data()["Name"] as! String, Note: document.data()["Note"] as! String, State: document.data()["State"] as! String, Order: document.data()["Order"] as! String)
                                                self.arrayOfTodos.append(tempTodo)
                                            }
                                            self.arrayOfTodos = self.arrayOfTodos.sorted(by: { $0.order < $1.order })
                                            self.totalTodos = self.totalTodos + 1
                                            if (self.arrayOfTodos.count == 0) {
                                                self.doneText.isHidden = false;
                                            }
                                            else {
                                                self.doneText.isHidden = true;
                                            }
                                            self.ToDos.reloadData()
                                        }
                                    }
                                }
                            }
                
                } else {
                
                    db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                if ((document.data()["Name"]! as? String)! == self.arrayOfTodos[self.editIndex].name) {
                                    editID = document.documentID
                                }
                            }
                        }
                    }
                    var editID2:String = ""
                
                    db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                if ((document.data()["ID"]! as? String)! == editID) {
                                    editID2 = document.documentID
                                }
                            }
                            print(self.newToDo.text!)
                            self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").document(editID2).updateData(["Name": self.newToDo.text!])
                            if (self.arrayOfTodos.count == 0) {
                                self.doneText.isHidden = false;
                            }
                            else {
                                self.doneText.isHidden = true;
                            }
                            
                            self.arrayOfTodos.removeAll()
                            self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        var tempTodo = todo(Name: document.data()["Name"] as! String, Note: document.data()["Note"] as! String, State: document.data()["State"] as! String, Order: document.data()["Order"] as! String)
                                        self.arrayOfTodos.append(tempTodo)
                                    }
                                    self.arrayOfTodos = self.arrayOfTodos.sorted(by: { $0.order < $1.order })
                                    if (self.arrayOfTodos.count == 0) {
                                        self.doneText.isHidden = false;
                                    }
                                    else {
                                        self.doneText.isHidden = true;
                                    }
                                    self.dimmer.isHidden = true;
                                    self.ToDos.reloadData()
                                    self.newToDo.text = "";
                                    self.view.endEditing(true)
                                }
                            }
            
                        }
                    }
            }

        }
        else {
        if (arrayOfTodos.count == 0) {
            doneText.isHidden = false;
            }
        else {
            doneText.isHidden = true;
            }
        }
        ToDos.reloadData()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfTodos.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        cell.name = arrayOfTodos[indexPath.row].name
        cell.ToDo.text = arrayOfTodos[indexPath.row].name
        
       
        let strikethrough: NSMutableAttributedString = NSMutableAttributedString(string: cell.ToDo.text!)
        
        if (arrayOfTodos[indexPath.row].state == "On") {
            
            strikethrough.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, cell.ToDo.text!.count))
            cell.ToDo.attributedText = strikethrough
            
            cell.State.isHighlighted = false
            cell.State.setOn(true, animated: true)
            cell.ToDo.isHighlighted = false
        }
        else {
            
            strikethrough.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, cell.ToDo.text!.count))
            cell.ToDo.attributedText = strikethrough
            
            cell.State.isHighlighted = true
            cell.State.setOn(false, animated: true)
            cell.ToDo.isHighlighted = true
            
        }
        
 
        return cell
    }
    
    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if ((document.data()["Order"]! as? String)! == String(indexPath.row+1)) {
                        
                        self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").document(document.documentID).updateData(["Order": "1"])
                    }
                    
                    if ((document.data()["Order"]! as? String)! == "1") {
                        
                        self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").document(document.documentID).updateData(["Order": String(indexPath.row+1)])
                    }
                }
                
                self.arrayOfTodos.removeAll()
                self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            var tempTodo = todo(Name: document.data()["Name"] as! String, Note: document.data()["Note"] as! String, State: document.data()["State"] as! String, Order: document.data()["Order"] as! String)
                            self.arrayOfTodos.append(tempTodo)
                        }
                        self.arrayOfTodos = self.arrayOfTodos.sorted(by: { $0.order < $1.order })
                        if (self.arrayOfTodos.count == 0) {
                            self.doneText.isHidden = false;
                        }
                        else {
                            self.doneText.isHidden = true;
                        }
                        self.dimmer.isHidden = true;
                        self.ToDos.reloadData()
                        self.newToDo.text = "";
                        self.view.endEditing(true)
                    }
                }
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75;
    }
    
    @objc func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .normal, title: "Notes") { action, index in
                self.noteIndex = indexPath.row
                self.performSegue(withIdentifier: "showNotes", sender: nil)
        }
        more.backgroundColor = UIColor(red: 0.17, green: 0.78, blue: 1.0, alpha: 1.0)
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.newToDo.isHidden = false;
            self.AddButton2.isHidden = false;
            self.dimmer.isHidden = false;
            self.label.isHidden = false;
            self.cancelButton.isHidden = false;
            self.doneText.isHidden = true;
            self.ToDos.isHidden = true;
            self.editIndex = indexPath.row
            self.newToDo.text = self.arrayOfTodos[indexPath.row].name
            self.mode = 1;
            /*Make this a function*/
        }
        edit.backgroundColor = UIColor(red: 0.51, green: 0.19, blue: 1.0, alpha: 1.0)
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let alert = UIAlertController(title: "Are you sure?", message: "You are about to permenantly delete this item!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
               
                var editID:String = ""
                var editID2:String = ""
                
                self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            if ((document.data()["Name"]! as? String)! == self.arrayOfTodos[indexPath.row].name) {
                                editID = document.documentID
                            }
                        }
                    }
                }
                
                self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
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
                        self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").document(editID2).delete(){ err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    print("Document successfully removed!")
                                    if (self.arrayOfTodos.count == 0) {
                                        self.doneText.isHidden = false;
                                    }
                                    else {
                                        self.doneText.isHidden = true;
                                    }
                                    self.totalTodos = self.totalTodos - 1
                                    self.arrayOfTodos.removeAll()
                                    self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
                                        if let err = err {
                                            print("Error getting documents: \(err)")
                                        } else {
                                            for document in querySnapshot!.documents {
                                                var tempTodo = todo(Name: document.data()["Name"] as! String, Note: document.data()["Note"] as! String, State: document.data()["State"] as! String, Order: document.data()["Order"] as! String)
                                                self.arrayOfTodos.append(tempTodo)
                                                
                                                if (Int(document.get("Order") as! String)! > indexPath.row+1) {
                                                    document.reference.updateData(["Order": String(Int(document.get("Order") as! String)!-1)])
                                                }
                                            }
                                            self.arrayOfTodos = self.arrayOfTodos.sorted(by: { $0.order < $1.order })
                                            if (self.arrayOfTodos.count == 0) {
                                                self.doneText.isHidden = false;
                                            }
                                            else {
                                                self.doneText.isHidden = true;
                                            }
                                            self.dimmer.isHidden = true;
                                            self.ToDos.reloadData()
                                }
                            }
                                }
                            }
                        }
                    }
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        delete.backgroundColor = UIColor(red: 0.96, green: 0.38, blue: 0.22, alpha: 1.0)
        
        return [delete, more, edit]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showNotes"){
            let destVC: NotesViewViewController =
                segue.destination as! NotesViewViewController
            destVC.noteIndex = noteIndex;
            destVC.notes = arrayOfTodos[noteIndex].note;
            destVC.todo = arrayOfTodos[noteIndex].name;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneText.isHidden = true;
        self.newToDo.isHidden = true;
        self.AddButton2.isHidden = true;
        self.label.isHidden = true;
        self.cancelButton.isHidden = true;
        
        if !(UserDefaults.standard.bool(forKey: "firstInstr")) {
             displayPopUp(title: "Welcome!", body: "You can swipe left on a todo to see the options for it, or tap on one to bring it to the top of the list.")
            UserDefaults.standard.set(true, forKey: "firstInstr")
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    var tempTodo = todo(Name: document.data()["Name"] as! String, Note: document.data()["Note"] as! String, State: document.data()["State"] as! String, Order: document.data()["Order"] as! String)
                    self.arrayOfTodos.append(tempTodo)
                    self.totalTodos = self.totalTodos + 1
                }
                self.arrayOfTodos = self.arrayOfTodos.sorted(by: { $0.order < $1.order })
                if (self.arrayOfTodos.count == 0) {
                    self.doneText.isHidden = false;
                }
                else {
                    self.doneText.isHidden = true;
                }
                self.dimmer.isHidden = true;
                self.ToDos.reloadData()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func displayPopUp(title:String, body:String) {
        let alertVC = UIAlertController(title: title, message: body, preferredStyle: .alert)
        
        let alertActionCancel = UIAlertAction(title: "Got It!", style: .default, handler: nil)
        alertVC.addAction(alertActionCancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}



fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
