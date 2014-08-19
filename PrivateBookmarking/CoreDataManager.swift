//
//  CoreDataManager.swift
//  PrivateBookmarking
//
//  Created by alexbutenko on 7/21/14.
//  Copyright (c) 2014 alex. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    struct SingleInstance {
        static let sharedCoreDataManager: CoreDataManager = {
            return CoreDataManager()
        }()
    }
    
    class var sharedInstance: CoreDataManager {
        return SingleInstance.sharedCoreDataManager
    }
    
    func saveContext () {
        var error: NSError? = nil
        let managedObjectContext = self.managedObjectContext
        if managedObjectContext != nil {
            if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    // #pragma mark - Core Data stack

    // Returns the managed object context for the application.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    var managedObjectContext: NSManagedObjectContext {
    if nil == _managedObjectContext {
        let coordinator = self.persistentStoreCoordinator
        if coordinator != nil {
            _managedObjectContext = NSManagedObjectContext()
            _managedObjectContext!.persistentStoreCoordinator = coordinator
        }
        }
        return _managedObjectContext!
    }
    var _managedObjectContext: NSManagedObjectContext? = nil

    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
        if nil == _managedObjectModel {
            let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
        }
        return _managedObjectModel!
    }
    var _managedObjectModel: NSManagedObjectModel? = nil

    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
    if nil == _persistentStoreCoordinator {
        let storeURL = self.sharedContainerDirectory.URLByAppendingPathComponent("PrivateBookmarking.sqlite")
        var error: NSError? = nil
        _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
            /*
            Replace this implementation with code to handle the error appropriately.
            
            abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            Typical reasons for an error here include:
            * The persistent store is not accessible;
            * The schema for the persistent store is incompatible with current managed object model.
            Check the error message to determine what the actual problem was.
            
            
            If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
            
            If you encounter schema incompatibility errors during development, you can reduce their frequency by:
            * Simply deleting the existing store:
            NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
            
            * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
            [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            
            Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
            
            */
            //println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        }
        return _persistentStoreCoordinator!
    }
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil

    
    func executeFetchRequest(fetchRequest:NSFetchRequest) -> (results:[AnyObject]!, error:NSError?) {
        var results:[AnyObject]! = nil
        var error:AutoreleasingUnsafeMutablePointer<NSError?> = nil
        
        results = managedObjectContext.executeFetchRequest(fetchRequest, error: error) as [AnyObject]!
        
        return (results, error ? error.memory:nil)
    }
    
    // #pragma mark - Application's Documents directory

    // Returns the URL to the shared container directory.
    var sharedContainerDirectory: NSURL {
        return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.sush.ios8.test")
    }
    
    //Bookmarks
    func addBookmarkWithURL(URL:NSURL) -> BookmarkEntity {
        let newEntity: BookmarkEntity = NSEntityDescription.insertNewObjectForEntityForName("BookmarkEntity", inManagedObjectContext:managedObjectContext) as BookmarkEntity
        newEntity.url = URL.absoluteString
        newEntity.date = NSDate.date()
        println("persisted bookmark \(newEntity) url \(newEntity.url)")
        return newEntity
    }
    
    func removeBookMark(bookmark:BookmarkEntity) {
        managedObjectContext.deleteObject(bookmark)
        saveContext()
    }
    
    func allBookmarks() -> [BookmarkEntity] {
        var fetchRequest = NSFetchRequest(entityName: "BookmarkEntity")
        
        var (results, error) = executeFetchRequest(fetchRequest)
        
        if (nil == error) {
            return results as [BookmarkEntity]
        }
        
        return [BookmarkEntity]()
    }
}
