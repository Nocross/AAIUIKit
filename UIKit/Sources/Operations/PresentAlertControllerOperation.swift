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

import AAIFoundation
import UIKit

public class PresentAlertControllerOperation: Operation, AlertControllerCallbacks {

    public let presentingController: UIViewController
    
    public let isDetached: Bool
    
    //MARK: -
    
    private static let queue = makeQueue()
    
    //MARK: -
    
    private let alertController: AlertController
    
    private let lock = OSUnfairLock()
    private var isPresented: Bool {
        get { return lock.withCritical { return _isPresented }  }
        set { lock.withCritical { return _isPresented = newValue } }
    }
    private var _isPresented: Bool = false
    
    //MARK: -
    
    public init(configure: ((UIAlertController) -> Void)? = nil, presentingController: UIViewController, detached: Bool = false) {
        alertController = AlertController()
        
        configure?(alertController)
        
        self.presentingController = presentingController
        
        self.isDetached = detached
        
        super.init()
        execution.prepare(for: self)
    }
    
    private init(controller: AlertController, presentingController: UIViewController) {
        alertController = controller
        self.presentingController = presentingController
        self.isDetached = true
        
        super.init()
        execution.prepare(for: self)
    }
    
    //MARK: - Overrides & Execution
    
    private let execution: Execution = AsynchronousExecution()
    
    public override var isExecuting: Bool {
        return execution.isExecuting
    }
    
    public override var isFinished: Bool {
        return execution.isFinished
    }
    
    public override var isCancelled: Bool {
        return execution.isCancelled
    }
    
    public override var isAsynchronous: Bool {
        return execution.isAsynchronous
    }
    
    public override func start() {
        if execution.start() {
            execute()
        } else if isCancelled {
            execution.cancel()
        }
    }
    
    public override func cancel() {
        execution.cancel(finalized: false)
        
        if isPresented {
            let alert = alertController
            OperationQueue.main.addOperation { alert.dismiss() }
        }
    }
    
    //MARK: -
    
    private func execute() {
        if isDetached {
            let op = PresentAlertControllerOperation(controller: alertController, presentingController: presentingController)
            op.completionBlock = { [unowned self] in self.execution.finalize() }
            
            type(of: self).queue.addOperation(op)
        } else {
            let presentingController = self.presentingController
            
            let alert = self.alertController
            alert.callbacks = self
            
            OperationQueue.main.addOperation {
                presentingController.present(viewController: alert)
            }
        }
    }
    
    //MARK: - AlertControllerCallbacks
    
    func controller(_ controller: UIAlertController, didDidPresent animated: Bool) {
        isPresented = true
        if isCancelled {
            OperationQueue.main.addOperation { controller.dismiss() }
        }
    }
    
    func controller(_ controller: UIAlertController, didDismiss animated: Bool) {
        execution.finalize()
        isPresented = false
    }
    
    //MARK: -
    
    private static func makeQueue() -> OperationQueue {
        
        let label = "\(Bundle.main.bundleIdentifier!).alert"
        
        let result = OperationQueue()
        result.name = label
        
        result.maxConcurrentOperationCount = 1
        
        return result
    }
}

//MARK: -



//MARK: -

fileprivate protocol AlertControllerCallbacks: class {
    func controller(_ controller: UIAlertController, didDidPresent animated: Bool)
    func controller(_ controller: UIAlertController, didDismiss animated: Bool)
}

fileprivate class AlertController: UIAlertController {
    public weak var callbacks: AlertControllerCallbacks?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isBeingPresented, let callbacks = callbacks {
            callbacks.controller(self, didDidPresent: animated)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isBeingDismissed, let callbacks = callbacks {
            callbacks.controller(self, didDismiss: animated)
        }
    }
}
