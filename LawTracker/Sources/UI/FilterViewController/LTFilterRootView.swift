//
//  LTFilterRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTFilterRootView: UIView {
    @IBOutlet var okButton               : UIButton!
    @IBOutlet var cancelButton           : UIButton!
    @IBOutlet var searchBar              : UISearchBar!
    @IBOutlet var tableView              : UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //setup searchBar
        searchBar.returnKeyType = .Done
        searchBar.scopeButtonTitles = ["Всі", "Обрані", "Необрані"]
        
        if let label = okButton.titleLabel {
            label.font = label.font.screenProportionalFont()
        }
        
        if let label = cancelButton.titleLabel {
            label.font = label.font.screenProportionalFont()
        }
    }
    
    func fillSearchBar(text: String?) {
        searchBar.text = text
    }
    
    func fillSearchBarPlaceholder(string: String) {
        searchBar.placeholder = string
    }
    
}
