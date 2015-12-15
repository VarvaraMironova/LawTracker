//
//  LTFilterRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTFilterRootView: UIView {
    @IBOutlet var filteredTableView      : UITableView!
    @IBOutlet var okButton               : UIButton!
    @IBOutlet var cancelButton           : UIButton!
    @IBOutlet var searchBar              : UISearchBar!
    @IBOutlet var tableView              : UITableView!
    @IBOutlet var filteredTableViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        filteredTableViewHeight.constant = 0
    }
    
    func fillSearchBar(model: LTSectionModel) {
        searchBar.text = model.title
    }
    
    func fitTableViewHeight() {
        let cellsCount = filteredTableView.numberOfRowsInSection(1)
        
        filteredTableViewHeight.constant = CGFloat(cellsCount * 30)
    }
    
    func fillSearchBarPlaceholder(string: String) {
        searchBar.placeholder = string
    }
    
}
