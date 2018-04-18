//
//  NoteText.swift
//  SimpleNote
//
//  Created by 吳德彥 on 17/04/2018.
//  Copyright © 2018 吳德彥. All rights reserved.
//

import Foundation

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
    
    var fileURL: URL {
        return TextNote.fileURL(of: self.title)
    }
    
    func save() throws {
        try self.content.write(to: self.fileURL, atomically: true, encoding: .utf8)
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

