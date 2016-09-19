
import Foundation

class FlickrPlaceRequest: BackendAPIRequestProtocol {
	
	let pin: Pin
	let auth: FlickrAuth
	
	init(pin: Pin, auth: FlickrAuth) {
		self.pin = pin
		self.auth = auth
	}
	
	var endpoint: String {
		
		return "?method=flickr.places.findByLatLon&lat=\(self.pin.latitude)&lon=\(self.pin.longitude)&api_key=\(auth.key)&format=json&nojsoncallback=1"
	}
	
	var method: NetworkService.Method {
		return .GET
	}
	
	var parameters: [String: Any]? {
		return nil
	}
	
	var headers: [String: String]? {
		return self.defaultJSONHeaders()
	}
	
}

class PhotoDetailsListRequest: BackendAPIRequestProtocol {
	
	let place: FlickrPlace
	let auth: FlickrAuth
	let limitPerPage: Int
	let page: Int
	
	init(place: FlickrPlace, auth: FlickrAuth, limitPerPage: Int = 20, page: Int = 1) {
		self.place = place
		self.auth = auth
		self.limitPerPage = limitPerPage
		self.page = page
	}
	
	var endpoint: String {
		return "?method=flickr.photos.search&place_id=\(place.placeID)&woe_id=\(place.woeID)&api_key=\(auth.key)&format=json&nojsoncallback=1&per_page=\(limitPerPage)&page=\(page)"
	}

	var method: NetworkService.Method {
		return .GET
	}

	var parameters: [String: Any]? {
		return nil
	}

	var headers: [String: String]? {
		return self.defaultJSONHeaders()
	}
	
}
