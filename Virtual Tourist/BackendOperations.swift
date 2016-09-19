//
//  BackendOperations.swift
//  EMClient
//
//  Created by David Moeller on 20/08/16.
//
//

import Foundation

public class ServiceOperation: NetworkOperation {
	
	let service: BackendService
	
	internal init(backendConfiguration: BackendConfiguration) {
		self.service = BackendService(backendConfiguration)
		super.init()
	}
	
	public override func cancel() {
		service.cancel()
		super.cancel()
	}
}

public class NetworkOperation: Operation {
	
	private var _ready: Bool
	public override var isReady: Bool {
		get { return _ready }
		set { update(change: { self._ready = newValue }, key: "isReady") }
	}
	
	private var _executing: Bool
	public override var isExecuting: Bool {
		get { return _executing }
		set { update(change: { self._executing = newValue }, key: "isExecuting") }
	}
	
	private var _finished: Bool
	public override var isFinished: Bool {
		get { return _finished }
		set { update(change: { self._finished = newValue }, key: "isFinished") }
	}
	
	private var _cancelled: Bool
	public override var isCancelled: Bool {
		get { return _cancelled }
		set { update(change: { self._cancelled = newValue }, key: "isCancelled") }
	}
	
	private func update(change: (Void) -> Void, key: String) {
		willChangeValue(forKey: key)
		change()
		didChangeValue(forKey: key)
	}
	
	override init() {
		_ready = true
		_executing = false
		_finished = false
		_cancelled = false
		super.init()
		name = "Network Operation"
	}
	
	public override var isAsynchronous: Bool {
		return true
	}
	
	public override func start() {
		if self.isExecuting == false {
			self.isReady = false
			self.isExecuting = true
			self.isFinished = false
			self.isCancelled = false
		}
	}
	
	/// Used only by subclasses. Externally you should use `cancel`.
	func finish() {
		self.isExecuting = false
		self.isFinished = true
	}
	
	public override func cancel() {
		self.isExecuting = false
		self.isCancelled = true
	}
}
