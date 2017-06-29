//
//  LTFilterRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTFilterRootView: UIView {
    @IBOutlet var okButton        : UIButton!
    @IBOutlet var cancelButton    : UIButton!
    @IBOutlet var searchBar       : UISearchBar!
    @IBOutlet var tableView       : UITableView!
    @IBOutlet var selectAllButton : LTSelectAllButton!
    
    var searchBarActive : Bool {
        get {
            return searchBar.text != "" || searchBar.selectedScopeButtonIndex > 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //setup searchBar
        searchBar.returnKeyType = .done
        searchBar.scopeButtonTitles = ["Всі", "Обрані", "Необрані"]
        
        if let label = okButton.titleLabel {
            label.font = label.font.screenProportionalFont()
        }
        
        if let label = cancelButton.titleLabel {
            label.font = label.font.screenProportionalFont()
        }
    }
    
    func fillSearchBar(_ text: String?) {
        searchBar.text = text
    }
    
    func fillSearchBarPlaceholder(_ string: String) {
        searchBar.placeholder = string
    }
    
}
