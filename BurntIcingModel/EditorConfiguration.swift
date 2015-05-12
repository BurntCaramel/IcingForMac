//
//  EditorConfiguration.swift
//  BurntIcing
//
//  Created by Patrick Smith on 14/02/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Foundation



public enum EditorConfiguration {
	case URL(URL: NSURL)
	case SourceCode(HTMLSource: String, javaScriptSources: [String])
	
	public init(editorURL: NSURL) {
		self = .URL(URL: editorURL)
	}
	
	public init(HTMLSource: String, javaScriptSources: [String]) {
		self = .SourceCode(HTMLSource: HTMLSource, javaScriptSources: javaScriptSources)
	}
	
	#if DEBUG
	public static var burntCaramelHostedEditor: EditorConfiguration {
		let editorURL = NSURL(string: "http://www.burntcaramel.com/icing/use/app.html")!
		return EditorConfiguration(editorURL: editorURL)
	}
	
	public static var burntCaramelDevEditor: EditorConfiguration {
		let editorURL = NSURL(string: "http://www.burntcaramel.dev/icing/use/app.html")!
		return EditorConfiguration(editorURL: editorURL)
	}
	
	public static var localDevEditor: EditorConfiguration {
		// Not supported by sandboxing:
		let editorURL = NSURL(string: "file:///Users/pgwsmith/Work/Web%20Git/burnt-icing/dev/app.html")!
		return EditorConfiguration(editorURL: editorURL)
	}
	#endif
	
	public static var errorCreatingLocalEditorCopiedFromBundle: NSError?
	public static var localEditorCopiedFromBundle: EditorConfiguration? {
		// http://jmduke.com/posts/singletons-in-swift/
		struct Static {
			static let instance: EditorConfiguration? = {
				var error: NSError?
				func didEncounterError() {
					EditorConfiguration.errorCreatingLocalEditorCopiedFromBundle = error
				}
				
				let fm = NSFileManager.defaultManager()
				let icingFolderName = "icing-web"
				
				let bundle = NSBundle.bundleForBurntIcingModel()
				let icingFolderURL = bundle.URLForResource(icingFolderName, withExtension: nil)!
				
				var copiedIcingFolderURL: NSURL? = icingFolderURL
				
				#if true
					
					func escapedContentsOfFileURL(fileURL: NSURL) -> Either<NSString, NSError> {
						if let fileContents = NSMutableString(contentsOfURL: fileURL, encoding: NSUTF8StringEncoding, error: &error) {
							// Ampersand must be escaped first, as the other entities contain ampersands
							fileContents.replaceOccurrencesOfString("&", withString: "&amp;", options: .allZeros, range: fileContents.entireRange)
							fileContents.replaceOccurrencesOfString("<", withString: "&lt;", options: .allZeros, range: fileContents.entireRange)
							fileContents.replaceOccurrencesOfString(">", withString: "&gt;", options: .allZeros, range: fileContents.entireRange)
							
							/*case .JavaScript:
								break
								//fileContents.replaceOccurrencesOfString("<", withString: "\\u003c", options: .allZeros, range: fileContents.entireRange)
								//fileContents.replaceOccurrencesOfString(">", withString: "\\u003e", options: .allZeros, range: fileContents.entireRange)
								//fileContents.replaceOccurrencesOfString("\"", withString: "\\u0022", options: .allZeros, range: fileContents.entireRange)
							}*/
							
							return Either(fileContents)
						}
						else {
							return Either(error!)
						}
					}
					
					#if false
					
						let appHTMLURL = icingFolderURL.URLByAppendingPathComponent("app-full.html")
						
						if let appHTMLContents = NSMutableString(contentsOfURL: appHTMLURL, encoding: NSUTF8StringEncoding, error: &error) {
							return EditorConfiguration(HTMLSource: appHTMLContents as String, javaScriptSources: [])
						}
					#else
					
					let appHTMLURL = icingFolderURL.URLByAppendingPathComponent("app.html")
					let mainJSURL = icingFolderURL.URLByAppendingPathComponent("main.js")
					let mainCSSURL = icingFolderURL.URLByAppendingPathComponent("styles", isDirectory: true).URLByAppendingPathComponent("main.css")
					
					if let appHTMLContents = NSMutableString(contentsOfURL: appHTMLURL, encoding: NSUTF8StringEncoding, error: &error) {
						if let
							mainJSContents = String(contentsOfURL: mainJSURL, encoding: NSUTF8StringEncoding, error: &error),
							mainCSSContentsEscaped = escapedContentsOfFileURL(mainCSSURL).some
						{
							appHTMLContents.replaceOccurrencesOfString("<link rel=\"stylesheet\" type=\"text/css\" href=\"styles/main.css\">", withString: "<style>\(mainCSSContentsEscaped)</style>", options: .allZeros, range: appHTMLContents.entireRange)
							
							let javaScriptSources = [
								mainJSContents
							]
							appHTMLContents.replaceOccurrencesOfString("<script src=\"main.js\"></script>", withString: "", options: .allZeros, range: appHTMLContents.entireRange)
							
							#if DEBUG && false
							println(appHTMLContents)
							#endif
							
							return EditorConfiguration(HTMLSource: appHTMLContents as String, javaScriptSources: javaScriptSources)
						}
					}
						
					#endif
					
					didEncounterError()
					return nil
					
					
				#elseif false
					
					let cacheDirectoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("www"))!
					var destinationIcingFolderURL: NSURL = cacheDirectoryURL.URLByAppendingPathComponent(icingFolderName, isDirectory: true)
					
					if let replacementDirectoryURL = fm.URLForDirectory(.ItemReplacementDirectory, inDomain: .UserDomainMask, appropriateForURL: destinationIcingFolderURL, create: true, error: &error)?.URLByAppendingPathComponent(icingFolderName, isDirectory: true) {
					if !fm.createDirectoryAtURL(cacheDirectoryURL, withIntermediateDirectories: true, attributes: nil, error: &error) {
					didEncounterError()
					return nil
					}
					
					if !fm.copyItemAtURL(icingFolderURL, toURL: replacementDirectoryURL, error: &error) {
					didEncounterError()
					return nil
					}
					
					println("icingFolderURL \(icingFolderURL) \(destinationIcingFolderURL)")
					if !fm.replaceItemAtURL(destinationIcingFolderURL, withItemAtURL: replacementDirectoryURL, backupItemName: nil, options: .UsingNewMetadataOnly, resultingItemURL: &copiedIcingFolderURL, error: &error) {
					didEncounterError()
					return nil
					}
					}
					
					return EditorConfiguration(editorURL: destinationIcingFolderURL)
					
				#else
					
					if let copiedIcingFolderURL = copiedIcingFolderURL {
					let portNumber = 38179
					
					let arguments: [String] = ["-S", "localhost:\(portNumber)", "-t", copiedIcingFolderURL.path!]
					let argumentsDebug = join(" ", arguments)
					println("PHP ARGUMENTS \(argumentsDebug)")
					
					let task = NSTask()
					
					task.launchPath = "/usr/bin/php"
					task.arguments = arguments
					task.standardOutput = NSPipe()
					task.standardError = NSPipe()
					
					task.launch()
					
					let servedURL = NSURL(string: "http://localhost:\(portNumber)/app.html")!
					return EditorConfiguration(editorURL: servedURL)
				}
				else {
					didEncounterError()
					return nil
				}
				#endif
			}()
		}
		
		return Static.instance
	}
	
	#if false
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
	#endif
}