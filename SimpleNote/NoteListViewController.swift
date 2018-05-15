//
//  ViewController.swift
//  SimpleNote
//
//  Created by 吳德彥 on 17/04/2018.
//  Copyright © 2018 吳德彥. All rights reserved.
//

import UIKit

class NoteListViewController: UITableViewController {

    var textNotes: [TextNote] = []{
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateNotes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateNotes()
        print(Bundle.allBundles)
    }
    
    @IBAction func updateTableViewContent(_ sender: UIRefreshControl) {
        self.updateNotes()
        sender.endRefreshing()
    }
    
    func updateNotes() {
        TextNote.getRemoteNotes{ textNotes in
            textNotes?.sorted{
                $0.title > $1.title
            }
            guard let textNotes = textNotes else { return }
            self.textNotes = textNotes
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return self.textNotes.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let note = self.textNotes[indexPath.row]
        cell.textLabel?.text = note.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.removeNote(at: indexPath)
        }
    }
    
    
    func removeNote(at indexPath: IndexPath) {
        let note = self.textNotes[indexPath.row]
        
        self.tableView.beginUpdates()
        defer {
            tableView.endUpdates()
        }
        
        do {
            note.deleteFromRemote()
            updateNotes()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            fatalError("Cannot delete note: \(note.title)")
        }
    }
    
    // MARK: - Storyboard Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenNote" {
            guard let cell = sender as? UITableViewCell else {
                fatalError("Mis-configured storyboard! The sender should be a cell.")
            }
            self.prepareOpeningNote(for: segue, sender: cell)
        } else if segue.identifier == "CreateNote" {
            self.prepareCreatingNote(for: segue)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func prepareOpeningNote(for segue: UIStoryboardSegue, sender: UITableViewCell) {
        let noteViewController = segue.destination as! NoteViewController
        let senderIndexPath = self.tableView.indexPath(for: sender)!
        let selectedNote = self.textNotes[senderIndexPath.row]
        noteViewController.note = selectedNote
    }
    
    func prepareCreatingNote(for segue: UIStoryboardSegue) {
        let noteViewController = segue.destination as! NoteViewController
        noteViewController.note = TextNote()
    }


}

