//
//  LTNewsTableViewDadaSource.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTNewsTableViewDadaSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var arrayModel: [LTNewsModel]!
    
    init(arrayModel: [LTNewsModel]) {
        super.init()
        self.arrayModel = arrayModel
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayModel.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTNewsTableViewCell", forIndexPath: indexPath) as! LTNewsTableViewCell
        let model = arrayModel[indexPath.row]
        cell.fillWithModel(model)
        
        return cell
    }
    
}
