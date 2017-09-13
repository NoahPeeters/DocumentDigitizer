//
//  ImportedFiles.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 12.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa
import Quartz

class ImportedImage: NSDocument {
    init(contentsOf url: URL, ofType typeName: String) throws {
        super.init()
        DocumentDigitizer.shared.convertFile(withURL: url) { [weak self] _ in
            self?.close()
        }
    }
}


class ImportedPDF: NSDocument {
    init(contentsOf url: URL, ofType typeName: String) throws {
        super.init()
        
        DocumentDigitizer.shared.handlePDFFile(at: url) { _ in
            self.close()
        }
    }
}


extension PDFDocument {
    var pages: [PDFPage] {
        return (0..<pageCount).map {
            page(at: $0)!
        }
    }
}

extension URL {
    static func makeTemporaryDirectory() -> URL {
        let tmpDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        return tmpDirectory
    }
}

extension Process {
    static func withEnvoirement() -> Process {
        let process = Process()
        
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = "/usr/local/bin"
        process.environment = env
        
        return process
    }
}
