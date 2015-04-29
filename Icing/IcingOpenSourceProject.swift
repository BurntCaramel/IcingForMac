//
//  IcingOpenSourceProject.swift
//  Icing
//
//  Created by Patrick Smith on 24/03/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Cocoa


enum IcingOpenSourceProject {
	case IcingEditor
	case Specs
	case IcingPHP
	
	var URL: NSURL {
		switch self {
		case .IcingEditor:
			return NSURL(string: "https://github.com/BurntIcing/IcingEditor")!
		case .Specs:
			return NSURL(string: "https://github.com/BurntIcing/Specs")!
		case .IcingPHP:
			return NSURL(string: "https://github.com/BurntIcing/IcingPHP")!
		}
	}
	
	func openURL() {
		NSWorkspace.sharedWorkspace().openURL(URL)
	}
}
