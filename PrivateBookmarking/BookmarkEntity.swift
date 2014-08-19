//
//  Bookmark.swift
//  PrivateBookmarking
//
//  Created by alexbutenko on 7/21/14.
//  Copyright (c) 2014 alex. All rights reserved.
//

import Foundation
import CoreData

@objc(BookmarkEntity)
class BookmarkEntity : NSManagedObject {
    @NSManaged var url:String
    @NSManaged var date:NSDate
}