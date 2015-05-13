//
//  Content.swift
//  BurntIcing
//
//  Created by Patrick Smith on 14/02/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Foundation


public struct Content {
	let JSONData: NSData
}

public struct Section {
	//let UUID: NSUUID
	var identifier: String
	let content: Content
}

public class Document {
	//let UUID: NSUUID
	var identifier: String
	var sections: [Section]
	
	init(identifier: String) {
		self.identifier = identifier
		self.sections = []
	}
	
	func addSection(section: Section) {
		sections.append(section)
	}
}


@objc public protocol DocumentContentEditor {
	func useLatestDocumentJSONDataOnMainQueue(callback: (NSData?) -> Void)
	func usePreviewHTMLStringOnMainQueue(callback: (String?) -> Void)
	func usePageSourceHTMLStringOnMainQueue(callback: (String?) -> Void) // For debugging
}


public class DocumentContentController {
	internal var JSONData: NSData!
	public weak var editor: DocumentContentEditor?
	
	public init(JSONData: NSData?) {
		if JSONData != nil {
			self.JSONData = JSONData!.copy() as! NSData
		}
	}
	
	public convenience init() {
		self.init(JSONData: nil)
	}
	
	public func useLatestJSONDataOnMainQueue(callback: (NSData?) -> Void) {
		#if DEBUG
			println("DocumentContentController useLatestJSONDataOnMainQueue \(self.JSONData?.length)")
		#endif
		if let editor = editor {
			NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
				editor.useLatestDocumentJSONDataOnMainQueue { (latestData) -> Void in
					callback(latestData)
				}
			}
		}
		else {
			NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
				callback(self.JSONData)
			}
		}
	}
	
	public func usePreviewHTMLStringOnMainQueue(callback: (String?) -> Void) {
		var block: () -> Void
		
		if let editor = editor {
			block = {
				editor.usePreviewHTMLStringOnMainQueue { (previewHTMLString) -> Void in
					callback(previewHTMLString)
				}
			}
		}
		else {
			block = {
				callback(nil)
			}
		}
		
		// Make sure it is always asynchronous.
		NSOperationQueue.mainQueue().addOperationWithBlock(block)
	}
	
	public func usePageSourceHTMLStringOnMainQueue(callback: (String?) -> Void) {
		var block: () -> Void
		
		if let editor = editor {
			block = {
				editor.usePageSourceHTMLStringOnMainQueue { (sourceHTMLString) -> Void in
					callback(sourceHTMLString)
				}
			}
		}
		else {
			block = {
				callback(nil)
			}
		}
		
		// Make sure it is always asynchronous.
		NSOperationQueue.mainQueue().addOperationWithBlock(block)
	}
	
	public func wrapNakedHTMLString(nakedHTMLString: String, pageTitle: String) -> String {
		let template = HTMLTemplate(name: "wrapped-content-template")
		
		return template.copyHTMLStringWithPlaceholderValues(
			[
				"__TITLE__": pageTitle,
				"__BODY_CONTENT__": nakedHTMLString
			]
		);
	}
}
