//
//  HistoryList+CoreDataProperties.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-05.
//
//

import Foundation
import CoreData


extension HistoryList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryList> {
        return NSFetchRequest<HistoryList>(entityName: "HistoryList")
    }

    @NSManaged public var historyID: UUID?
    @NSManaged public var destination: String?
    @NSManaged public var sourceModule: String?
    @NSManaged public var dateEntered: Date?
    @NSManaged public var interactionType: String?
    @NSManaged public var data: String?

}

extension HistoryList : Identifiable {

}
