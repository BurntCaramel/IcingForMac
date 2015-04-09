//
//  HTMLTemplate.swift
//  Icing
//
//  Created by Patrick Smith on 12/03/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Foundation


public struct HTMLTemplate {
	let name: String
	
	public func copyHTMLStringWithPlaceholderValues(values: [String: String]) -> String {
		let bundle = NSBundle.bundleForBurntIcingModel()
		let templateURL = bundle.URLForResource(name, withExtension: "html")!
		let templateString = NSMutableString(contentsOfURL: templateURL, encoding: NSUTF8StringEncoding, error: nil)!
		
		func replaceInTemplate(find target: String, replace replacement: String) {
			templateString.replaceOccurrencesOfString(target, withString: replacement, options: NSStringCompareOptions(0), range: NSMakeRange(0, templateString.length))
		}
		
		for (placeholderID, value) in values {
			replaceInTemplate(find: placeholderID, replace: value)
		}
		
		return templateString as String
	}
}