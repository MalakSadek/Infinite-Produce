//
//  todo.swift
//  InfiniteProduce
//
//  Created by Malak Sadek on 8/22/19.
//  Copyright © 2019 Malak Sadek. All rights reserved.
//

import Foundation

class todo {
    public var name:String = ""
    public var note:String = ""
    public var state:String = ""
    public var order:String = ""
    
    init(Name:String, Note:String, State:String, Order:String){
        name = Name;
        note = Note;
        state = State;
        order = Order;
    }
}
