//
//  DocumentWindowController.swift
//  BurntIcing
//
//  Created by Patrick Smith on 3/03/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa
import BurntIcingModel


class DocumentWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
		
		//println("window did load \(contentViewController)")
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
	
	var contentController: DocumentContentController! {
		didSet {
			contentViewController?.representedObject = contentController
		}
	}
}
