//
//  SingleOperations.swift
//  EMNetwork
//
//  Created by David Moeller on 06/09/2016.
//
//

import Foundation

public class GETOperation<A: Mappable>: ServiceOperation {
	
	private let request: BackendAPIRequestProtocol
	private let responseMapper: Mapper<A>
	
	public var success: ((_ object: A) -> Void)?
	public var failure: ((_ error: Error) -> Void)?
	
	internal init(request: BackendAPIRequestProtocol, backendConfiguration: BackendConfiguration, responseMapper: Mapper<A>, success: ((_ object: A) -> Void)? = nil, failure: ((_ error: Error) -> Void)? = nil) {
		self.request = request
		self.success = success
		self.failure = failure
		self.responseMapper = responseMapper
		super.init(backendConfiguration: backendConfiguration)
	}
	
	public override func start() {
		super.start()
		service.request(request: self.request, success: self.handleSuccess, failure: self.handleFailure)
	}
	
	private func handleSuccess(response: Any?) {
		// Just acknowledge delegate
		do {
			let object = try responseMapper.map(obj: response)
			self.success?(object)
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

public class POSTOperation: ServiceOperation {
	
	private let request: BackendAPIRequestProtocol
	
	public var success: ((Void) -> Void)?
	public var failure: ((_ error: Error,_ request: BackendAPIRequestProtocol) -> Void)?
	
	internal init(request: BackendAPIRequestProtocol, backendConfiguration: BackendConfiguration, success: ((Void) -> Void)? = nil, failure: ((_ error: Error,_ request: BackendAPIRequestProtocol) -> Void)? = nil) {
		self.request = request
		self.success = success
		self.failure = failure
		super.init(backendConfiguration: backendConfiguration)
	}
	
	public override func start() {
		super.start()
		service.request(request: self.request, success: self.handleSuccess, failure: self.handleFailure)
	}
	
	private func handleSuccess(response: Any?) {
		// Just acknowledge delegate
		self.success?()
		self.finish()
	}
	
	private func handleFailure(error: Error) {
		self.failure?(error, request)
		self.finish()
	}
	
}

public class DELETEOperation: ServiceOperation {
	
	private let request: BackendAPIRequestProtocol
	
	public var success: ((Void) -> Void)?
	public var failure: ((_ error: Error,_ request: BackendAPIRequestProtocol) -> Void)?
	
	internal init(request: BackendAPIRequestProtocol, backendConfiguration: BackendConfiguration, success: ((Void) -> Void)? = nil, failure: ((_ error: Error,_ request: BackendAPIRequestProtocol) -> Void)? = nil) {
		self.request = request
		self.success = success
		self.failure = failure
		super.init(backendConfiguration: backendConfiguration)
	}
	
	public override func start() {
		super.start()
		service.request(request: self.request, success: self.handleSuccess, failure: self.handleFailure)
	}
	
	private func handleSuccess(response: Any?) {
		// Just acknowledge delegate
		self.success?()
		self.finish()
	}
	
	private func handleFailure(error: Error) {
		self.failure?(error, request)
		self.finish()
	}
	
}

