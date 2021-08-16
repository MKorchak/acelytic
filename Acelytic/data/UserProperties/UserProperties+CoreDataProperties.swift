//
//  UserProperties+CoreDataProperties.swift
//  
//
//  Created by Mikhail Korchak on 16.08.2021.
//
//

import Foundation
import CoreData


extension UserProperties {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProperties> {
        return NSFetchRequest<UserProperties>(entityName: "UserProperties")
    }

    @NSManaged public var properties: String?

}
