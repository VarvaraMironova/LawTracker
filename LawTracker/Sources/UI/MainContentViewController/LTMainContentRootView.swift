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

class LTMainContentRootView: LTArrayRootView {
    @IBOutlet var headerView             : UIView!
    @IBOutlet var titleLabel             : UILabel!
    @IBOutlet var filterButton           : UIButton!
    @IBOutlet var menuButton             : UIButton!
    @IBOutlet var byCommitteesButton     : LTSwitchButton!
    @IBOutlet var byInitialisersButton   : LTSwitchButton!
    @IBOutlet var byLawsButton           : LTSwitchButton!
    @IBOutlet var shadowImageView        : UIImageView!
    @IBOutlet var contentView            : UIView!
    @IBOutlet var noSubscriptionsLabel   : UILabel!
    @IBOutlet var contentTableView       : UITableView!
    @IBOutlet var menuContainerView      : UIView!
    @IBOutlet var dismissFilterViewButton: UIButton!
    @IBOutlet var helpViewContainer      : UIView!

    var menuShown : Bool = false
    
    lazy var titleStrings: [String] = {
        [unowned self] in
        return [titleOne, titleTwo, titleThree]
        }()
    
    var selectedButton: LTSwitchButton! {
        didSet {
            let tag = selectedButton.tag
            titleLabel.text = titleStrings[tag]
            
            selectedButton.on = true
            
            if let oldValue = oldValue as LTSwitchButton! {
                oldValue.on = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedButton = byCommitteesButton
    }
    
    func showHelpView() {
        UIView.animateWithDuration(0.4, animations: {
            self.dismissFilterViewButton.alpha = 0.8
            self.helpViewContainer.alpha = 1.0
            }, completion: nil)
    }
    
    func hideHelpView() {
        UIView.animateWithDuration(0.4, animations: {
            self.dismissFilterViewButton.alpha = 0.0
            self.helpViewContainer.alpha = 0.0
            }, completion: nil)
    }
    
    func showMenu() {
        //horizontal
        let width = CGRectGetWidth(menuContainerView.frame) < 250.0 ? CGRectGetWidth(menuContainerView.frame) : 250.0;
        animateMenu(width, show: !menuShown)
    }
    
    func hideMenu(completionHandler: (finished: Bool) -> Void) {
        if menuShown {
            let width = CGRectGetWidth(menuContainerView.frame) < 250.0 ? CGRectGetWidth(menuContainerView.frame) : 250.0;
            let menuContainer = menuContainerView
            UIView.animateWithDuration(0.4, animations: {
                var center = menuContainer.center
                center.x = -width / 2.0
                menuContainer.center = center
                self.dismissFilterViewButton.alpha = 0.0
                }, completion: {(finished: Bool) -> Void in
                    self.menuShown = !self.menuShown
                    completionHandler(finished: finished)
            })
        }
    }
    
    private func animateMenu(width: CGFloat, show: Bool) {
        let menuContainer = menuContainerView
        
        UIView.animateWithDuration(0.4, animations: {
            var center = menuContainer.center
            center.x = show ?  width / 2.0 : -width / 2.0
            menuContainer.center = center
            self.dismissFilterViewButton.alpha = show ? 0.8 : 0.0
            }, completion: {(finished: Bool) -> Void in
                self.menuShown = !self.menuShown
        })

    }
    
}
