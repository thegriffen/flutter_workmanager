//
//  BackgroundTaskOperation.swift
//  workmanager
//
//  Created by Sebastian Roth on 10/06/2021.
//

import Foundation

class BackgroundTaskOperation: Operation {

    private let identifier: String
    private let flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?
    private let inputData: String
    private let backgroundMode: BackgroundMode
    
    private var backgroundWorker: BackgroundWorker?

    init(_ identifier: String,
         inputData: String,
         flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?,
         backgroundMode: BackgroundMode) {
        self.identifier = identifier
        self.inputData = inputData
        self.flutterPluginRegistrantCallback = flutterPluginRegistrantCallback
        self.backgroundMode = backgroundMode
    }

    override func main() {
        let semaphore = DispatchSemaphore(value: 0)
        self.backgroundWorker = BackgroundWorker(mode: self.backgroundMode,
                                      inputData: self.inputData,
                                      flutterPluginRegistrantCallback: self.flutterPluginRegistrantCallback)
        DispatchQueue.main.async {
            self.backgroundWorker!.performBackgroundRequest { _ in
                semaphore.signal()
            }
        }

        semaphore.wait()
    }
    
    override func cancel() {
        super.cancel()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.main.async {
            self.backgroundWorker?.cancel {
                semaphore.signal()
            }
        }
        
        semaphore.wait()
    }
}
