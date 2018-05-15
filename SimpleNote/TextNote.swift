//
//  NoteText.swift
//  SimpleNote
//
//  Created by 吳德彥 on 17/04/2018.
//  Copyright © 2018 吳德彥. All rights reserved.
//

import Foundation
import Alamofire

struct TextNote {
    var title: String  = TextNote.defaultTitle() {
        didSet {
            try? FileManager.default.moveItem(at: TextNote.fileURL(of: oldValue), to: TextNote.fileURL(of: title))
        }
    }
    
    var content: String = {
//        let templatePath = Bundle.main.url(forResource: "template", withExtension: "txt")!
        let templateContent = "\(Bundle.main.infoDictionary)"
//        guard let templateContent = try? String(contentsOf: templatePath, encoding: .utf8) else { return "" }
        return templateContent
    }()
    
    var id: String = ""
    
    var fileURL: URL {
        return TextNote.fileURL(of: self.title)
    }
    
    func save() throws {
        try self.content.write(to: self.fileURL, atomically: true, encoding: .utf8)
    }
    
    init(id: String = "", title: String = "", content: String = "") {
        self.id = id
        self.title = title
        self.content = content
    }
}


extension TextNote {
    
    /*
     In this simple note struct, we use the file name (without extension) as the title of a note.
     */
    
    static func defaultTitle() -> String {
        let date = Date()
        let dateString = TextNote.fileNameDateFormatter.string(from: date)
        return "Untitled \(dateString)"
    }
    
    private static let fileNameDateFormatter: DateFormatter = {
        /*
         We use date formatter to convert `Date` instances to String
         And then we can use it as the default note name.
         
         Usually we would share the instance of `DateFormatter` since
         it's expensive to create it.
         */
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        return dateFormatter
    }()
    
    // MARK: Storage location
    
    static let storageURL: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    static func fileName(of title: String) -> String {
        return "\(title).txt"
    }
    
    static func fileURL(of title: String) -> URL {
        return self.storageURL.appendingPathComponent(self.fileName(of: title))
    }
    
    // MARK: I/O
    
    static func open(url: URL) -> TextNote? {
        let title = url.deletingPathExtension().lastPathComponent
        guard let noteContent = (try? String(contentsOf: url, encoding: .utf8)) else { return nil }
        return TextNote(title: title, content: noteContent)
    }
    
    static func getSavedNotes() -> [TextNote] {
        var result = [TextNote]()
        guard let noteURLs = try?
            FileManager.default.contentsOfDirectory(at: TextNote.storageURL,
                                                    includingPropertiesForKeys: nil) else { return [] }
        
        for noteURL in noteURLs {
            guard noteURL.pathExtension == "txt" else { continue }
            guard let note = TextNote.open(url: noteURL) else {continue}
            result.append(note)
        }
        return result
    }
    
    static func remove(title: String) throws {
        try FileManager.default.removeItem(at: self.fileURL(of: title))
    }
}

extension TextNote {
    static let remoteAPIEndpoint: URL = URL(string: "http://127.0.0.1:3000")!

    static var collectionURL: URL {
        return remoteAPIEndpoint.appendingPathComponent("notes")}
    
    static func remoteURL(id: String) -> URL {
        if id == ""{
            return remoteAPIEndpoint.appendingPathComponent("note")
        }
        else {
            return remoteAPIEndpoint.appendingPathComponent("note").appendingPathComponent("id")
        }
    }
        
    static func getRemoteNotes(completion: (([TextNote]?) -> Void)? = nil) -> Void{
        Alamofire
            .request(collectionURL, method: .get, encoding: JSONEncoding.default)
            .responseJSON { dataResponse in
                guard dataResponse.result.isSuccess else {
                    completion?(nil)
                    return
                }
                // Done
                guard let respValue = dataResponse.value as? [[String: Any]] else {
                    print("Failed to get the list of notes.")
                    return
                }
                
                var fetchedNotesList = [TextNote]()
                for item in respValue {
                    guard let title = item["title"] as? String, let content = item["content"] as? String, let id = item["_id"] as? String else { fatalError("Failed to parse the content of notes.") }
                    
                    fetchedNotesList.append(TextNote(id: id, title: title, content: content))
                }
                completion?(fetchedNotesList)
        }
    }
    
    func saveToRemote(completion: ((Bool) -> Void)? = nil) {
        Alamofire
            .request(TextNote.remoteURL(id: id), method: .post,  parameters: ["title": self.title, "content": self.content], encoding: JSONEncoding.default)
            .responseJSON { dataResponse in
                guard dataResponse.result.isSuccess else {
                    completion?(false)
                    return
                }
                completion?(true)
        }
    }
    
    func deleteFromRemote(completion: ((Bool) -> Void)? = nil) {
        Alamofire
            .request(TextNote.remoteURL(id: id), method: .delete, encoding: JSONEncoding.default)
            .responseJSON { dataResponse in
                guard dataResponse.result.isSuccess else {
                    completion?(false)
                    return
                }
                completion?(true)
        }
    }
}

