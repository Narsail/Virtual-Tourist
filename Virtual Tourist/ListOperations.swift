//
//  ListOperations.swift
//  EMNetwork
//
//  Created by David Moeller on 06/09/2016.
//
//

import Foundation

public class ListGETOperation<A: Mappable>: ServiceOperation {
	
	private let request: BackendAPIRequestProtocol
	private let responseMapper: Mapper<A>
	private let arrayMapper: ArrayMapper<A>
	
	public var success: ((_ list: [A]) -> Void)?
	public var failure: ((_ error: Error) -> Void)?
	
	internal init(request: BackendAPIRequestProtocol, backendConfiguration: BackendConfiguration, arrayMapper: ArrayMapper<A>, responseMapper: Mapper<A>, success: ((_ list: [A]) -> Void)? = nil, failure: ((_ error: Error) -> Void)? = nil) {
		self.request = request
		self.success = success
		self.failure = failure
		self.responseMapper = responseMapper
		self.arrayMapper = arrayMapper
		super.init(backendConfiguration: backendConfiguration)
	}
	
	public override func start() {
		super.start()
		service.request(request: self.request, success: self.handleSuccess, failure: self.handleFailure)
	}
	
	private func handleSuccess(response: Any?) {
		// Just acknowledge delegate
		do {
			NSLog("Response: \(response)")
			let list = try self.arrayMapper.process(obj: response, mapper: responseMapper.map)
			self.success?(list)
			self.finish()
		} catch {
			handleFailure(error: error)
		}
	}
	
	private func handleFailure(error: Error) {
		self.failure?(error)
		self.finish()
	}
	
}
