//
//  PieChartViewController.swift
//  RealTimeSoundClassifier
//
//  Created by Waqar Qureshi on 14/12/2019.
//  Copyright © 2019 Anuj Dutt. All rights reserved.
//

import UIKit
import Charts

class PieChartViewController: UIViewController {
    
    var pieChartData : [String:Int] = [:]
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var status: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.status.text =  Utility.getAnlysis(pieChartData)
        self.setupPieChart(pieChartData)
    }
    
    func setupPieChart(_ data: [String: Int]) {
        
        pieChart.chartDescription?.enabled = false
        pieChart.drawHoleEnabled = true
        pieChart.rotationAngle = 0
        pieChart.rotationEnabled = true
        pieChart.legend.enabled = false
        
        var entries: [PieChartDataEntry] = Array()
        for (key, value) in data{
            entries.append(PieChartDataEntry(value: Double(value), label: key))
        }
        let dataSet = PieChartDataSet(entries: entries, label: "Fast")
        
        let c1 = NSUIColor(red: 218, green: 59, blue: 33)
        let c2 = NSUIColor(red: 253, green: 153, blue: 49)
        
        dataSet.colors = [c1, c2]
        dataSet.drawValuesEnabled = false
        
        pieChart.data = PieChartData(dataSet: dataSet)
    }
}
