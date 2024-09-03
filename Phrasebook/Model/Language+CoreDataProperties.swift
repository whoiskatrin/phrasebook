//
//  Language+CoreDataProperties.swift
//  Phrasebook
//
//  Created by Christine Røde on 01/09/2024.
//
//

import Foundation
import CoreData


extension Language {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Language> {
        return NSFetchRequest<Language>(entityName: "Language")
    }

    @NSManaged public var language: String?
    @NSManaged public var phrases: NSSet?

}

// MARK: Generated accessors for phrases
extension Language {

    @objc(addPhrasesObject:)
    @NSManaged public func addToPhrases(_ value: Phrase)

    @objc(removePhrasesObject:)
    @NSManaged public func removeFromPhrases(_ value: Phrase)

    @objc(addPhrases:)
    @NSManaged public func addToPhrases(_ values: NSSet)

    @objc(removePhrases:)
    @NSManaged public func removeFromPhrases(_ values: NSSet)

}

extension Language : Identifiable {

}
