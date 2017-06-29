//
//  LTNewsFeedRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTNewsFeedRootView: OTMView {
    @IBOutlet var contentView                   : UIView!
    @IBOutlet var headerView                    : UIView!
    @IBOutlet var filterButton                  : UIButton!
    @IBOutlet var menuButton                    : UIButton!
    @IBOutlet var searchDateButton              : UIButton!
    @IBOutlet var datePickerContainer           : UIView!
    @IBOutlet var datePicker                    : UIDatePicker!
    @IBOutlet var cancelPickerButton            : UIButton!
    @IBOutlet var donePickerButton              : UIButton!
    @IBOutlet var tabBarContainerView           : UIView!
    @IBOutlet var byCommitteesButton            : LTSwitchButton!
    @IBOutlet var byInitiatorsButton            : LTSwitchButton!
    @IBOutlet var byBillsButton                 : LTSwitchButton!
    @IBOutlet var dismissChildControllersButton : UIButton!
    @IBOutlet var menuContainerView             : UIView!
    
    var menuShown       : Bool = false
    var datePickerShown : Bool = false
    
    var selectedButton: LTSwitchButton! {
        didSet {
            selectedButton.on = true
            
            if let oldValue = oldValue as LTSwitchButton! {
                oldValue.on = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        datePicker.date = Date().previousDay()
        datePicker.maximumDate = Date()
        
        selectedButton = byCommitteesButton
        if let label = searchDateButton.titleLabel {
            label.font = label.font.screenProportionalFont()
        }
    }
    
    func showMenu() {
        //horizontal
        let width = menuContainerView.frame.width < 250.0 ? menuContainerView.frame.width : 250.0;
        animateMenu(width, show: !menuShown)
    }
    
    func hideMenu(_ completionHandler: @escaping (_ finished: Bool) -> Void) {
        if menuShown {
            let width = menuContainerView.frame.width < 250.0 ? menuContainerView.frame.width : 250.0;
            let menuContainer = menuContainerView
            UIView.animate(withDuration: 0.4, animations: {
                var center = menuContainer?.center
                center?.x = -width / 2.0
                menuContainer?.center = center!
                self.dismissChildControllersButton.alpha = 0.0
                }, completion: {(finished: Bool) -> Void in
                    self.menuShown = !self.menuShown
                    completionHandler(finished)
            })
        }
    }
    
    func showDatePicker() {
        datePickerContainer.isHidden = false
        datePickerShown = true
    }
    
    func hideDatePicker() {
        datePickerContainer.isHidden = true
        datePickerShown = false
    }
    
    func fillSearchButton(_ date: Date) {
        DispatchQueue.main.async {
            self.searchDateButton.setTitle(date.longString(), for: UIControlState())
            self.datePicker.date = date
        }
    }
    
    fileprivate func animateMenu(_ width: CGFloat, show: Bool) {
        let menuContainer = menuContainerView
        
        if show {
            hideDatePicker()
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            var center = menuContainer?.center
            center?.x = show ?  width / 2.0 : -width / 2.0
            menuContainer?.center = center!
            self.dismissChildControllersButton.alpha = show ? 0.8 : 0.0
            }, completion: {(finished: Bool) -> Void in
                self.menuShown = !self.menuShown
        })
    }
    
    func setFilterImages() {
        byBillsButton.setFilterImage(.byLaws)
        byCommitteesButton.setFilterImage(.byCommittees)
        byInitiatorsButton.setFilterImage(.byInitiators)
    }

}
