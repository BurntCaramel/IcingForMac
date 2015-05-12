//
//  Either.swift
//  Icing
//
//  Created by Patrick Smith on 30/04/2015.
//  Copyright (c) 2015 Burnt Caramel. All rights reserved.
//

import Foundation


enum Either<A: AnyObject, B: AnyObject> {
	case Some(A)
	case Other(B)
	
	init(_ main: A) {
		self = .Some(main)
	}
	
	init(_ other: B) {
		self = .Other(other)
	}
	
	var both: (A?, B?) {
		switch self {
		case .Some(let value):
			return (value, nil)
		case .Other(let value):
			return (nil, value)
		}
	}
	
	var some: A? {
		switch self {
		case .Some(let value):
			return value
		default:
			return nil
		}
	}
	
	var other: B? {
		switch self {
		case .Other(let value):
			return value
		default:
			return nil
		}
	}
	
	/*
	subscript(boolValue: ()) -> AnyObject {
		switch self {
		case .Some(let value):
			return value
		case .Alternative(let value):
			return value
		}
	}
	*/
}
