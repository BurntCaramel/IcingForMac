//
//  ViewController.swift
//  BurntIcing
//
//  Created by Patrick Smith on 14/02/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa
import BurntIcingModel


class ViewController: NSViewController {
	var editorViewController: EditorViewController!
	

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//println("view did load from storyboard \(self.storyboard) parentViewController: \(self.parentViewController)")

		let storyboard = NSStoryboard(name: "Editor", bundle: nil)!
		editorViewController = storyboard.instantiateControllerWithIdentifier("Editor View Controller") as! EditorViewController
		self.addChildViewController(editorViewController)
		
		//println("create editor view controller from storyboard \(storyboard)")
		
		self.fillViewWithChildView(editorViewController.view)
	}

	override var representedObject: AnyObject? {
		didSet {
			if let contentController = representedObject as? DocumentContentController {
				editorViewController.setContentController(contentController)
			}
		}
	}
}

