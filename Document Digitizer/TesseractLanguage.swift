//
//  TesseractLanguage.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation

struct TesseractLanguage {
    
    static func listFromArray(_ inputArray: Array<String>) -> [TesseractLanguage] {
        return inputArray.map {
            return TesseractLanguage(shortForm: $0)
        }
    }
    
    let shortForm: String
}

extension TesseractLanguage: StringIdentifiable {
    var stringIdentifier: String {
        return shortForm
    }
}

extension TesseractLanguage: CustomUserInterfaceString {
    var uiString: String {
        guard let localizedString = Locale.current.localizedString(forLanguageCode: shortForm) else {
            return shortForm
        }
        
        return "\(localizedString) (\(shortForm))"
    }
}
