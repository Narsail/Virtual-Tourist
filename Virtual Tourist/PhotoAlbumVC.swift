//
//  PhotoAlbumVC.swift
//  Virtual Tourist
//
//  Created by David Moeller on 17/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumVC: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var newCollectionButton: UIBarButtonItem!
	
	@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
	
	var annotation: PinAnnotation?
	
	var fetchedResultsController : NSFetchedResultsController<Photo>?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		let stack = getStack()
		
		// Create a fetchrequest
		let fr = NSFetchRequest<Photo>(entityName: "Photo")
		fr.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true)]
		
		fr.predicate = NSPredicate(format: "pin = %@", argumentArray: [annotation!.pin])
		
		// Create the FetchedResultsController
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
		do{
			try fetchedResultsController!.performFetch()
		} catch {
			NSLog("Error while fetching Results: \(error)")
		}
		self.collectionView.reloadData()
		fetchedResultsController?.delegate = self
		
		newCollectionButton.isEnabled = !annotation!.loadingPhotos
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Configure Collection View Flow Layout
		let space: CGFloat = 3.0
		let dimension = (view.frame.size.width - (2 * space)) / 3.0
		
		flowLayout.minimumInteritemSpacing = space
		flowLayout.minimumLineSpacing = space
		flowLayout.itemSize = CGSize(width: dimension, height: dimension)
		
	}

	@IBAction func newCollectionAction(_ sender: AnyObject) {
		
		newCollectionButton.isEnabled = false
		annotation!.loadingPhotos = true
		
		let stack = getStack()
		
		/* Delete all photos of a Pin */
		// Get all Photos - FetchRequest
		let fr = NSFetchRequest<Photo>(entityName: "Photo")
		fr.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true)]
		fr.predicate = NSPredicate(format: "pin = %@", argumentArray: [annotation!.pin])
		
		do {
			let fetchResults = try getStack().context.fetch(fr) as [Photo]
			
			// Delete those Results
			for result in fetchResults {
				stack.context.delete(result)
			}
			try? stack.saveContext()
		} catch {
			NSLog("Error occurred while fetching Data from CoreData. Error: \(error)")
		}
		
		annotation?.incrementPage()
		
		downloadPhotoDetailsList(withPin: annotation!.pin, page: annotation!.page, withCompletionHandler: { detailsState in
			self.annotation?.photoDetailsState = detailsState
		}, withErrorHandler: { error in
			self.annotation!.loadingPhotos = false
		})
		
	}

}

extension PhotoAlbumVC: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		
		if let fc = fetchedResultsController, let sections = fc.sections {
			return (sections.count)
		} else {
			return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let fc = fetchedResultsController {
			return fc.sections![section].numberOfObjects
		} else {
			return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		// Find the right photo for this indexpath
		let photo = fetchedResultsController!.object(at: indexPath) 
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
		
		cell.initialize(withPhoto: photo)

		if photo.loading {
			cell.startsIndicator()
		} else {
			cell.stopIndicator()
		}
		
		return cell
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let fc = fetchedResultsController {
			
			let object = fc.object(at: indexPath)
			
			let stack = getStack()
			
			stack.context.delete(object)
			
		}
	}
}

extension PhotoAlbumVC: NSFetchedResultsControllerDelegate {

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		
		let set = IndexSet(integer: sectionIndex)
		
		switch (type) {
		case .insert:
			collectionView.insertSections(set)
		case .delete:
			collectionView.deleteSections(set)
		default: break
		}
		
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

		if let results = controller.fetchedObjects {
			if results.isEmpty {
				self.collectionView.reloadData()
				return
			}
		}
		
		switch(type) {
		case .insert:
			collectionView.insertItems(at: [newIndexPath!])
		case .delete:
			collectionView.deleteItems(at: [indexPath!])
		case .update:
			collectionView.reloadItems(at: [indexPath!])
		case .move:
			collectionView.deleteItems(at: [indexPath!])
			collectionView.insertItems(at: [newIndexPath!])
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		
		self.newCollectionButton.isEnabled = !annotation!.loadingPhotos

	}
	
}
