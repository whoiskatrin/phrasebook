//
//  Phrase+CoreDataProperties.swift
//  Phrasebook
//
//  Created by Christine Røde on 01/09/2024.
//
//

import Foundation
import CoreData


extension Phrase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Phrase> {
        return NSFetchRequest<Phrase>(entityName: "Phrase")
    }

    @NSManaged public var english: String?
    @NSManaged public var translation: String?
    @NSManaged public var romanization: String?
    @NSManaged public var category: Category?
    @NSManaged public var language: Language?
    @NSManaged public var subcategory: Subcategory?

}

extension Phrase : Identifiable {

}
