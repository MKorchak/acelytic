//
//  UserPropertiesLocalDataManager.swift
//  Acelytic
//
//  Created by Mikhail Korchak on 16.08.2021.
//  Copyright © 2021 ACE. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

struct UserPropertiesLocalDataManager {
    
    static let shared = UserPropertiesLocalDataManager()
    
    private let coreDataStore = CoreDataStore.shared
    
    func fetchUserProperties() -> Maybe<[String: Any]> {
        Maybe.create { eventFactory in
            self.coreDataStore.persistentContainer.performBackgroundTask { context in
                do {
                    try context
                        .fetch(UserProperties.fetchRequest())
                        .first
                        .flatMap { (model: UserProperties) in model.properties?.data(using: .utf8) }
                        .flatMap { try JSONSerialization.jsonObject(with: $0) as? [String: Any] }
                        .map { eventFactory(.success($0)) }
                        ?? eventFactory(.completed)
                } catch {
                    eventFactory(.error(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func saveUserProperties(_ properties: [String: Any]) {
        removeUserProperties { context in
            do {
                let userProperties = UserProperties(context: context)
                userProperties.properties = try String(
                    data: JSONSerialization.data(withJSONObject: properties),
                    encoding: .utf8
                )
                try context.save()
                Logging.shared.log("user properties saved to db error")
            } catch {
                Logging.shared.log("user properties saved to db error \(error)")
            }
        }
    }
    
    func clearUserProperties() {
        removeUserProperties { _ in }
    }
    
    private func removeUserProperties(completion: @escaping (NSManagedObjectContext) -> Void) {
        coreDataStore.persistentContainer.performBackgroundTask { context in
            do {
                let request = NSBatchDeleteRequest(fetchRequest: UserProperties.fetchRequest())
                try context.execute(request)
                Logging.shared.log("user properties removed from db")
            } catch {
                Logging.shared.log("user properties removed from db error")
            }
            completion(context)
        }
    }
}
