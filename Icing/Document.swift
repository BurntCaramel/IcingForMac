//
//  Document.swift
//  BurntIcing
//
//  Created by Patrick Smith on 14/02/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa
import BurntIcingModel


enum DocumentTypes {
	case IcingDocumentJSON
	case ExportedNakedHTML
	case ExportedWrappedHTML
	
	private static let IcingDocumentJSONTypeName = "com.burntcaramel.icing.document.json"
	private static let ExportedNakedHTMLTypeName = "com.burntcaramel.icing.exported.html.naked"
	private static let ExportedWrappedHTMLTypeName = "com.burntcaramel.icing.exported.html.wrapped"
	//private static let ExportedHTMLTypeName = kUTTypeHTML
	
	init? (typeName: String) {
		if (typeName == DocumentTypes.IcingDocumentJSONTypeName) {
			self = .IcingDocumentJSON
		}
		else if (typeName == DocumentTypes.ExportedNakedHTMLTypeName) {
			self = .ExportedNakedHTML
		}
		else if (typeName == DocumentTypes.ExportedWrappedHTMLTypeName) {
			self = .ExportedWrappedHTML
		}
		else {
			return nil
		}
	}
	
	func toString() -> String {
		switch self {
		case .IcingDocumentJSON:
			return DocumentTypes.IcingDocumentJSONTypeName
		case .ExportedNakedHTML:
			return DocumentTypes.ExportedNakedHTMLTypeName
		case .ExportedWrappedHTML:
			return DocumentTypes.ExportedWrappedHTMLTypeName
		}
	}
}


class Document: NSDocument {
	var mainWindowController: DocumentWindowController!
	
	var contentController: DocumentContentController!

	override init() {
	    super.init()
		// Add your subclass-specific initialization here.
	}
	
	// Blank new document
	convenience init(type typeName: String, error outError: NSErrorPointer) {
		self.init()
		
		self.fileType = typeName
		
		contentController = DocumentContentController()
	}

	override class func autosavesInPlace() -> Bool {
		// Currently asynchronous saving implementation below stuffs up 'Duplicate' action.
		return false
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: "Main", bundle: nil)!
		mainWindowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as DocumentWindowController
		
		//println("created window controller \(mainWindowController) from storyboard \(storyboard)")
		
		if contentController != nil {
			mainWindowController.contentController = contentController
		}
		
		self.addWindowController(mainWindowController)
	}
	
	override func canAsynchronouslyWriteToURL(url: NSURL, ofType typeName: String, forSaveOperation saveOperation: NSSaveOperationType) -> Bool {
		return true
	}
	
	/*
	override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
		
		self.unblockUserInteraction()
		
		let lock = NSConditionLock(condition: 0)
		var contentData: NSData? = nil
		if contentController != nil {
			contentController.useLatestJSONDataOnMainQueue({ (latestContentData) -> Void in
				contentData = latestContentData
				lock.unlockWithCondition(1)
			})
		}
		
		lock.lockWhenCondition(1)
		lock.unlock()
		
		return contentData
		
		//outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		//return nil
	}
	*/
	
	override func writeToURL(url: NSURL, ofType typeName: String, forSaveOperation saveOperation: NSSaveOperationType, originalContentsURL absoluteOriginalContentsURL: NSURL?, error outError: NSErrorPointer) -> Bool {
		//let fileAttributes = fileAttributesToWriteToURL(url, ofType: typeName, forSaveOperation: saveOperation, originalContentsURL: absoluteOriginalContentsURL, error: outError)
		
		//println("Will unblockUserInteraction")
		if let type = DocumentTypes(typeName: typeName) {
			unblockUserInteraction()
			
			let lock = NSConditionLock(condition: 0)
			var contentData: NSData? = nil
			if let contentController = contentController {
				if type == .IcingDocumentJSON {
					//println("Will useLatestJSONDataOnMainQueue")
					contentController.useLatestJSONDataOnMainQueue {
						(latestContentData) in
						contentData = latestContentData
						//contentData = latestContentData?.copy() as? NSData
						//println("Got latest content data \(contentData?.length)")
						lock.unlockWithCondition(1)
					}
				}
				else if type == .ExportedNakedHTML || type == .ExportedWrappedHTML {
					contentController.usePreviewHTMLStringOnMainQueue {
						(previewHTMLString) in
						if var previewHTMLString = previewHTMLString {
							if type == .ExportedWrappedHTML {
								var pageTitle: String = "Untitled"
								if let savedName = url.URLByDeletingPathExtension?.lastPathComponent {
									pageTitle = savedName
								}
								previewHTMLString = contentController.wrapNakedHTMLString(previewHTMLString, pageTitle: pageTitle)
							}
							
							contentData = previewHTMLString.dataUsingEncoding(NSUTF8StringEncoding)
						}
						lock.unlockWithCondition(1)
					}
				}
			}
			
			lock.lockWhenCondition(1)
			//println("Lock got condition 1")
			lock.unlock()
			
			let fileWrapper = NSFileWrapper(regularFileWithContents: contentData!)
			
			/*
			// Complains for some reason
			if fileAttributes != nil {
			fileWrapper.fileAttributes = fileAttributes!
			}
			*/
			
			//println("Writing to URL \(url)")
			if !fileWrapper.writeToURL(url, options: .Atomic, originalContentsURL: absoluteOriginalContentsURL, error: outError) {
				return false
			}
			
			return true
		}
		else {
			return false
		}
	}
	
	/*
	override func writeToURL(url: NSURL, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
		if contentController != nil {
			return contentController.copyJSONData()
		}
	}
*/

	override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
		if let type = DocumentTypes(typeName: typeName) {
			if type == .IcingDocumentJSON {
				contentController = DocumentContentController(JSONData: data)
				
				println("set data in document")
				//mainWindowController.DocumentJSONData = JSONData
				
				return true
			}
		}
		
		// Type not handled:
		
		println(typeName)
		// Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
		// You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
		// If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
		outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		return false
	}

	@IBAction func exportHTMLPreview(sender: AnyObject) {
		let savePanel = NSSavePanel()
		//savePanel.allowedFileTypes = [kUTTypeHTML]
		savePanel.allowedFileTypes = ["html"]
		savePanel.allowsOtherFileTypes = true
		
		savePanel.canSelectHiddenExtension = true
		savePanel.extensionHidden = false
		savePanel.nameFieldStringValue = displayName.stringByDeletingPathExtension + ".html"
		
		savePanel.nameFieldLabel = "Export HTML"
		savePanel.title = "Export HTML"
		savePanel.prompt = "Export HTML"
		
		if let window = self.windowForSheet {
			savePanel.beginSheetModalForWindow(window, completionHandler: { (result) -> Void in
				if result == NSFileHandlingPanelOKButton {
					if let URL = savePanel.URL {
						var error: NSError?
						//let success = self.writeSafelyToURL(URL, ofType: DocumentTypes.ExportedHTML.toString(), forSaveOperation: .SaveToOperation, error: &error)
						self.saveToURL(URL, ofType: DocumentTypes.ExportedWrappedHTML.toString(), forSaveOperation: .SaveToOperation, completionHandler: { (error) -> Void in
							if let error = error {
								println("Error saving HTML \(error)")
							}
						})
					}
				}
			})
		}
	}
}

