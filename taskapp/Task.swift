//
//  Task.swift
//  taskapp
//
//  Created by Shousei  Murakami on 2020/06/01.
//  Copyright © 2020 shousei.murakami2. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    @objc dynamic var id = 0
    
    
    @objc dynamic var title = ""
    
    
    @objc dynamic var contents = ""
    
    
    @objc dynamic var date = Date()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}
