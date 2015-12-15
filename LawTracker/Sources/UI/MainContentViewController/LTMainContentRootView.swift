//
//  LTMainContentRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/3/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

let titleOne = "За комітетами"
let titleTwo = "За ініціаторами"
let titleThree = "За законопроектами"

enum LTFilterType : Int {
    case byCommettees = 0, byInitializers = 1, byLaws = 2
    
    static let filterTypes = [byCommettees, byInitializers, byLaws]
}

class LTMainContentRootView: UIView {
    @IBOutlet var headerView             : UIView!
    @IBOutlet var titleLabel             : UILabel!
    @IBOutlet var filterButton           : UIButton!
    @IBOutlet var menuButton             : UIButton!
    @IBOutlet var byCommetteesButton     : LTSwitchButton!
    @IBOutlet var byInitializersButton   : LTSwitchButton!
    @IBOutlet var byLawsButton           : LTSwitchButton!
    @IBOutlet var shadowImageView        : UIImageView!
    @IBOutlet var contentView            : UIView!
    @IBOutlet var noSubscriptionsLabel   : UILabel!
    @IBOutlet var contentTableView       : UITableView!
    @IBOutlet var menuContainerView      : UIView!
    @IBOutlet var dismissFilterViewButton: UIButton!

    var menuShown : Bool = false
    
    lazy var titleStrings: [String] = {
        [unowned self] in
        return [titleOne, titleTwo, titleThree]
        }()
    
    var selectedButton: LTSwitchButton! {
        didSet {
            let tag = selectedButton.tag
            titleLabel.text = titleStrings[tag]
        }
    }
    
    var filterType: LTFilterType {
        get {
            switch selectedButton.tag {
            case 1:
                return .byInitializers
                
            case 2:
                return .byLaws
                
            default:
                return .byCommettees
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedButton = byCommetteesButton
    }
    
    func showMenu() {
        //horizontal
        var width = 0.0 as CGFloat!
        if menuShown {
            width = CGRectGetWidth(menuContainerView.frame) < 250.0 ? CGRectGetWidth(menuContainerView.frame) : 250.0;
        } else {
            width = CGRectGetWidth(menuContainerView.frame)
        }
        
        animateMenu(width, show: menuShown)
    }
    
    private func animateMenu(width: CGFloat, show: Bool) {
        let menuContainer = menuContainerView
        
        UIView.animateWithDuration(0.4, animations: {
            var center = menuContainer.center
            center.x = show ? -width / 2.0 : width / 2.0
            menuContainer.center = center
            self.dismissFilterViewButton.alpha = show ? 0.0 : 0.8
            }, completion: {(finished: Bool) -> Void in
                self.menuShown = !self.menuShown
        })

    }
    
}
