//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by David Moeller on 17/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsVC: UIViewController, MKMapViewDelegate {

	@IBOutlet weak var mapView: MKMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set Gesture Recognizer to set the Annotation
		
		let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsVC.setAnnotation(_:)))
		self.mapView.addGestureRecognizer(recognizer)
		
		self.mapView.delegate = self
		
		// Load all Pins and display them
		do {
			let fetchResults = try getStack().context.fetch(Pin.fetchRequest()) as [Pin]
			
			self.set(withPins: fetchResults)
			
		} catch {
			NSLog("Got Error while fetching: \(error)")
		}
		
		let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(52.5243700), longitude: CLLocationDegrees(13.4105300))
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(100, 100))
		
		self.mapView.setRegion(region, animated: true)
		
	}
	
	// MARK: - Map Methods
	
	func setAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
		if gestureRecognizer.state == UIGestureRecognizerState.ended {
			let touchPoint = gestureRecognizer.location(in: self.mapView)
			let newCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
			let annotation = createPinAndAnnotation(withCoordinates: newCoordinates)
			self.mapView.addAnnotation(annotation)
		}
	}
	
	func set(withPins pins: [Pin]) {
		
		let annotations = pins.map({ PinAnnotation(title: nil, pin: $0) })
		
		self.mapView.addAnnotations(annotations)
		
	}
	
	// MARK: - Delegate Methods
	
	func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		
		for annotationView in views {
			let endFrame = annotationView.frame
			
			annotationView.frame = CGRect(x: annotationView.frame.origin.x, y: annotationView.frame.origin.y - 100,
			                              width: annotationView.frame.size.width, height: annotationView.frame.size.height)
			
			UIView.beginAnimations(nil, context: nil)
			UIView.setAnimationDuration(0.45)
			UIView.setAnimationCurve(UIViewAnimationCurve.easeInOut)
			annotationView.frame = endFrame
			UIView.commitAnimations()
		}
		
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		
		guard let annotation = view.annotation as? PinAnnotation else {
			return
		}
		
		self.mapView.deselectAnnotation(annotation, animated: false)
		
		performSegue(withIdentifier: "showCollectionView", sender: annotation)
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let vc = segue.destination as? PhotoAlbumVC, let annotation = sender as? PinAnnotation else {
			return
		}
		
		vc.annotation = annotation
		
	}
	
	// MARK: - Pin Methods
	
	@IBAction func deleteAllPins(_ sender: AnyObject) {
		
		NSLog("Delete Pins")
		
		let annotations = self.mapView.annotations as! [PinAnnotation]
		
		// Remove annotations from Map
		self.mapView.removeAnnotations(annotations)
		
		let stack = getStack()
		
		for annotation in annotations {
			stack.context.delete(annotation.pin)
		}
		try? stack.saveContext()
		
	}
	

}

