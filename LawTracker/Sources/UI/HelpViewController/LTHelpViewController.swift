//
//  LTHelpViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/15/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

private let kPortrait1 = "screenshot1_portrait"
private let kPortrait2 = "screenshot2_portrait"
private let kPortrait3 = "screenshot3_portrait"
private let kPortrait4 = "screenshot4_portrait"
private let kPortrait5 = "screenshot5_portrait"
private let kPortrait6 = "screenshot6_portrait"
private let kPortrait7 = "screenshot7_portrait"
private let kPortrait8 = "screenshot8_portrait"
private let kPortrait9 = "screenshot9_portrait"
private let kPortrait10 = "screenshot10_portrait"
private let kLandscape1 = "screenshot1_landscape"
private let kLandscape2 = "screenshot2_landscape"
private let kLandscape3 = "screenshot3_landscape"
private let kLandscape4 = "screenshot4_landscape"
private let kLandscape5 = "screenshot5_landscape"
private let kLandscape6 = "screenshot6_landscape"
private let kLandscape7 = "screenshot7_landscape"
private let kLandscape8 = "screenshot8_landscape"
private let kLandscape9 = "screenshot9_landscape"
private let kLandscape10 = "screenshot10_landscape"

class LTHelpViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    weak var delegate: LTNewsFeedViewController!
    
    var helpModel: [[String]]! {
        get {
            return [[kPortrait1, kLandscape1], [kPortrait2, kLandscape2], [kPortrait3, kLandscape3], [kPortrait4, kLandscape4], [kPortrait5, kLandscape5], [kPortrait6, kLandscape6], [kPortrait7, kLandscape7], [kPortrait8, kLandscape8], [kPortrait9, kLandscape9], [kPortrait10, kLandscape10]]
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({(UIViewControllerTransitionCoordinatorContext) -> Void in
            self.rootView.helpCollectionView.performBatchUpdates( { () -> Void in }, completion: nil)
            }, completion: {(UIViewControllerTransitionCoordinatorContext) -> Void in })
    }

    @IBAction func onCloseButton(sender: UIButton) {
        if let navigationController = navigationController as UINavigationController! {
            let newsFeedController = self.storyboard!.instantiateViewControllerWithIdentifier("LTNewsFeedViewController") as! LTNewsFeedViewController
            navigationController.viewControllers = [newsFeedController]
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return helpModel.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LTHelpViewCell", forIndexPath: indexPath) as! LTHelpViewCell
        let model = helpModel[indexPath.row]
        cell.fillWithModel(model)
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return collectionView.frame.size
    }

}
