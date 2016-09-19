//
//  Backend.swift
//  EMClient
//
//  Created by David Moeller on 11/08/16.
//
//

import Foundation

enum BackendServiceError: Error {
	case responseCode(code: Int)
}

class BackendService {
	
	private let conf: BackendConfiguration
	private let service: NetworkService!
	
	init(_ conf: BackendConfiguration) {
		self.conf = conf
		self.service = NetworkService()
	}
	
	func request(request: BackendAPIRequestProtocol,
	             success: ((Any?) -> Void)? = nil,
	             failure: ((Error) -> Void)? = nil) {
		
		guard let url = URL(string: request.endpoint, relativeTo: conf.baseURL) else {
			print("Can't build URL with Base: \(conf.baseURL) and Endpoint: \(request.endpoint)")
			return
		}
		
		var headers = request.headers
		// Set authentication token if available.
		if let auth = self.conf.auth {
			for (key, value) in auth.headerParameters() {
				headers?[key] = value
			}
		}
		
		service.request(url: url, method: request.method, params: request.parameters, headers: headers, success: { data in
			var json: Any? = nil
			if let data = data {
				json = try? JSONSerialization.jsonObject(with: data as Data, options: [])
			}
			
			success?(json)
			
			}, failure: { data, error, statusCode in
				// Do stuff you need, and call failure block.
				if error != nil {
					failure?(error!)
				} else {

					failure?(BackendServiceError.responseCode(code: statusCode))
					// TODO: Map responsecode or data to new Error
				}
				
		})
	}
	
	func cancel() {
		service.cancel()
	}
}

public class NetworkService {
	
	private var task: URLSessionDataTask?
	private var successCodes: Range<Int> = 200..<299
	private var failureCodes: Range<Int> = 400..<499
	
	public enum Method: String {
		case GET, POST, PUT, DELETE
	}
	
	func request(url: URL, method: Method,
	             params: [String: Any]? = nil,
	             headers: [String: String]? = nil,
	             success: ((Data?) -> Void)? = nil,
	             failure: ((_ data: Data?, _ error: Error?, _ responseCode: Int) -> Void)? = nil) {
		
		NSLog("URL: \(url)")
		
		let mutableRequest = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
		                                         timeoutInterval: 10.0)
		
		NSLog("MutableRequest: \(mutableRequest)")
		mutableRequest.allHTTPHeaderFields = headers
		mutableRequest.httpMethod = method.rawValue
		if let params = params {
			mutableRequest.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
		}
		
		let session = URLSession.shared
		task = session.dataTask(with: mutableRequest as URLRequest, completionHandler: { data, response, error in
			// Decide whether the response is success or failure and call
			// proper callback.
			
			var responseCode = 0
			
			if let response = response as? HTTPURLResponse {
				responseCode = response.statusCode
			}
			
			if responseCode > 300 {
				failure?(data, error, responseCode)
				return
			}
			
			if data != nil && error == nil {
				success?(data!)
			} else {
				failure?(data, error, responseCode)
			}
		})
		
		task?.resume()
	}
	
	func cancel() {
		task?.cancel()
	}
}

public protocol BackendAPIRequestProtocol {
	var endpoint: String { get }
	var method: NetworkService.Method { get }
	var parameters: [String: Any]? { get }
	var headers: [String: String]? { get }
}

extension BackendAPIRequestProtocol {
	
	func defaultJSONHeaders() -> [String: String] {
		return ["Content-Type": "application/json"]
	}
	
}
