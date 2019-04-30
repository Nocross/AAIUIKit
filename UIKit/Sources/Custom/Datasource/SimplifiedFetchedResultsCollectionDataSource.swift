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

public class SimplifiedFetchedResultsCollectionDataSource<FetchResultType>: FetchedResultsCollectionDataSource<FetchResultType, FetchedResultsCollectionDataSourceCallbackValue<FetchResultType, FetchedResultsCollectionDataSourceSupplementarySource<FetchResultType>, FetchedResultsCollectionDataSourceMoveHandlerValue<FetchResultType> > > where FetchResultType: NSFetchRequestResult {
    
    public typealias Callback = FetchedResultsCollectionDataSourceCallbackValue<FetchResultType, FetchedResultsCollectionDataSourceSupplementarySource<FetchResultType>, FetchedResultsCollectionDataSourceMoveHandlerValue<FetchResultType> >
    
    public typealias CellDequeueBlock = Callback.CellDequeueBlock
    public typealias SupplementaryElementDequeueBlock = Callback.SupplementarySource.DequeueBlock
    public typealias MoveTuple = Callback.MoveHandler.MoveTuple
    
    public init(withCollectionView collectionView: UICollectionView, fetchedResultsController frc: NSFetchedResultsController<FetchResultType>, dequeue block: @escaping Callback.CellDequeueBlock, supplementaryDequeue: SupplementaryElementDequeueBlock? = nil, move tuple: MoveTuple? = nil) {
        let sup = supplementaryDequeue == nil ? nil : FetchedResultsCollectionDataSourceSupplementarySource<FetchResultType>(supplementaryDequeue: supplementaryDequeue!)
        let move = tuple == nil ? nil : FetchedResultsCollectionDataSourceMoveHandlerValue<FetchResultType>(move: tuple!)
        
        let callback = Callback(dequeueCell: block, supplementaryElementSource: sup, moveHandler: move)
        
        super.init(withCollectionView: collectionView, fetchedResultsController: frc, callback: callback)
    }
}

