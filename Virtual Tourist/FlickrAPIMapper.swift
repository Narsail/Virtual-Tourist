
import Foundation

extension FlickrPhotoDetails: Mappable {}

extension FlickrPlace: Mappable {}

final class ArrayPhotoDetailsMapper: ArrayMapping {
	
	typealias Item = FlickrPhotoDetails
	
	func process(obj: Any?, mapper: ((Any?) throws -> Item)) throws -> [Item] {
		guard let json = obj as? [String: Any] else { throw MapperError.invalid }
		
		guard let photos = json["photos"] as? [String: Any] else {
			throw MapperError.missingAttribute(attribute: "photos")
		}
		
		guard let photo = photos["photo"] as? [[String: Any]] else {
			throw MapperError.missingAttribute(attribute: "photo")
		}
		
		
		
		var items = [Item]()
		for jsonNode in photo {
			let item = try mapper(jsonNode)
			items.append(item)
		}
		
		if let page = photos["page"] as? Int, let maxPage = photos["pages"] as? Int {
			items = items.map({
				return FlickrPhotoDetails(id: $0.id, owner: $0.owner, secret: $0.secret, server: $0.server, farm: $0.farm, page: page, maxPage: maxPage)
			})
			
		}
		
		return items
	}
}

final class FlickrPhotoDetailsMapper: Mapping {
	
	typealias Item = FlickrPhotoDetails
	
	func map(obj: Any?) throws -> Item {
		return try extractJSON(obj: obj, parse: { json in

			guard let id = json["id"] as? String else {
				throw MapperError.missingAttribute(attribute: "id")
			}
			
			guard let owner = json["owner"] as? String else {
				throw MapperError.missingAttribute(attribute: "owner")
			}
			
			guard let secret = json["secret"] as? String else {
				throw MapperError.missingAttribute(attribute: "secret")
			}
			
			guard let server = json["server"] as? String else {
				throw MapperError.missingAttribute(attribute: "server")
			}
			
			guard let farm = json["farm"] as? Int else {
				throw MapperError.missingAttribute(attribute: "farm")
			}
			
			return FlickrPhotoDetails(id: id, owner: owner, secret: secret, server: server, farm: String(farm), page: nil, maxPage: nil)
			
		})
	}

	func serialize(item: Item) -> [String : Any] {
		return ["":""]
	}
	
}

final class FlickrPlaceMapper: Mapping {
	
	typealias Item = FlickrPlace
	
	func map(obj: Any?) throws -> Item {
		return try extractJSON(obj: obj, parse: { json in
			
			guard let places = json["places"] as? [String: Any] else {
				throw MapperError.missingAttribute(attribute: "places")
			}
			
			guard let placeList = places["place"] as? [[String: Any]] else {
				throw MapperError.missingAttribute(attribute: "place")
			}
			
			guard let place = placeList.first else {
				throw MapperError.empty
			}
			
			guard let placeID = place["place_id"] as? String else {
				throw MapperError.missingAttribute(attribute: "place_id")
			}
			
			guard let woeid = place["woeid"] as? String else {
				throw MapperError.missingAttribute(attribute: "woeid")
			}
			
			return FlickrPlace(placeID: placeID, woeID: woeid)
			
		})
	}
	
	func serialize(item: Item) -> [String : Any] {
		return ["":""]
	}
	
}
