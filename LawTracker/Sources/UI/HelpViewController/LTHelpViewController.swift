//
//  LTHelpViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/15/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

private let kHelpTopText1    = "In main screen header you can see date of news. To choose another date, tap on date and choose new date in date picker."
private let kHelpBottomText1 = "To get more info about bill or its status, visit bill page on Verkhovna Rada web site by tapping at bill name."
private let kHelpTopText2    = "To see news grouped by main committee tap at 'Комітети' button, by initiator - at 'Ініціатори' button and by bill numbers - at 'Законопроекти'."
private let kHelpBottomText2 = "If You want to filter news by one of these three groups - choose appropriate tab and tap at filter button."
private let kHelpTopText3    = "Use search field to find filters. In 'Всі' You can see full list of filters, in 'Обрані' - only choosen filters, in 'Необрані' - not choosen ones."
private let kHelpBottomText3 = "To set filter, choose one or more filters in filter list and tap at 'Зберегти' button. To clear filters tap at 'Скинути' button."
private let kHelpTopText4    = "If filters are set, filter icon appears on corresponding tab. You can reload committees, initiators and bills by pulling down main screen."
private let kHelpBottomText4 = "To get more info about 'Zakonoproekt' app, to review this manual or to visit Chesno web site, tap at menu button."

class LTHelpViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    weak var delegate: LTMainContentViewController!
    
    var helpModel: [[String]]! {
        get {
            return [[kHelpTopText1, "screenshot1", kHelpBottomText1, "screenshot2"], [kHelpTopText2, "screenshot3", kHelpBottomText2, "screenshot4"], [kHelpTopText3, "screenshot5", kHelpBottomText3, "screenshot6"], [kHelpTopText4, "screenshot7", kHelpBottomText4, "screenshot8"]]
        }
    }
    
    var rootView: LTHelpRootView! {
        get {
            if isViewLoaded() && view.isKindOfClass(LTHelpRootView) {
                return view as! LTHelpRootView
            } else {
                return nil
            }
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({(UIViewControllerTransitionCoordinatorContext) -> Void in
            self.rootView.helpCollectionView.performBatchUpdates({ () -> Void in
                
                }, completion: nil)
            }, completion: {(UIViewControllerTransitionCoordinatorContext) -> Void in })
    }

    @IBAction func onCloseButton(sender: UIButton) {
        delegate.onDismissFilterViewButton(sender)
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return helpModel.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LTHelpViewCell", forIndexPath: indexPath) as! LTHelpViewCell
        let model = helpModel[indexPath.row]
        cell.fill(model[0], topImage: model[1], bottomText: model[2], bottomImage: model[3], index: indexPath.row)
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return collectionView.frame.size
    }

}
