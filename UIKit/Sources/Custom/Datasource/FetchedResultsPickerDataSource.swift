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

#if FetchedResultsPickerDataSource

import CoreData
import UIKit

import AAICoreData

@available(iOS 3.0, *)
open class FetchedResultsPickerDataSource<FetchResultType, View>: NSObject, NSFetchedResultsControllerDelegate, UIPickerViewDataSource where FetchResultType : NSFetchRequestResult, View : UIView {
    
    public typealias ViewDequeueStrategy = (_ pickerView: UIPickerView, _ row: Int, _ forComponent: Int, _ view: View?, _ object: FetchResultType) -> View
    
    public typealias TitleDequeueStrategy = (_ pickerView: UIPickerView, _ row: Int, _ forComponent: Int, _ object: FetchResultType) -> String
    
    public typealias InsertionStrategy = (_ tableView: UITableView, _ indexPath: IndexPath) -> FetchResultType
    
    public typealias ReloadStrategy = (_ pickerView: UIPickerView, _ row: Int, _ forComponent: Int,  _ object: FetchResultType) -> Bool
    
    private enum DequeueStrategyKind {
        case title(hanler: TitleDequeueStrategy)
        case view(handler: ViewDequeueStrategy)
    }
    
    public private(set) weak var pickerView: UIPickerView?
    public let fetchedResultsController: NSFetchedResultsController<FetchResultType>
    
    private let dequeueStrategy: DequeueStrategyKind
    private let insertionStrategy: InsertionStrategy?
    private let shouldReloadStrategy: ReloadStrategy?
    
    private var batch: [() -> Void]?
    
    public init(withPickerView pickerView: UIPickerView, fetchedResultsController frc: NSFetchedResultsController<FetchResultType>, viewDequeueStrategy: @escaping ViewDequeueStrategy, insertionStrategy: InsertionStrategy? = nil, shouldReloadStrategy: ReloadStrategy? = nil) {
        self.pickerView = pickerView
        
        fetchedResultsController = frc
        dequeueStrategy = .view(handler: viewDequeueStrategy)
        self.insertionStrategy = insertionStrategy
        self.shouldReloadStrategy = shouldReloadStrategy
    }
    
    public func performFetch() throws {
        if fetchedResultsController.delegate !== self {
            fetchedResultsController.delegate = self;
        }
        
        try self.fetchedResultsController.performFetch()
    }
    
    open override func responds(to aSelector: Selector!) -> Bool {
        var result: Bool
        
        switch aSelector {
        case #selector(UIPickerViewDelegate.pickerView(_:titleForRow:forComponent:)):
            switch dequeueStrategy {
            case .view(_):
                result = true
            case .title(_):
                preconditionFailure()
            }
        case #selector(UIPickerViewDelegate.pickerView(_:viewForRow:forComponent:reusing:)):
            switch dequeueStrategy {
            case .view(_):
                preconditionFailure()
            case .title(_):
                result = true
            }
        default:
            result = super.responds(to: aSelector)
        }
        
        return result
    }
    
    //MARK: -
    
//    // returns nil if cell is not visible
//    open func object(for view: UIView) -> FetchResultType? {
//
//        var result: FetchResultType?
//
//        // returns nil if cell is not visible
//        pickerView?.v
//        if let indexPath = pickerView?.indexPath(for: cell) {
//            result = object(at: indexPath)
//        }
//
//        return result
//    }
    
    //MARK: -
    
    open var fetchedObjects: [FetchResultType]? {
        return fetchedResultsController.fetchedObjects
    }
    
    open func object(at indexPath: IndexPath) -> FetchResultType {
        return fetchedResultsController.object(at: indexPath)
    }
    
    open func indexPath(forObject object: FetchResultType) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    //MARK: - UIPickerViewDataSource
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        assert(pickerView === self.pickerView, "Called from unregistered picker view")
        
        var result: Int = 0;
        
        if let sections = fetchedResultsController.sections {
            result = sections.count
        }
        
        return result
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        assert(pickerView === self.pickerView, "Called from unregistered picker view")
        
        var result: Int = 0
        if let sectionInfo = fetchedResultsController.sections?[component] {
            result = sectionInfo.numberOfObjects
        }
        
        return result
    }
    
    //MARK: - UIPickerViewDelegate
    
    // Optional
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
    }
    
    
    // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
    // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
    // If you return back a different object, the old one will be released. the view will be centered in the row rect
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var result: String?
        
        switch dequeueStrategy {
        case .view(_):
            preconditionFailure()
        case .title(let hanler):
            let object = self.object(at: [component, row])
            result = hanler(pickerView, row, component, object)
        }
        
        return result
    }
    
    @available(iOS 6.0, *) // attributed title is favored if both methods are implemented
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let result: UIView
        
        switch dequeueStrategy {
        case .view(let handler):
            guard let some = view as? View else { preconditionFailure() }
            
            let object = self.object(at: [component, row])
            
            result = handler(pickerView, row, component, some , object)
        case .title(_):
            preconditionFailure()
        }
        
        return result
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
//    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        assert(tableView === self.pickerView, "Called from unregistered table view")
//
//        var result: String? = nil
//
//        if let sectionInfo = fetchedResultsController.sections?[section] {
//            result = sectionInfo.name
//        }
//
//        return result
//    }
    
    // Editing
    
    // Moving/reordering
    
    // Index
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        assert(tableView === self.pickerView, "Called from unregistered table view")
        
        return fetchedResultsController.sectionIndexTitles
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        assert(tableView === self.pickerView, "Called from unregistered table view")
        
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    // Data manipulation - insert and delete support
    
//    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        assert(tableView === self.pickerView, "Called from unregistered table view")
//
//        guard let object = fetchedResultsController.object(at: indexPath) as? NSManagedObject else {
//            preconditionFailure()
//        }
//
//        switch editingStyle {
//        case .insert:
//            if let block = insertionStrategy, let object = block(tableView, indexPath) as? NSManagedObject , !object.isInserted {
//                fetchedResultsController.managedObjectContext.insert(object)
//            }
//
//        case .delete:
//            fetchedResultsController.managedObjectContext.delete(object)
//
//        case .none:
//            debugPrint("commit to tableView \(tableView) with editing style - \(editingStyle)")
//            break
//
//        @unknown default:
//            debugPrint("Uknown NSFetchedResultsChangeType - \(editingStyle)")
//            break
//        }
//    }
    
    // Data manipulation - reorder / moving support
    
    
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
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
        var result: String?
        
        if !sectionName.isEmpty {
            let index = sectionName.index(after: sectionName.startIndex)
            result = String(sectionName.prefix(upTo: index))
        }
        
        return result
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard let pickerView = self.pickerView else {
            assertionFailure()
            return
        }
        
//        var block: () -> Void
        
        switch type {
        case .insert:
//            block = { pickerView.insertSections(sections, with: .automatic) }
            pickerView.reloadComponent(sectionIndex)
        case .delete:
//            block = { pickerView.deleteSections(sections, with: .automatic) }
            pickerView.reloadAllComponents()
        default:
            preconditionFailure("Invalid section change type - \(type)")
            break
        }
        
//        batch?.append(block)
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let pickerView = self.pickerView else {
            assertionFailure()
            return
        }
        
//        var block: (() -> Void)?
        
        switch type {
        case .insert:
//            block = { tableView.insertRows(at: [newIndexPath!], with: .automatic) }
            break
        case .delete:
//            block = { tableView.deleteRows(at: [indexPath!], with: .automatic) }
            break
        case .move:
//            block = { tableView.moveRow(at: indexPath!, to: newIndexPath!) }
            break
        case .update:
            let shouldReload: Bool
            if let strategy = shouldReloadStrategy  {
                let object = anObject as! FetchResultType
//                shouldReload = block(tableView, indexPath!, object)
                shouldReload = strategy(pickerView, indexPath!.row, indexPath!.section, object)
            } else {
                shouldReload = true
            }
            
            if shouldReload {
//                block = { pickerView.reloadComponent(indexPath!.section) }
                pickerView.reloadComponent(indexPath!.section)
            }
            
        @unknown default:
            debugPrint("Uknown NSFetchedResultsChangeType - \(type)")
            break
        }
        
//        if let some = block {
//            batch?.append(some)
//        }
    }
    
    //MARK: -
    
    private func process(batchUpdates: @escaping () -> Void, for controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let tableView = self.pickerView
        let callout = {
            if #available(iOS 11.0, *) {
                let handler: ((Bool) -> Void)? = nil
                tableView?.performBatchUpdates(batchUpdates, completion: handler)
            } else {
                tableView?.beginUpdates()
                
                batchUpdates()
                
                tableView?.endUpdates()
            }
        }
        
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

#endif /* FetchedResultsPickerDataSource */
