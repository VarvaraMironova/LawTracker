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
    @IBOutlet var helpContainerView             : UIView!
    
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
        
        datePicker.date = NSDate().previousDay()
        datePicker.maximumDate = NSDate()
        
        selectedButton = byCommitteesButton
        if let label = searchDateButton.titleLabel {
            label.font = label.font.screenProportionalFont()
        }
    }
    
    func showHelpView() {
        UIView.animateWithDuration(0.4, animations: {
            self.dismissChildControllersButton.alpha = 0.8
            self.helpContainerView.alpha = 1.0
            }, completion: nil)
    }
    
    func hideHelpView() {
        UIView.animateWithDuration(0.4, animations: {
            self.dismissChildControllersButton.alpha = 0.0
            self.helpContainerView.alpha = 0.0
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
                self.dismissChildControllersButton.alpha = 0.0
                }, completion: {(finished: Bool) -> Void in
                    self.menuShown = !self.menuShown
                    completionHandler(finished: finished)
            })
        }
    }
    
    func showDatePicker() {
        datePickerContainer.hidden = false
        datePickerShown = true
    }
    
    func hideDatePicker() {
        datePickerContainer.hidden = true
        datePickerShown = false
    }
    
    func fillSearchButton(date: NSDate) {
        dispatch_async(dispatch_get_main_queue()) {
            self.searchDateButton.setTitle(date.longString(), forState: .Normal)
            self.datePicker.date = date
        }
    }
    
    private func animateMenu(width: CGFloat, show: Bool) {
        let menuContainer = menuContainerView
        
        if show {
            hideDatePicker()
        }
        
        UIView.animateWithDuration(0.4, animations: {
            var center = menuContainer.center
            center.x = show ?  width / 2.0 : -width / 2.0
            menuContainer.center = center
            self.dismissChildControllersButton.alpha = show ? 0.8 : 0.0
            }, completion: {(finished: Bool) -> Void in
                self.menuShown = !self.menuShown
        })
    }

}
