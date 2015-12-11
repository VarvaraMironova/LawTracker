//
//  LTFilterRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTFilterRootView: UIView {
//    @IBOutlet var commeteeSearchView: UIView!
    @IBOutlet var filteredTableView: UITableView!
    
//    var searchViewDelegate: LTSearchViewDelegate!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    
    lazy var commiteesArray: [String] = {
        [unowned self] in
        return [Commitee1, Commitee2, Commitee3, Commitee4, Commitee5, Commitee1, Commitee2, Commitee3]
        }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let searchView = LTSearchView.searchView(commeteeSearchView)
//        searchViewDelegate = LTSearchViewDelegate(arrayModel: commiteesArray, searchView: searchView)
    }
    
}
