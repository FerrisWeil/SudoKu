//
//  GameData+CoreDataProperties.swift
//  Sudoku Solver
//
//  Created by Taylor Weil on 1/21/20.
//  Copyright © 2020 Taylor Weil. All rights reserved.
//
//

import Foundation
import CoreData


extension GameData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameData> {
        return NSFetchRequest<GameData>(entityName: "GameData")
    }

    @NSManaged public var cellString: String?
    @NSManaged public var id: UUID?

}
