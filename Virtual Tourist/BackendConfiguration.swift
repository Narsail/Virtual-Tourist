//
//  BackendConfiguration.swift
//  EMClient
//
//  Created by David Moeller on 11/08/16.
//
//

import Foundation

public protocol BackendAuth {
	
	func headerParameters() -> [String: String]
	
}

public final class BackendConfiguration {
	
	public let baseURL: URL
	let auth: BackendAuth?
	
	public init(baseURL: URL, withAuth auth: BackendAuth? = nil) {
		self.baseURL = baseURL
		self.auth = auth
	}
	
	public static var shared: BackendConfiguration?
	
}
