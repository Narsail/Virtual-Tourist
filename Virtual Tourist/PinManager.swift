//
//  PinManager.swift
//  Virtual Tourist
//
//  Created by David Moeller on 17/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import Foundation
import MapKit
import CoreData

func createPinAndAnnotation(withCoordinates coordinate: CLLocationCoordinate2D) -> PinAnnotation {
	
	let stack = getStack()
	
	// Create new Pin
	let pin = Pin(coordinate: coordinate, context: stack.context)
	
	let annotation = PinAnnotation(title: nil, pin: pin)
	annotation.loadingPhotos = true
	
	downloadPhotoDetailsList(withPin: pin, withCompletionHandler: { detailsState in
		annotation.photoDetailsState = detailsState
	}, withErrorHandler: { error in
		annotation.loadingPhotos = false
	})
	
	return annotation
	
}

func downloadPhotoDetailsList(withPin pin: Pin, page: Int = 1, withCompletionHandler completionHandler: @escaping (_ photoDetailsListState: FlickrPhotoDetailsState) -> Void, withErrorHandler errorHandler: @escaping (_ error: Error) -> Void) {
	FlickrRESTAPI.shared.fetchPlaceForPin(pin: pin, withCompletionHandler: { place in
		FlickrRESTAPI.shared.fetchPhotoDetailList(withPlace: place, page: page, withCompletionHandler: { list in
			if list.isEmpty {
				NSLog("List of Photos is empty")
			} else {
				completionHandler(FlickrPhotoDetailsState.photos(photos: list))
			}
			}, withErrorHandler: { error in
				NSLog("No PhotoDetails found with Error: \(error)")
				errorHandler(error)
		})
		}, withErrorHandler: { error in
			NSLog("No Place found with Error: \(error)")
			errorHandler(error)
	})
}

func downloadPhotos(forPin pin: Pin, andPhotoDetailsList photoDetailsList: [FlickrPhotoDetails], withCompletionHandler completionHandler: (() -> ())? = nil) {
	
	DispatchQueue.main.async {
		let stack = getStack()
		
		/* Fetch Images */
	
		var counter = photoDetailsList.count
		
		func decrementCounter() {
			counter -= 1
			if counter == 0 {
				completionHandler?()
			}
		}
		
		for photoDetails in photoDetailsList {
			
			let photo = Photo(image: nil, flickrUrl: photoDetails.photoURL, loading: true, context: stack.context)
			try? stack.saveContext()
			
			// Download Image
			downloadImageData(url: photoDetails.photoURL, withCompletionHandler: { data in
				photo.imageData = data as NSData
				photo.loading = false
				decrementCounter()
			}, withErrorHandler: { error in
				NSLog("Download of Image failed: \(error)")
				photo.loading = false
				decrementCounter()
			})
			
			photo.pin = pin
			
		}
	}
	
}

// MARK: Image Download Methods

func downloadImageData(url: String, withCompletionHandler completionHandler: @escaping (_ image: Data) -> Void, withErrorHandler errorHandler: @escaping (_ error: Error) -> Void) {
	guard let checkedUrl = URL(string: url) else { return }
	getDataFromUrl(url: checkedUrl) { (data, response, error)  in
		DispatchQueue.main.sync() { () -> Void in
			
			guard let data = data, error == nil else { errorHandler(error!); return }
			
			completionHandler(data)
			
		}
	}
}

func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
	URLSession.shared.dataTask(with: url) {
		(data, response, error) in
		completion(data, response, error)
	}.resume()
}
