//
//  DataBaseManager.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 05/02/2025.
//

import UIKit
import CoreData

protocol DataBaseManager {
	func createProject(id: String, name: String)
	func updateProject(id: String, name: String)
	func load<T: NSManagedObject>() -> [T]
	func delete(id: String, type: NSManagedObject.Type)
}

final class DataBaseManagerImpl: DataBaseManager {
	
	static var shared = DataBaseManagerImpl()
	
	// MARK: - Private properties
	private var appDelegate: AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}
	
	private var persistentContainer: NSPersistentContainer {
		return appDelegate.persistentContainer
	}
	
	private var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	private init() {}
	
	// MARK: - DataBaseManager
	func createProject(id: String, name: String) {
		guard let projectEntityDescription = NSEntityDescription.entity(forEntityName: "Project", in: context) else {
			return
		}
		
		let project = Project(entity: projectEntityDescription, insertInto: context)
		project.name = name
		project.id = id
		project.createDate = Date()
		
		appDelegate.saveContext()
	}
	
	func updateProject(id: String, name: String) {
		let updateRequest = NSBatchUpdateRequest(entityName: "Project")
		updateRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
		updateRequest.propertiesToUpdate = ["name": name]
		
		do {
			try context.execute(updateRequest)
			appDelegate.saveContext()
		} catch {
			print("ERROR: error while updating \(error)")
		}
	}
	
	func load<T: NSManagedObject>() -> [T] {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(T.self)")
		return (try? context.fetch(fetchRequest) as? [T]) ?? []
	}
	
	func delete(id: String, type: NSManagedObject.Type) {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(type.self)")
		fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
		
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		
		do {
			try context.execute(deleteRequest)
			appDelegate.saveContext()
		} catch {
			print("ERROR: error while deleting \(error)")
		}
	}
}
