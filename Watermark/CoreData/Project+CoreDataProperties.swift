//
//  Project+CoreDataProperties.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 05/02/2025.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var createDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var name: String?

}

extension Project : Identifiable {

}
