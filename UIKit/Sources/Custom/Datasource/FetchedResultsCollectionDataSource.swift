/*
    Copyright (c) 2019 Andrey Ilskiy.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

import UIKit
import CoreData

import AAICoreData

@available(iOS 6.0, *)
public protocol FetchedResultsCollectionDataSourceCallback {
    associatedtype FetchResultType
    associatedtype SupplementarySource: FetchedResultsCollectionDataSourceSupplementaryElementSource where SupplementarySource.FetchResultType == FetchResultType
    associatedtype MoveHandler: FetchedResultsCollectionDataSourceMoveHandler where MoveHandler.FetchResultType == FetchResultType
    
    var supplementaryElementSource: SupplementarySource? { get }
    var moveHandler: MoveHandler? { get }
    
    
    func collectionView(_ collectionView: UICollectionView, dequeuCellAt indexPath: IndexPath, _ object: FetchResultType) -> UICollectionViewCell
    
    func collectionView(_ collectionView: UICollectionView, shouldReloadAt indexPath: IndexPath, _ object: FetchResultType) -> Bool
}

@available(iOS 6.0, *)
public protocol FetchedResultsCollectionDataSourceSupplementaryElementSource {
    associatedtype FetchResultType: NSFetchRequestResult
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath, for object: FetchResultType) -> UICollectionReusableView
}

@available(iOS 9.0, *)
public protocol FetchedResultsCollectionDataSourceMoveHandler {
    associatedtype FetchResultType: NSFetchRequestResult
    
    @available(iOS 9.0, *)
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, for object: FetchResultType) -> Bool
    
    @available(iOS 9.0, *)
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, for object: FetchResultType)
}

@available(iOS 6.0, *)
public class FetchedResultsCollectionDataSource<FetchResultType, CallbackType>: NSObject, NSFetchedResultsControllerDelegate, UICollectionViewDataSource where CallbackType: FetchedResultsCollectionDataSourceCallback, FetchResultType == CallbackType.FetchResultType  {
    public typealias CallbackProtocol = FetchedResultsCollectionDataSourceCallback
    
    public private(set) weak var collectionView: UICollectionView?
    public let fetchedResultsController: NSFetchedResultsController<FetchResultType>
    
    public let callback: CallbackType
    
    private var uncommitedUpdates: [() -> Void]?
    
    public init(withCollectionView collectionView: UICollectionView, fetchedResultsController frc: NSFetchedResultsController<FetchResultType>, callback: CallbackType)
    {
        self.collectionView = collectionView
        
        fetchedResultsController = frc
        self.callback = callback
    }
    
    //MARK: -
    
    public func performFetch() throws {
        if fetchedResultsController.delegate !== self {
            fetchedResultsController.delegate = self;
        }
        
        try self.fetchedResultsController.performFetch()
    }
    
    //MARK: -
    
    public override func responds(to aSelector: Selector!) -> Bool {
        let result: Bool
        
        switch aSelector {
        case #selector(collectionView(_:canMoveItemAt:)):
            result = callback.moveHandler != nil
            
        case #selector(collectionView(_:moveItemAt:to:)):
            result = callback.moveHandler != nil
            
        case #selector(collectionView(_:viewForSupplementaryElementOfKind:at:)):
            result = callback.supplementaryElementSource != nil
            
        default:
            result = super.responds(to: aSelector)
        }
        
        return result
    }
    
    //MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assert(collectionView === self.collectionView, "Called from unregistered collection view")
        
        var result: Int = 0
        if let sectionInfo = fetchedResultsController.sections?[section] {
            result = sectionInfo.numberOfObjects
        }
        
        return result
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assert(collectionView === self.collectionView, "Called from unregistered collection view")
        
        let object = fetchedResultsController.object(at: indexPath)
        
        let cell = callback.collectionView(collectionView, dequeuCellAt: indexPath, object)
        
        return cell
    }
    
    @available(iOS 6.0, *)
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        assert(collectionView === self.collectionView, "Called from unregistered collection view")
        
        var result: Int = 0;
        
        if let sections = fetchedResultsController.sections {
            result = sections.count
        }
        
        return result
    }
    
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        assert(collectionView === self.collectionView, "Called from unregistered collection view")
        
        guard let source = callback.supplementaryElementSource else { preconditionFailure("Missing source") }
        
        let object = fetchedResultsController.object(at: indexPath)
        let result = source.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath, for: object)
        return result
    }
    
    
    @available(iOS 9.0, *)
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        assert(collectionView === self.collectionView, "Called from unregistered collection view")
        
        guard let move = callback.moveHandler else { preconditionFailure("Missing handler") }
        
        let object = fetchedResultsController.object(at: indexPath)
        let result = move.collectionView(collectionView, canMoveItemAt: indexPath, for: object)
        return result
    }
    
    @available(iOS 9.0, *)
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        assert(collectionView === self.collectionView, "Called from unregistered collection view")
        
        guard let move = callback.moveHandler else { preconditionFailure("Missing handler") }
        let object = fetchedResultsController.object(at: sourceIndexPath)
        
        move.collectionView(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath, for: object)
    }
    
    
    /// Returns a list of index titles to display in the index view (e.g. ["A", "B", "C" ... "Z", "#"])
    @available(iOS 6.0, *)
    public func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return fetchedResultsController.sectionIndexTitles
    }
    
    
    /// Returns the index path that corresponds to the given title / index. (e.g. "B",1)
    /// Return an index path with a single index to indicate an entire section, instead of a specific item.
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        assert(collectionView === self.collectionView, "Called from unregistered collection view")
        
        let section = fetchedResultsController.section(forSectionIndexTitle: title, at: index)
        
        return IndexPath(index: section)
    }
    
    // Data manipulation - reorder / moving support
    
    //MARK: - NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        assert(uncommitedUpdates == nil, "stale collectionView updates")
        
        uncommitedUpdates = []
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		let uncommitedUpdates = self.uncommitedUpdates
		self.uncommitedUpdates = nil

		let collectionView = self.collectionView

		let completion = { (finished: Bool) -> Void in
			if !finished, let some = collectionView {
				debugPrint("Animation are interrupted for updates of collection view  - \(some)")
			}
		}
        
        let work = {
            let updates: () -> Void = { uncommitedUpdates?.forEach { $0() } }
            collectionView?.performBatchUpdates(updates, completion: completion)
        }
        
        if controller.managedObjectContext.concurrencyType == .mainQueueConcurrencyType {
            work()
        } else {
            OperationQueue.main.addOperation(work)
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        var result: String?
        
        if !sectionName.isEmpty {
            let index = sectionName.index(after: sectionName.startIndex)
            result = String(sectionName.prefix(upTo: index))
        }
        
        return result
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        assert(uncommitedUpdates != nil, "unbatched change")
        
        let update: () -> Void = { [unowned self] in self.process(controller, didChange: sectionInfo, atSectionIndex: sectionIndex, for: type) }
        uncommitedUpdates?.append(update)
    }
    
    private func process(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard let collectionView = self.collectionView else {
            assertionFailure()
            return
        }
        
        let sections = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            collectionView.insertSections(sections)
        case .delete:
            collectionView.deleteSections(sections)
        default:
            preconditionFailure("Invalid section change type - \(type)")
            break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        assert(uncommitedUpdates != nil, "unbatched change")
        
        let update: () -> Void = { [unowned self] in self.process(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath) }
        uncommitedUpdates?.append(update)
    }
    
    private func process(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let collectionView = self.collectionView else {
            assertionFailure()
            return
        }
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            
        case .update:
            
            if callback.collectionView(collectionView, shouldReloadAt: indexPath!, anObject as! FetchResultType) {
                collectionView.reloadItems(at: [indexPath!])
            }
            
        @unknown default:
            debugPrint("Uknown NSFetchedResultsChangeType - \(type)")
            break
        }
    }
}

//MARK: -

@available(iOS 6.0, *)
public struct FetchedResultsCollectionDataSourceCallbackValue<FetchResultType, SupplementarySourceType, MoveHandlerType>: FetchedResultsCollectionDataSourceCallback
    where SupplementarySourceType: FetchedResultsCollectionDataSourceSupplementaryElementSource, SupplementarySourceType.FetchResultType == FetchResultType,
    MoveHandlerType: FetchedResultsCollectionDataSourceMoveHandler, MoveHandlerType.FetchResultType == FetchResultType
{
    
    public typealias FetchResultType = FetchResultType
    public typealias SupplementarySource = SupplementarySourceType
    public typealias MoveHandler = MoveHandlerType
    
    //MARK: -
    
    public typealias CellDequeueBlock = (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ object: FetchResultType) -> UICollectionViewCell
    
    public typealias ShouldReloadBlock = (_ collectionView: UICollectionView, _ shouldReloadAt: IndexPath, _ object: FetchResultType) -> Bool
    
    //MARK: -
    
    public let dequeueCell: CellDequeueBlock
    public let shouldReloadHandler: ShouldReloadBlock?
    
    public let supplementaryElementSource: SupplementarySource?
    public let moveHandler: MoveHandler?
    
    
    public func collectionView(_ collectionView: UICollectionView, dequeuCellAt indexPath: IndexPath, _ object: FetchResultType) -> UICollectionViewCell {
        return dequeueCell(collectionView, indexPath, object)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldReloadAt indexPath: IndexPath, _ object: FetchResultType) -> Bool {
        return shouldReloadHandler?(collectionView, indexPath, object) ?? true
    }
}

@available(iOS 6.0, *)
public struct FetchedResultsCollectionDataSourceSupplementarySource<FetchResultType>: FetchedResultsCollectionDataSourceSupplementaryElementSource where FetchResultType: NSFetchRequestResult {
    public typealias DequeueBlock = (_ collectionView: UICollectionView, _ kind: String, _ indexPath: IndexPath, _ object: FetchResultType) -> UICollectionReusableView

    public let supplementaryDequeue: DequeueBlock

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath, for object: FetchResultType) -> UICollectionReusableView {
        return supplementaryDequeue(collectionView, kind, indexPath, object)
    }
}

@available(iOS 9.0, *)
public struct FetchedResultsCollectionDataSourceMoveHandlerValue<FetchResultType>: FetchedResultsCollectionDataSourceMoveHandler where FetchResultType: NSFetchRequestResult {
    public typealias FetchResultType = FetchResultType
    
    public typealias CanMoveBlock = (_ collectionView: UICollectionView,_ indexPath: IndexPath) -> Bool
    public typealias MoveBlock = (_ collectionView: UICollectionView, _ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) -> Void
    public typealias MoveTuple = (can: CanMoveBlock?, do: MoveBlock?)
    
    public let move: MoveTuple
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, for object: FetchResultType) -> Bool {
        return move.can?(collectionView, indexPath) ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, for object: FetchResultType) {
        
        move.do?(collectionView, sourceIndexPath, destinationIndexPath)
    }
}

//MARK: -

extension FetchedResultsCollectionDataSource where CallbackType == FetchedResultsCollectionDataSourceCallbackValue<FetchResultType, FetchedResultsCollectionDataSourceSupplementarySource<FetchResultType>, FetchedResultsCollectionDataSourceMoveHandlerValue<FetchResultType> > {

    convenience init(withCollectionView collectionView: UICollectionView, fetchedResultsController frc: NSFetchedResultsController<FetchResultType>, dequeue block: @escaping CallbackType.CellDequeueBlock, reload: CallbackType.ShouldReloadBlock? = nil) {
        let callback = CallbackType(dequeueCell: block, shouldReloadHandler: reload, supplementaryElementSource: nil, moveHandler: nil)

        self.init(withCollectionView: collectionView, fetchedResultsController: frc, callback: callback)
    }
}
