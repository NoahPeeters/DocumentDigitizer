//
//  Tesseract.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation

class Tesseract {
    static let shared = Tesseract()

    var languageList: [TesseractLanguage] = []
    
    private init() {}
    
    private func newTesseractProcess() -> Process {
        let process = Process()
        process.launchPath = "/usr/local/bin/tesseract"
        return process
    }
    
    func reloadLanguageList() {
        
        let process = newTesseractProcess()
        process.arguments = ["--list-langs"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        let outputHandle = pipe.fileHandleForReading
        
        var lineNumber = 0
        var newLanguageList: [String] = []
        
        outputHandle.readabilityHandler = { pipe in
            guard let input = String(data: pipe.availableData, encoding: .utf8) else {
                return
            }
            
            for line in input.components(separatedBy: "\n") {
                lineNumber += 1
                if lineNumber > 1, line.characters.count > 0 {
                    newLanguageList.append(line)
                }
            }
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            //launch and wait
            process.launch()
            process.waitUntilExit()
            self?.languageList = TesseractLanguage.listFromArray(newLanguageList)
            
            NotificationCenter.default.post(name: NSNotification.Name.TesseractLanguageListChanged, object: nil)
        }
    }
    
    func run(inputURL: URL, outputURL: URL, languages: [TesseractLanguage], completionBlock: @escaping () -> Void) {
        let process = newTesseractProcess()
        
        process.arguments = (languages.count > 0 ? ["-l", languages.map({ return $0.shortForm }).joined(separator: "+")] : []) + [inputURL.path, outputURL.deletingPathExtension().path, outputURL.pathExtension]
        
        DispatchQueue.global(qos: .userInitiated).async {
            //launch and wait
            process.launch()
            process.waitUntilExit()
            
            completionBlock()
        }
    }
}
