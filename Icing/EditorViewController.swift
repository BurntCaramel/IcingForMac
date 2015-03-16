//
//  EditorViewController.swift
//  BurntIcing
//
//  Created by Patrick Smith on 14/02/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa
import WebKit
import BurntIcingModel


class EditorViewController: NSViewController {
	internal var webViewController: EditorWebViewController!
	
	//var editorConfiguration: EditorConfiguration = EditorConfiguration.burntCaramelHostedEditor
	var editorConfiguration: EditorConfiguration = EditorConfiguration.burntCaramelDevEditor
	
	var minimumWidth: CGFloat = 700.0
	var minimumHeight: CGFloat = 550.0

    override func viewDidLoad() {
        super.viewDidLoad()
		
		/*
		let minimumWidth = 960.0
		let minimumHeight = 400.0
		
		view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: minimumWidth))
		view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: minimumHeight))
*/
		view.addConstraint(NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: minimumWidth))
		view.addConstraint(NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: minimumHeight))
    }
	
	func prepareWebViewController(webViewController: EditorWebViewController) {
		webViewController.setUpWebViewWithEditorConfiguration(editorConfiguration)
	}
	
	func setContentController(contentController: DocumentContentController) {
		webViewController.contentController = contentController
	}
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "webViewController" {
			webViewController = segue.destinationController as EditorWebViewController
			prepareWebViewController(webViewController)
		}
	}
}


let EditorWebViewController_icingReceiveContentJSONMessageIdentifier = "icingReceiveContentJSON"

class EditorWebViewController: NSViewController, DocumentContentEditor, WKNavigationDelegate, WKScriptMessageHandler {
	internal var editorConfiguration: EditorConfiguration!
	internal var webView: WKWebView!
	internal var latestCopiedJSONData: NSData!
	
	func setUpWebViewWithEditorConfiguration(editorConfiguration: EditorConfiguration) {
		self.editorConfiguration = editorConfiguration
		
		let preferences = WKPreferences()
		preferences.javaEnabled = false
		preferences.plugInsEnabled = false
		
		#if DEBUG
			preferences.setValue(true, forKey: "developerExtrasEnabled")
		#endif
		
		let webViewConfiguration = WKWebViewConfiguration()
		webViewConfiguration.preferences = preferences
		
		let userContentController = WKUserContentController()
		userContentController.addScriptMessageHandler(self, name: EditorWebViewController_icingReceiveContentJSONMessageIdentifier)
		webViewConfiguration.userContentController = userContentController
		
		webView = WKWebView(frame: NSRect.zeroRect, configuration: webViewConfiguration)
		webView.navigationDelegate = self
		self.fillViewWithChildView(webView)
		
		let URLRequest = NSURLRequest(URL: editorConfiguration.editorURL)
		webView.loadRequest(URLRequest)
	}
	
	var contentController: DocumentContentController! {
		didSet {
			println("did set contentController \(webView.loading)")
			if !webView.loading {
				self.setUpWithJSONContent()
			}
		}
	}
	
	var hasSetUpContent = false
	
	func setUpWithJSONContent() {
		println("setUpWithJSONContent")
		
		if hasSetUpContent {
			return
		}
		
		if contentController == nil {
			return
		}
		
		// TODO: escape IDs properly
		
		var documentID = "untitled"
		var sectionID = "main"
		
		contentController.useLatestJSONDataOnMainQueue { (contentJSONData) -> Void in
			var javaScriptString: String!
			
			println("Using content JSON Data \(contentJSONData) to set up web view")
			if contentJSONData != nil {
				if let JSONString = NSString(data: contentJSONData!, encoding: NSUTF8StringEncoding) {
					javaScriptString = "window.burntIcing.setInitialContentJSON(\(JSONString));"
					//let javaScriptString = "document.getElementsByTagName('body')[0].style.setProperty('background-color', 'red');"
				}
			}
			
			if javaScriptString == nil {
				javaScriptString = "window.burntIcing.setInitialContentJSON(null);"
			}
			
			println("JavaScript String \(javaScriptString)")
			
			self.webView.evaluateJavaScript(javaScriptString) { (result, error) -> Void in
				println("error \(error)")
			}
			
			self.contentController.editor = self
			self.hasSetUpContent = true
		}
	}
	
	func useLatestContentJSONDataOnMainQueue(callback: (NSData?) -> Void) {
		println("useLatestContentJSONDataOnMainQueue")
		
		let javaScriptString = "window.burntIcing.copyContentJSONForCurrentDocumentSection()"
		
		println("JavaScript String \(javaScriptString)")
		
		webView.evaluateJavaScript(javaScriptString) { (result, error) -> Void in
			var contentJSONData: NSData?
			
			if let contentJSON: AnyObject = result {
				contentJSONData = NSJSONSerialization.dataWithJSONObject(contentJSON, options: NSJSONWritingOptions(0), error: nil)!
			}
			else {
				println("error \(error)")
			}
			
			NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
				callback(contentJSONData)
			})
		}
	}
	
	func usePreviewHTMLStringOnMainQueue(callback: (String?) -> Void) {
		let javaScriptString = "window.burntIcing.copyPreviewHTMLForCurrentDocumentSection()"
		
		println("JavaScript String \(javaScriptString)")
		
		webView.evaluateJavaScript(javaScriptString) { (result, error) -> Void in
			var previewHTMLString = result as? String
			
			if previewHTMLString == nil {
				println("error \(error)")
			}
			
			NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
				callback(previewHTMLString)
			})
		}
	}
	
	@IBAction func reload(sender: AnyObject) {
		webView.reload()
	}
	
	func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
		println("didFinishNavigation")
		self.setUpWithJSONContent()
	}
	
	func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
		println("didReceiveScriptMessage \(message)")
		if message.name == EditorWebViewController_icingReceiveContentJSONMessageIdentifier {
			if let messageBody = message.body as? [String: AnyObject] {
				if let contentJSON = messageBody["contentJSON"] as? [String: AnyObject] {
					//latestCopiedJSONData = NSJSONSerialization.dataWithJSONObject(contentJSON, options: NSJSONWritingOptions(0), error: nil)
				}
			}
		}
	}
}
