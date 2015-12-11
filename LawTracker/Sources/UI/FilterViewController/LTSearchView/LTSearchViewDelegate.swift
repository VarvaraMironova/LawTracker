//
//  LTSearchViewDelegate.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/8/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTSearchViewDelegate: NSObject, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    var arrayModel: [String]!
    var searchView: LTSearchView!
    
    init(arrayModel: [String], searchView: LTSearchView) {
        super.init()
        
        self.arrayModel = arrayModel
        
        searchView.searchTextField.delegate = self
        searchView.tableView.dataSource = self
        searchView.tableView.delegate = self
        self.searchView = searchView
    }
    
    //MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayModel.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LTSearchTableViewCell", forIndexPath: indexPath) as! LTSearchTableViewCell
        let title = arrayModel[indexPath.row]
        cell.fill(title)
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchView.fillTextFild(arrayModel[indexPath.row])
    }
    
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        //add picker
        searchView.show()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //hide picker
        searchView.hide()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}
