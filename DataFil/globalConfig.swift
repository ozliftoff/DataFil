//
//  globalConfig.swift
//  Accelerometer Graph
//
//  Created by Alex Gubbay on 20/12/2016.
//  Copyright © 2016 Alex Gubbay. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/**
 Contains various functions an variables required at a global level in the main application. NOT in the filter algorithms.
 */
struct utilities{
    static var dateFormatter = DateFormatter()
    static var nc = NotificationCenter.default
    //static let newRawDataNotification = Notification.Name("newRawData")
    static var singleView = true
    static var pointCount = 300
    
    init() {
        utilities.dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss '+'ZZZZ"
        utilities.dateFormatter.timeStyle = .full
    }
 
 
    static func duplicateAccelData(data: [accelPoint])-> [accelPoint]{
        var outputArray = [accelPoint]()
        for d in data{
            outputArray.append(accelPoint(dataX: d.xAccel, dataY: d.yAccel, dataZ: d.zAccel, count: d.count))
        }
        return outputArray
    }
}


extension Double {
    /**
     Utility function for rounding doubles to a specified number of places.
     */
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

/**
 Wapper to ease use of persistent container for CoreData.
 */
var persistentContainer: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "Model")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error {
            
            fatalError("Unresolved error with the persistent container")
        }
    })
    return container
}()

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence

/**
 Utility function to ease raising a number to the power. Allows for `x^^y` to denote rasing x to y.
 */
func ^^ (first: Double, second: Double) -> Double {
    return pow(Double(first), Double(second))
}

struct alertBuilder{
    
    
}
