//
//  LTNewsFeedRootView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTNewsFeedRootView: UIView {
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
    

}
