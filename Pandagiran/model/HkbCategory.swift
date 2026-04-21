//
//  Hkb_category.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 12/29/17.
//  Copyright © 2017 MacBook Pro. All rights reserved.
//

import Foundation
import CoreData

class HkbCategory: NSManagedObject {
    
    @NSManaged var title : String
    @NSManaged var box_icon : String
    @NSManaged var box_color : String
    @NSManaged var balance_amount : Double
    @NSManaged var user_id : Int
    @NSManaged var is_expense : Int
    @NSManaged var budget_amount : Double
    @NSManaged var active : Int
    @NSManaged var flex1 : String
    @NSManaged var cattype : String
    @NSManaged var descr : String
    @NSManaged var glaccno : String
    @NSManaged var flex2 : String
    
}
