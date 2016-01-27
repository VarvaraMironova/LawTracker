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
        
        searchBar.returnKeyType = .Done
        searchBar.scopeButtonTitles = ["Всі", "Обрані", "Необрані"]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var okButtonFont = okButton.titleLabel!.font
        okButtonFont = okButtonFont.screenProportionalFont()
        
        var cancelButtonFont = cancelButton.titleLabel!.font
        cancelButtonFont = cancelButtonFont.screenProportionalFont()
    }
    
    func fillSearchBar(text: String?) {
        searchBar.text = text
    }
    
    func fillSearchBarPlaceholder(string: String) {
        searchBar.placeholder = string
    }
    
}
