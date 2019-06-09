//
//  FetchedResultsSegmentedControlDataSource.swift
//  UIKit
//
//  Created by Andrey Ilskiy on 08/06/2019.
//  Copyright © 2019 Andrey Ilskiy. All rights reserved.
//

import CoreData
import UIKit

@available(iOS 3.0, *)
public class FetchedResultsSegmentedControlDataSource<FetchResultType: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    
    public typealias TitleDequeueStrategy = (_ segmentedControl: UISegmentedControl, _ index: Int, _ object: FetchResultType) -> String
    public typealias InsertionStrategy = (_ segmentedControl: UISegmentedControl, _ index: Int) -> FetchResultType
    public typealias ReloadStrategy = (_ segmentedControl: UISegmentedControl, _ index: Int,  _ object: FetchResultType) -> Bool
    
    public private(set) weak var segmentedControl: UISegmentedControl?
    public let fetchedResultsController: NSFetchedResultsController<FetchResultType>
    
    public let dequeueStrategy: TitleDequeueStrategy
    public let insertionStrategy: InsertionStrategy?
    public let shouldReloadStrategy: ReloadStrategy?
    
    private var batch: [() -> Void]?
    
    public init(with segmentedControl: UISegmentedControl, fetchRequest request: NSFetchRequest<FetchResultType>, managedObjectContext moc: NSManagedObjectContext, dequeueStrategy: @escaping TitleDequeueStrategy, insertionBlock: InsertionStrategy? = nil, shouldReloadBlock: ReloadStrategy? = nil) {
        self.segmentedControl = segmentedControl
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = frc
        self.dequeueStrategy = dequeueStrategy
        self.insertionStrategy = insertionBlock
        self.shouldReloadStrategy = shouldReloadBlock
    }
    
    public func performFetch() throws {
        if fetchedResultsController.delegate !== self {
            fetchedResultsController.delegate = self;
        }
        
        try self.fetchedResultsController.performFetch()
        
        let count = fetchedResultsController.fetchedObjects?.count ?? 0
        
        for i in 0..<count {
            let object = fetchedResultsController.object(at: [0, i])
            let title = self.dequeueStrategy(segmentedControl!, i, object)
            
            segmentedControl?.insertSegment(withTitle: title, at: i, animated: UIView.areAnimationsEnabled)
        }
    }

    
    //MARK: -
    
    open var fetchedObjects: [FetchResultType]? {
        return fetchedResultsController.fetchedObjects
    }
    
    open func object(at index: Int) -> FetchResultType {
        return fetchedResultsController.object(at: [0, index])
    }
    
    open func indexPath(forObject object: FetchResultType) -> Int? {
        return fetchedResultsController.indexPath(forObject: object)?.row
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        precondition(controller == fetchedResultsController)
        precondition(batch == nil)
        
        batch = []
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        precondition(controller == fetchedResultsController)
        
        guard let batch = batch else { preconditionFailure() }
        
        let isRevelant = !batch.isEmpty
        if isRevelant {
            let block = { batch.forEach { $0() } }
            process(batchUpdates: block, for: controller)
        }
        self.batch = nil
    }
    
//    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
//
//        var result: String?
//
//        if !sectionName.isEmpty {
//            let index = sectionName.index(after: sectionName.startIndex)
//            result = String(sectionName.prefix(upTo: index))
//        }
//
//        return result
//    }
    
//    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        guard let segmentedControl = self.segmentedControl else {
//            assertionFailure()
//            return
//        }
//
//        let sections = IndexSet(integer: sectionIndex)
//
//        var block: () -> Void
//
//        switch type {
//        case .insert:
//            block = { segmentedControl.insertSections(sections, with: .automatic) }
//        case .delete:
//            block = { segmentedControl.deleteSections(sections, with: .automatic) }
//        default:
//            preconditionFailure("Invalid section change type - \(type)")
//            break
//        }
//
//        batch?.append(block)
//    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let segmentedControl = self.segmentedControl else {
            assertionFailure()
            return
        }
        
        var block: (() -> Void)?
        
        let index = indexPath!.row
        
        switch type {
        case .insert:
            let object = anObject as! FetchResultType
            
            let index = indexPath!.row
            let title = self.dequeueStrategy(segmentedControl, indexPath!.row, object)
            block = { segmentedControl.insertSegment(withTitle: title, at: index, animated: UIView.areAnimationsEnabled) }
        case .delete:
            block = { segmentedControl.removeSegment(at: index, animated: UIView.areAnimationsEnabled) }
        case .move:
            let newIndex = newIndexPath!.row
            block = {
                let animated = UIView.areAnimationsEnabled
                let title = segmentedControl.titleForSegment(at: index)
                segmentedControl.removeSegment(at: index, animated: animated)
                segmentedControl.insertSegment(withTitle: title, at: newIndex, animated: animated)
                
            }
        case .update:
            let shouldReload: Bool
            if let block = shouldReloadStrategy  {
                let object = anObject as! FetchResultType
                shouldReload = block(segmentedControl, index, object)
            } else {
                shouldReload = true
            }
            
            if shouldReload {
                let object = anObject as! FetchResultType
                let title = self.dequeueStrategy(segmentedControl, indexPath!.row, object)
                block = {
                    let animated = UIView.areAnimationsEnabled
                    segmentedControl.removeSegment(at: index, animated: animated)
                    segmentedControl.insertSegment(withTitle: title, at: index, animated: animated)
                }
            }
            
        @unknown default:
            debugPrint("Uknown NSFetchedResultsChangeType - \(type)")
            break
        }
        
        if let some = block {
            batch?.append(some)
        }
    }
    
    //MARK: -
    
    private func process(batchUpdates: @escaping () -> Void, for controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let segmentedControl = self.segmentedControl
        let callout = batchUpdates
        
        let concurrencyType = controller.managedObjectContext.concurrencyType
        let isMainQueue: Bool
        if #available(iOS 9.0, *) {
            let isRelevant = concurrencyType == .mainQueueConcurrencyType
            isMainQueue = isRelevant && Thread.isMainThread
        } else {
            let isRelevant = concurrencyType == .mainQueueConcurrencyType || concurrencyType == .confinementConcurrencyType
            isMainQueue = isRelevant && Thread.isMainThread
        }
        
        if isMainQueue {
            callout()
        } else {
            OperationQueue.main.addOperation(callout)
        }
    }
}

