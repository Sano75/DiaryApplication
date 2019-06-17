//
//  DiaryTableViewController.swift
//  QuickDiary
//
//  Created by Sano Gharzani on 2019-04-15.
//  Copyright © 2019 Sano Gharzani. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Diarys")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        
        return container
    }

    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
}
