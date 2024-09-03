//
//  Subcategory+CoreDataProperties.swift
//  Phrasebook
//
//  Created by Christine Røde on 01/09/2024.
//
//

import Foundation
import CoreData


extension Subcategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subcategory> {
        return NSFetchRequest<Subcategory>(entityName: "Subcategory")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: Category?
    @NSManaged public var phrases: Phrase?

}

extension Subcategory : Identifiable {

}
