//
//  String+HTML.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/18/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation

extension String {
    var htmlToAttributedString: NSAttributedString? {
        
        let htmlCSSString = "<style>" +
            "html * {" +
                "font-size: 14pt !important;" +
                "color: #000 !important;" +
                "font-family: Roboto !important;" +
            "}" +
            "a {" +
                "color: #000 !important;" +
            "}" +
            "h2 {" +
                "font-family: Oswald !important;" +
                "font-weight: bold !important;" +
            "}" +
        "</style> \(self)"
        
        
        guard let data = htmlCSSString.data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
