//
//  AceEvent+CoreDataProperties.swift
//  Acelytic
//
//  Created by AlexeyPanyok on 1/11/19.
//  Copyright © 2019 ACE. All rights reserved.
//

import Foundation
import CoreData

extension AceEvent {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AceEvent> {
        return NSFetchRequest<AceEvent>(entityName: "Event");
    }
    
    @NSManaged public var eventId: String?
    @NSManaged public var name: String?
    @NSManaged public var properties: String?
    @NSManaged public var time: Double

}
