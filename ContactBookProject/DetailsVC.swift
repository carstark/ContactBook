//
//  DetailsVC.swift
//  ContactBookProject
//
//  Created by Carsten Starke on 19.09.24.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var chosenContact = ""
    var chosenContactId : UUID?

    @IBOutlet weak var datePicked: UIDatePicker!
    @IBOutlet weak var linkText: UITextField!
    @IBOutlet weak var nameText: UITextField!

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var contactImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenContact != "" {
            
            saveButton.isHidden = true
            
            // retrieve data from CoreData
            let stringUUID = chosenContactId!.uuidString
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contacts")
            fetchRequest.predicate = NSPredicate(format: "id = %@", stringUUID)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let link = result.value(forKey: "link") as? String {
                            linkText.text = link
                        }
                        if let date = result.value(forKey: "date") as? Date {
                            datePicked.date = date
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            contactImage.image = image
                        }
                    }
                }
            } catch {
                print("fetch error")
            }
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        // Recognizers
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        contactImage.isUserInteractionEnabled = true
        let contactImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        contactImage.addGestureRecognizer(contactImageTapRecognizer)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        contactImage.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newContact = NSEntityDescription.insertNewObject(forEntityName: "Contacts", into: context)
        
        // Attributes
        newContact.setValue(nameText.text, forKey: "name")
        newContact.setValue(linkText.text, forKey: "link")
        newContact.setValue(datePicked.date, forKey: "date")
        
        newContact.setValue(UUID(), forKey: "id")
        
        let data = contactImage.image?.jpegData(compressionQuality: 0.5)
        newContact.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success saving")
        } catch {
            print("error saving")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
