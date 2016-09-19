//
//  ResponseMapper.swift
//  EMNetwork
//
//  Created by David Moeller on 27/08/16.
//
//

import Foundation


final class ArrayResponseMapper<A: Mappable>: ArrayMapping {
	
	typealias Item = A
	
	func process(obj: Any?, mapper: ((Any?) throws -> A)) throws -> [A] {
		guard let json = obj as? [[String: Any]] else { throw MapperError.invalid }
		
		var items = [A]()
		for jsonNode in json {
			let item = try mapper(jsonNode)
			items.append(item)
		}
		return items
	}
}

class ArrayMapper<A: Mappable>: ArrayMapping {
	
	typealias Item = A
	var processFunction: ((_ obj: Any?, _ mapper: ((Any?) throws -> Item)) throws -> [Item])
	
	init<Base: ArrayMapping>(base: Base) where Base.Item == A {
		processFunction = base.process
	}
	
	func process(obj: Any?, mapper: ((Any?) throws -> A)) throws -> [A] {
		return try self.processFunction(obj, mapper)
	}
	
}

protocol ArrayMapping {
	associatedtype Item
	func process(obj: Any?, mapper: ((Any?) throws -> Item)) throws -> [Item]
	
}

class Mapper<A: Mappable>: Mapping {
	
	typealias Item = A
	
	var mapFunction: ((_ obj: Any?) throws -> A)
	var serializeFunction: ((_ item: A) throws -> [String: Any])
	
	init<Base: Mapping>(base : Base) where Base.Item == A {
		mapFunction = base.map
		serializeFunction = base.serialize
	}
	
	func map(obj: Any?) throws -> A {
		return try mapFunction(obj)
	}
	
	func serialize(item: A) throws -> [String : Any] {
		return try serializeFunction(item)
	}
	
}

protocol Mapping {
	associatedtype Item
	func map(obj: Any?) throws -> Item
	func serialize(item: Item) throws -> [String: Any]
	
}

extension Mapping {
	func extractJSON(obj: Any?, parse: (_ json: [String: Any]) throws -> Item) throws -> Item {
		guard let json = obj as? [String: Any] else { throw MapperError.invalid }
		return try parse(json)
	}
}

public protocol Mappable { }

internal enum MapperError: Error {
	case invalid
	case missingAttribute(attribute: String)
	case empty
}
