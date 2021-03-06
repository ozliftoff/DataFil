//
//  dataPackager.swift
//  DataFil
//
//  Created by Alex Gubbay on 12/03/2017.
//  Copyright © 2017 Alex Gubbay. All rights reserved.
//
/*
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 The software implementation below is NOT designed to be used in any situation where the failure of the algorithms code on which they rely or mathematical assumptions made therin could lead to the harm of the user or others, property or the environment. It is NOT designed to prevent silent failures or fail safe.
 */
import Foundation

/**
 Responsible for managing the two way flow of accelPoint data objects with the remote communicator. Relies on `Serialiser` and `RemoteCommunicator`, as part of the stack.
 */
class RemoteDataInterface {

    static let sharedInstance = RemoteDataInterface()
    let srl = Serialiser()
    let observerKey = "watchAccelRaw"
    var buffer = [String]()
    var isListening = false
    var isSending = false
    var sampleBuffer = 30

    /**
     Calling will cause the class to attempt to send new raw data points to remote partner. Class begins listening for notifications under the "newRawData" name, serialises them and sends them to the `RemoteCommunicator` class
     */
    func publishOutgoingData(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.newOutgoingData), name: Notification.Name("newRawData"), object: nil)
    }
    
    /**
     Calling will cause the class to begin listening for new remote data points arriving under the "newRemoteData" notification form the `remoteCommunicator` class.
     */
    func subscribeIncomingData() {

        let incoming = {(data: Any)->Void in

            for d in data as! [String]{
                let accel = self.srl.deserialise(input: d)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("newRemoteData"), object: nil, userInfo:["data":accel])
                }
            }
        }
        RemoteCommunicator.sharedInstance.addObserver(key: observerKey, update: incoming)
        isListening = true
    }
    /**
     Used for cleanup after not longer needed.
     */
    func teardown(){
         NotificationCenter.default.removeObserver(self)
        isListening = false
        isSending = false
    }
    deinit {
        teardown()
         NotificationCenter.default.removeObserver(self)
    }

    @objc private func newOutgoingData(notification: NSNotification){
        let data = notification.userInfo as! Dictionary<String,accelPoint>
        if let accelData = data["data"]{
            buffer.append(srl.serialise(input: accelData))
        }
        if buffer.count > sampleBuffer {
            RemoteCommunicator.sharedInstance.sendMessage(key: "watchAccelRaw", value: buffer)
            buffer.removeAll()
        }
        isSending = true
    }
}
