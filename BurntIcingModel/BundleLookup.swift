//
//  BundleLookup.swift
//  Icing
//
//  Created by Patrick Smith on 17/03/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Foundation


internal class BurntIcingModelBundleClassLookup : NSObject {
	// Used for NSBundle lookup below
}

public extension NSBundle {
	public class func bundleForBurntIcingModel() -> NSBundle {
		return NSBundle(forClass: BurntIcingModelBundleClassLookup.self)
	}
}