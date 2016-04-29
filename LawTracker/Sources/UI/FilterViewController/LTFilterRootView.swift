//
//  LTFilterRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

struct PlaceHolder {
    static let Initiators = "ПІБ депутата або назва ініціатора"
    static let Committees = "Назва комітету"
    static let Laws       = "Номер або назва законопроекту"
}

struct Header {
    static let Initiators = "Ініціатори"
    static let Committees = "Комітети"
    static let Laws       = "Законопроекти"
}

class LTFilterRootView: UIView {
    @IBOutlet var okButton        : UIButton!
    @IBOutlet var cancelButton    : UIButton!
    @IBOutlet var searchBar       : UISearchBar!
    @IBOutlet var tableView       : UITableView!
    @IBOutlet var selectAllButton : LTSelectAllButton!
    @IBOutlet var headerLabel     : UILabel!
    
    var searchBarActive : Bool {
        get {
            return searchBar.text != "" || searchBar.selectedScopeButtonIndex > 0
        }
    }
    
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
    
    //MARK: - Public
    func setSelectAllButtonSelected(selected: Bool) {
        selectAllButton.on = selected
    }
    
    func fillSearchBar(text: String?) {
        searchBar.text = text
    }
    
    func fillSearchBarPlaceholder(type: LTType) {
        switch type.rawValue {
        case 0:
            headerLabel.text = Header.Committees
            searchBar.placeholder = PlaceHolder.Committees
            
        case 1:
            headerLabel.text = Header.Initiators
            searchBar.placeholder = PlaceHolder.Initiators
            
        default:
            headerLabel.text = Header.Laws
            searchBar.placeholder = PlaceHolder.Laws
        }
    }
    
}
