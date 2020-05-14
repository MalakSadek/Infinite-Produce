import UIKit
import FirebaseFirestore

class TableViewCell: UITableViewCell {
    @IBOutlet weak var State: UISwitch!
    @IBOutlet weak var ToDo: UILabel!
    var name:String!;
    let db = Firestore.firestore();
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func StateChanged(_ sender: Any) {

        let strikethrough: NSMutableAttributedString = NSMutableAttributedString(string: ToDo.text!)
        
        if (State.isOn) {
            
            var editID:String = ""
            
            db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if ((document.data()["Name"]! as? String)! == self.name) {
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
                    self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").document(editID2).updateData(["State": "On"])
                    strikethrough.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, self.ToDo.text!.count))
                    self.ToDo.attributedText = strikethrough
                    
                    self.State.isHighlighted = false
                    self.ToDo.isHighlighted = false
                        }
                    }
            
        } else {
            
            var editID:String = ""
            
            db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if ((document.data()["Name"]! as? String)! == self.name) {
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
                    self.db.collection("Users").document(UserDefaults.standard.string(forKey: "ID")!).collection("Todos").document(editID2).updateData(["State": "Off"])
                    strikethrough.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, self.ToDo.text!.count))
                    self.ToDo.attributedText = strikethrough
                    
                    self.State.isHighlighted = true
                    self.ToDo.isHighlighted = true
                }
            }
            

        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
