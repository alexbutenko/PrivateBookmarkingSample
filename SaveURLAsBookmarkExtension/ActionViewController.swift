//
//  ActionViewController.swift
//  SaveURLAsBookmarkExtension
//
//  Created by alexbutenko on 7/21/14.
//  Copyright (c) 2014 alex. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var URLFound = false
        
        for item: AnyObject in self.extensionContext.inputItems! {
            let inputItem = item as NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as NSItemProvider
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as NSString) {
                    // This is an URL. We'll persist it in core data
                    itemProvider.loadItemForTypeIdentifier(kUTTypeURL as NSString, options: nil, completionHandler: { (URL, error) in
                        
                        println("loaded URL \(URL)")
                        
                        if let loadedURL = URL as? NSURL {
                            CoreDataManager.sharedInstance.addBookmarkWithURL(loadedURL)
                            CoreDataManager.sharedInstance.saveContext()
                        }
                    })
                    
                    URLFound = true
                    break
                }
            }
            
            if (URLFound) { // We only handle one image, so stop looking for more.
                break
            }
        }
    }
    
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        
        var masterNavController = childViewControllers[0] as UINavigationController
        var masterViewController:MasterViewController = masterNavController.viewControllers[0] as MasterViewController
        masterViewController.onDidSelectRow = {url in
            //trying to open this URL in Safari, but it doesn't work for me now
            var extensionItem = NSExtensionItem()
            extensionItem.attachments = [NSItemProvider(item: url, typeIdentifier: kUTTypeURL as NSString)]
            
            self.extensionContext.completeRequestReturningItems([extensionItem], completionHandler: nil)
            
//            self.extensionContext.openURL(url, completionHandler: nil)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext.completeRequestReturningItems(self.extensionContext.inputItems, completionHandler: nil)
    }

}
