//
//  Element+JSON.swift
//  PeriodicTableOfTheElements
//
//  Created by Jason Gresh on 12/20/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation
import CoreData

extension Element {
    func populate(from dictionary: [String:Any]) {
        guard let number = dictionary["number"] as? Int,
            let name = dictionary["name"] as? String,
            let weight = dictionary["weight"] as? Double,
            let symbol = dictionary["symbol"] as? String,
            let group = dictionary["group"] as? Int
            else {
                print("Skipping element \(dictionary)")
                return
        }
        
        self.number = Int16(number)
        self.weight = weight
        self.name = name
        self.symbol = symbol
        self.group = Int16(group)
    }
    
    static func putElements(from arr:[[String:Any]], into context:NSManagedObjectContext) {
        // create the private context on the thread that needs it
        
        context.performAndWait {
            for elementDict in arr {
                // now it goes in the database
                let element = NSEntityDescription.insertNewObject(forEntityName: "Element", into: context) as! Element
                element.populate(from: elementDict)
            }
            
            do {
                try context.save()
                
                context.parent?.performAndWait {
                    do {
                        try context.parent?.save()
                    }
                    catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
}
