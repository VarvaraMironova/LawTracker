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

class LTMainContentRootView: UIView {
    @IBOutlet var headerView             : UIView!
    @IBOutlet var titleLabel             : UILabel!
    @IBOutlet var filterButton           : UIButton!
    @IBOutlet var byCommetteesButton     : LTSwitchButton!
    @IBOutlet var byInitializersButton   : LTSwitchButton!
    @IBOutlet var byLawsButton           : LTSwitchButton!
    @IBOutlet var shadowImageView        : UIImageView!
    @IBOutlet var contentView            : UIView!
    @IBOutlet var noSubscriptionsLabel   : UILabel!
    @IBOutlet var contentTableView       : UITableView!
    @IBOutlet var filterContainerView    : UIView!
    @IBOutlet var dismissFilterViewButton: UIButton!
    
    var filterViewShown : Bool = false
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedButton = byCommetteesButton
    }
    
    func showFilterView() {
        //horizontal
//        let filterContainer = filterContainerView
//        let screenWidth = CGRectGetWidth(self.frame)
//        
//        UIView.animateWithDuration(0.4, animations: {
//            var center = filterContainer.center
//            center.x = self.filterViewShown ? screenWidth + 207.0 : screenWidth - 207.0
//            filterContainer.center = center
//            self.dismissFilterViewButton.alpha = self.filterViewShown ? 0.0 : 0.8
//            }, completion: {(finished: Bool) -> Void in
//            self.filterViewShown = !self.filterViewShown
//        })
//        
        //vertical
        let filterContainer = filterContainerView
        let headerHeight = CGRectGetHeight(headerView.frame)
        
        UIView.animateWithDuration(0.4, animations: {
            var center = filterContainer.center
            center.y = self.filterViewShown ? headerHeight - 150.0 : headerHeight + CGRectGetHeight(self.filterContainerView.frame) / 2.0
            filterContainer.center = center
            self.dismissFilterViewButton.alpha = self.filterViewShown ? 0.0 : 0.8
            }, completion: {(finished: Bool) -> Void in
            self.filterViewShown = !self.filterViewShown
        })
    }
    
}
