//
//  Category+CoreDataProperties.swift
//  Phrasebook
//
//  Created by Christine Røde on 01/09/2024.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var symbol: String?
    @NSManaged public var phrases: NSSet?
    @NSManaged public var subcategories: Subcategory?

}

// MARK: Generated accessors for phrases
extension Category {

    @objc(addPhrasesObject:)
    @NSManaged public func addToPhrases(_ value: Phrase)

    @objc(removePhrasesObject:)
    @NSManaged public func removeFromPhrases(_ value: Phrase)

    @objc(addPhrases:)
    @NSManaged public func addToPhrases(_ values: NSSet)

    @objc(removePhrases:)
    @NSManaged public func removeFromPhrases(_ values: NSSet)

}

extension Category : Identifiable {

}
