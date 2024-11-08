//
//  ToDoDetailTableViewController.swift
//  ToDoList
//
//  Created by マナフォフ・マリフ on 2024/11/08.
//

import UIKit

class ToDoDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var isCompleteButton: UIButton!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButtonState()
    }
    
    func updateSaveButtonState() {
        let shouldEnableSaveButton = titleTextField.text?.isEmpty == false
        saveButton.isEnabled = shouldEnableSaveButton
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
}
