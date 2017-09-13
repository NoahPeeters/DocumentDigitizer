//
//  ICDeviceExtension.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import ImageCaptureCore

extension ICDevice: StringIdentifiable {
    var stringIdentifier: String {
        return persistentIDString ?? ""
    }
}

extension ICDevice: CustomUserInterfaceString {
    var uiString: String {
        return name ?? NSLocalizedString("DefaultDeviceName", comment: "")
    }
}
