//
//  NoteViewController.swift
//  SimpleNote
//
//  Created by 吳德彥 on 17/04/2018.
//  Copyright © 2018 吳德彥. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var note: TextNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUIElements()
    }
    
    func updateUIElements() {
        self.titleTextField.text = self.note?.title
        self.contentTextView.text = self.note?.content
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.note?.title = self.titleTextField.text ?? ""
        self.note?.content = self.contentTextView.text ?? ""
        do{
            try self.note?.saveToRemote()
        }catch{
            fatalError("Cannot save note: \(note?.title)")
        }
    }

}
