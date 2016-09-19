//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by David Moeller on 17/09/2016.
//  Copyright © 2016 David Moeller. All rights reserved.
//

import CoreData
import UIKit

struct  CoreDataStack {
	
	// MARK: - Properties
	fileprivate let model: NSManagedObjectModel
	fileprivate let coordinator: NSPersistentStoreCoordinator
	fileprivate let modelURL: URL
	fileprivate let dbURL: URL
	let context: NSManagedObjectContext
	let backgroundContext: NSManagedObjectContext
	
	// MARK: - Initializers
	init?(modelName: String) {
		
		// Assumes the model is in the main bundle
		guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
			print("Unable to find \(modelName) in the main bundle")
			return nil
		}
		
		self.modelURL = modelURL
		
		guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
			print("unable to create a model from \(modelURL)")
			return nil
		}
		
		self.model = model
		
		// Create the store coordinator
		coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
		
		// create a context and connect it to the coordinator
		context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.persistentStoreCoordinator = coordinator
		
		backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		backgroundContext.persistentStoreCoordinator = coordinator
		
		// Add a SQLite store located in the documents folder
		let fm = FileManager.default
		
		guard let docURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
			print("Unable to reach the documents folder")
			return nil
		}
		
		let dbURL = docURL.appendingPathComponent("model.sqlite")
		
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
		} catch {
			print("unable to add store at \(dbURL)")
		}
		
		self.dbURL = dbURL
	}
	
}

extension CoreDataStack {
	
	func dropAllData() throws {
		try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
	}
	
	func saveContext() throws {
		if context.hasChanges {
			try context.save()
		}
	}
	
	func autoSave(delayInSeconds: Int) {
		
		if delayInSeconds > 0 {
			do {
				try saveContext()
				print("Autosaving (Delay: \(delayInSeconds))")
			} catch {
				print("Error while autosaving")
			}
			
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delayInSeconds), execute: {
				self.autoSave(delayInSeconds: delayInSeconds)
			})
			
		}
	}
	
}
