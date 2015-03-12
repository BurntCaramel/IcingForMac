//
//  EditorConfiguration.swift
//  BurntIcing
//
//  Created by Patrick Smith on 14/02/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Foundation


public class EditorConfiguration {
	//internal(set) public var editorURL: NSURL
	public let editorURL: NSURL
	
	public init(editorURL: NSURL) {
		self.editorURL = editorURL
	}
	
	public class var burntCaramelHostedEditor: EditorConfiguration {
		let editorURL = NSURL(string: "http://www.burntcaramel.com/icing/use/app.html")!
		return EditorConfiguration(editorURL: editorURL)
	}
	
	public class var burntCaramelDevEditor: EditorConfiguration {
		let editorURL = NSURL(string: "http://www.burntcaramel.dev/icing/use/app.html")!
		return EditorConfiguration(editorURL: editorURL)
	}
	
	public class var localDevEditor: EditorConfiguration {
		// Not supported by sandboxing:
		let editorURL = NSURL(string: "file:///Users/pgwsmith/Work/Web%20Git/burnt-icing/dev/app.html")!
		return EditorConfiguration(editorURL: editorURL)
	}
	
	var reactJSURL: NSURL {
		get {
			return NSURL(string: "https://cdnjs.cloudflare.com/ajax/libs/react/0.12.2/react.js")!
		}
	}
	
	var mainCSSURL: NSURL {
		get {
			return editorURL.URLByAppendingPathComponent("main.css")
		}
	}
	
	var mainJSURL: NSURL {
		get {
			return editorURL.URLByAppendingPathComponent("main.js")
		}
	}
	
	var editorPageHTML: String {
		get {
			// TODO: change to HTMLTemplate struct
			let bundle = NSBundle()
			let templateURL = bundle.URLForResource("editor-template", withExtension: "html")!
			let templateString = NSMutableString(contentsOfURL: templateURL, encoding: NSUTF8StringEncoding, error: nil)!
			
			func replaceInTemplate(find target: NSString, replace replacement: NSString) {
				templateString.replaceOccurrencesOfString(target, withString: replacement, options: NSStringCompareOptions(0), range: NSMakeRange(0, templateString.length))
			}
			
			replaceInTemplate(find: "_PLACEHOLDER_REACT_JS_", replace: reactJSURL.absoluteString!)
			replaceInTemplate(find: "_PLACEHOLDER_BURNTICING_MAIN_CSS_", replace: mainCSSURL.absoluteString!)
			replaceInTemplate(find: "_PLACEHOLDER_BURNTICING_MAIN_JS_", replace: mainJSURL.absoluteString!)
			
			return templateString.copy() as NSString
		}
	}
}