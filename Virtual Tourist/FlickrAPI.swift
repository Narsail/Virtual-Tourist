//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by David Moeller on 18/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import Foundation

final class FlickrRESTAPI {
	
	internal static let shared = FlickrRESTAPI()
	
	let backendQueue = OperationQueue()
	let configuration: BackendConfiguration
	
	private init() {
		let auth = FlickrAuth()
		configuration = BackendConfiguration(baseURL: URL(string: "https://api.flickr.com/services/rest/")!, withAuth: auth)
	}
	
	func fetchPlaceForPin(pin: Pin, withCompletionHandler completionHandler: @escaping (_ place: FlickrPlace) -> (Void), withErrorHandler errorHandler: @escaping (_ error: Error) -> (Void)) {
		let request = FlickrPlaceRequest(pin: pin, auth: configuration.auth as! FlickrAuth)
		let mapper = Mapper(base: FlickrPlaceMapper())
		let operation = GETOperation(request: request, backendConfiguration: configuration, responseMapper: mapper, success: { place in
			completionHandler(place)
		}, failure: { error in
			errorHandler(error)
		})
		backendQueue.addOperation(operation)
	}
	
	func fetchPhotoDetailList(withPlace place: FlickrPlace, page: Int = 1, withCompletionHandler completionHandler: @escaping (_ photoDetailsList: [FlickrPhotoDetails]) -> (Void), withErrorHandler errorHandler: @escaping (_ error: Error) -> (Void)) {
		let request = PhotoDetailsListRequest(place: place, auth: configuration.auth as! FlickrAuth, page: page)
		let arrayMapper = ArrayMapper(base: ArrayPhotoDetailsMapper())
		let mapper = Mapper(base: FlickrPhotoDetailsMapper())
		let operation = ListGETOperation(request: request, backendConfiguration: configuration, arrayMapper: arrayMapper, responseMapper: mapper, success: { photoDetailsList in
			completionHandler(photoDetailsList)
		}, failure: { error in
				errorHandler(error)
		})
		backendQueue.addOperation(operation)
	}
	
}
