//
//  FilterManager.swift
//  Accelerometer Graph
//
//  Created by Alex Gubbay on 09/12/2016.
//  Copyright © 2016 Alex Gubbay. All rights reserved.
//

import Foundation



class FilterManager{
    
    static let sharedInstance = FilterManager()
    var activeFilters = [Filter]()
    
    init(){

        NotificationCenter.default.addObserver(self, selector: #selector(FilterManager.newRawData), name: Notification.Name("newRawData"), object: nil)

    }

    @objc func newRawData(notification: NSNotification){
        let data = notification.userInfo as! Dictionary<String,accelPoint>
        let accelData = data["data"]
        //let currentData = accelData?.getAxis(axis: "x")
        if activeFilters.count >= 1 {
            activeFilters[0].addDataPoint(dataPoint: accelData!)
        }else{ //no filters, direct input straight to output
            receiveData(data: [accelData!], id: -1)
        }
        
    }
    
    func addNewFilter(filterName: String){
        
        switch filterName {
        case "High Pass":
            let highPass = HighPass()
            highPass.id = activeFilters.count
            
            let update = {(data: [accelPoint])->Void in
                
                self.receiveData(data: data, id: highPass.id)
            }
            
            highPass.addObserver(update: update)
            activeFilters.append(highPass)
            break
        case "Low Pass":
            let lowPass = advancedLowPass()
            lowPass.id = activeFilters.count
            
            let update = {(data: [accelPoint])->Void in
                
                self.receiveData(data: data, id: lowPass.id)
            }
            
            lowPass.addObserver(update: update)
            activeFilters.append(lowPass)
            break
        case "Bounded Average":
            let boundedAvg = boundedAverage()
            boundedAvg.id = activeFilters.count
            
            let update = {(data: [accelPoint])->Void in
                
                self.receiveData(data: data, id: boundedAvg.id)
            }
            
            boundedAvg.addObserver(update: update)
            activeFilters.append(boundedAvg)
            break
        case "Savitzky Golay":
            let savgolay = SavitzkyGolay()
            let update = {(data: [accelPoint])->Void in
                
                self.receiveData(data: data, id: savgolay.id)
            }
            savgolay.addObserver(update: update)
            activeFilters.append(savgolay)
            break
        case "Total Variation Denoising":
           let tvd = TotalVariationWrapper()
           let update = {(data: [accelPoint])->Void in
            
            self.receiveData(data: data, id: tvd.id)
           }
           tvd.addObserver(update: update)
           activeFilters.append(tvd)
            break
        default:
            print("No match in FilterManager")
        }
        
    }
    
    func removeFilter(filterName: String){
        for i in 0 ..< activeFilters.count{
            if activeFilters[i].filterName == filterName{
                activeFilters.remove(at: i)
                break;
            }
        }
    }
    
    private func getFilterByName(name: String) -> Filter?{
        for filter in activeFilters{
            if filter.filterName == name{
            return filter
            }
        }
        return nil
    }
    
    func setFilterParameter(filterName: String, parameterName: String, parameterValue: Double){
        getFilterByName(name: filterName)?.setParameter(parameterName: parameterName, parameterValue: parameterValue)
    }
    
    func receiveData(data: [accelPoint], id:Int){

        
        if(id >= activeFilters.count-1){ //Possible for data from dedacitvated filters to arrive asynchronusly

            NotificationCenter.default.post(name: Notification.Name("newProcessedData"), object: nil, userInfo:["data":data])
        }else{
            for dataPoint in data{
                activeFilters[id+1].addDataPoint(dataPoint: dataPoint)
            }
        }
        
    }
}
