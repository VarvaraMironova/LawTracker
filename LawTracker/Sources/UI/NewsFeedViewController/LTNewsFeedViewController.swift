//
//  LTNewsFeedViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit
let kLTMaxLoadingCount = 30

class LTNewsFeedViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var navigationGesture: LTPanGestureRacognizer!
    
    var currentController : LTMainContentViewController!
    var newsFeedModel     : LTChangesModel!
    var animator          : LTSliderAnimator?
    var shownDate         : NSDate! {
        didSet {
            rootView.fillSearchButton(selectedArray.date)
        }
    }
    
    var loadedAtFirst : Bool = true
    var loadingCount  : Int = 0
    
    var filterType: LTType {
        get {
            switch rootView.selectedButton.tag {
            case 1:
                return .byInitiators
                
            case 2:
                return .byLaws
                
            default:
                return .byCommittees
            }
        }
    }
    
    var changesModel      : LTArrayModel!
    
    var selectedArray     : LTChangesModel! {
        didSet {
            currentController.arrayModel = selectedArray
            shownDate = selectedArray.date
        }
    }
    
    var byLawsArray       : LTChangesModel! {
        didSet {
            rootView.byBillsButton.filtersSet = byLawsArray.filtersIsApplied
        }
    }
    
    var byCommitteesArray : LTChangesModel! {
        didSet {
            rootView.byCommitteesButton.filtersSet = byCommitteesArray.filtersIsApplied
        }
    }
    
    var byInitiatorsArray : LTChangesModel! {
        didSet {
            rootView.byInitiatorsButton.filtersSet = byInitiatorsArray.filtersIsApplied
        }
    }
    
    var menuViewController: LTMenuViewController {
        get {
            let menuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LTMenuViewController") as! LTMenuViewController
            menuViewController.delegate = self
            
            return menuViewController
        }
    }
    
    var helpViewController: LTHelpViewController {
        get {
            let helpViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LTHelpViewController") as! LTHelpViewController
            helpViewController.delegate = self
            
            return helpViewController
        }
    }
    
    var rootView     : LTNewsFeedRootView! {
        get {
            if isViewLoaded() && view.isKindOfClass(LTNewsFeedRootView) {
                return view as! LTNewsFeedRootView
            } else {
                return nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
        
        let settingsModel = VTSettingModel()
        if true != settingsModel.firstLaunch {
            //download data from server
            loadData()
        } else {
            downloadChanges(NSDate().previousDay())
        }
        
        //add menuViewController as a childViewController to menuContainerView
        addChildViewController(menuViewController, view: rootView.menuContainerView)
        
        //add helpViewController as a childViewController to menuContainerView
        addChildViewController(helpViewController, view: rootView.helpContainerView)
        
        //check, if it is a first launch -> show helpViewController, create dictionary filters in SettingsModel
        if settingsModel.firstLaunch != true {
            rootView.showHelpView()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({(UIViewControllerTransitionCoordinatorContext) -> Void in
            if self.rootView.menuShown {
                self.rootView.showMenu()
            }}, completion: {(UIViewControllerTransitionCoordinatorContext) -> Void in })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    //MARK: - Interface Handling
    @IBAction func onGesture(sender: LTPanGestureRacognizer) {
        let direction = sender.direction
        if direction != .Right {
            handlePageSwitchingGesture(sender)
        }
    }
    
    @IBAction func onDismissFilterViewButton(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            let view = self.rootView
            view.hideMenu() {finished in}
            view.hideHelpView()
        }
    }
    
    @IBAction func onMenuButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.rootView.showMenu()
        }
    }
    
    @IBAction func onFilterButton(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            let filterController = self.storyboard!.instantiateViewControllerWithIdentifier("LTFilterViewController") as! LTFilterViewController
            filterController.delegate = self
            
            var entityName = String()
            switch self.filterType {
            case .byCommittees:
                entityName = "LTCommitteeModel"
                break
                
            case .byInitiators:
                entityName = "LTInitiatorModel"
                break
                
            case .byLaws:
                entityName = "LTLawModel"
                break
            }
            
            let filters = LTArrayModel(entityName: entityName, predicate: NSPredicate(value: true))
            filterController.filters = filters.filters(self.filterType)
            
            self.presentViewController(filterController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onByCommitteesButton(sender: LTSwitchButton) {
        if rootView.selectedButton != sender {
            rootView.selectedButton = sender
            selectedArray = byCommitteesArray
        }
    }
    
    @IBAction func onByInitializersButton(sender: LTSwitchButton) {
        if rootView.selectedButton != sender {
            rootView.selectedButton = sender
            selectedArray = byInitiatorsArray
        }
    }
    
    @IBAction func byLawsButton(sender: LTSwitchButton) {
        if rootView.selectedButton != sender {
            rootView.selectedButton = sender
            selectedArray = byLawsArray
        }
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        rootView.showDatePicker()
    }
    
    @IBAction func onHidePickerButton(sender: AnyObject) {
        rootView.hideDatePicker()
    }
    
    @IBAction func onDonePickerButton(sender: AnyObject) {
        rootView.hideDatePicker()
        let date = rootView.datePicker.date
        
        downloadChanges(date)
    }
    
    // MARK: - Public
    func setupContent() {
        currentController = storyboard!.instantiateViewControllerWithIdentifier("LTMainContentViewController") as! LTMainContentViewController
        let containerView = rootView.contentView
        addChildViewController(currentController, view: containerView)
        
        setCurrentController(currentController)
        scrollToTop()
    }
    
    // MARK: - Private
    private func scrollToTop() {
        currentController.rootView.contentTableView.setContentOffset(CGPointZero, animated: true)
    }
    
    private func handlePageSwitchingGesture(recognizer: LTPanGestureRacognizer) {
        let location = recognizer.locationInView(recognizer.view)
        let direction = recognizer.direction
        let translation = recognizer.translationInView(recognizer.view)
        let state = recognizer.state
        
        if .Changed == state {
            let dx = recognizer.startLocation.x - location.x;
            let dy = recognizer.startLocation.y - location.y;
            
            let distance = sqrt(dx*dx + dy*dy)
            if distance >= 0.0 {
                if let animator = animator as LTSliderAnimator! {
                    let percent = (.Down == direction && location.y < recognizer.startLocation.y) || (.Up == direction && location.y > recognizer.startLocation.y) ? 0.0 : fabs(distance/CGRectGetHeight(view.bounds))
                    animator.updateInteractiveTransition(percent)
                } else {
                    animator = LTSliderAnimator()
                    if .Down == direction && translation.y > 0 {
                        //downloadChanges previous day -> LTChangesModel
                    } else if translation.y < 0 {
                        //downloadChanges for next day -> LTChangesModel
                    }
                    
                    //instantiate LTMainContentViewController with LTChangesModel
                    let currentController = storyboard!.instantiateViewControllerWithIdentifier("LTMainContentViewController") as! LTMainContentViewController
                    setCurrentController(currentController, animated: true, forwardDirection: .Up == direction)
                }
            }
        } else if .Ended == state {
            let velocity = recognizer.velocityInView(recognizer.view)
            if (velocity.y > 0 && .Down == direction) || (velocity.y < 0 && .Up == direction) {
                animator?.finishInteractiveTransition()
            } else {
                animator?.cancelInteractiveTransition()
            }
        } else if .Cancelled == state {
            animator?.cancelInteractiveTransition()
        }
        
        if .Cancelled == state || .Ended == state {
            animator = nil
        }
    }
    
    func setCurrentController(controller: LTMainContentViewController, animated: Bool, forwardDirection: Bool) {
        if currentController != controller {
            transitionFromViewController(currentController, toViewController: controller, animated: animated, forward: forwardDirection)
        }
    }
    
    func transitionFromViewController(fromViewController: LTMainContentViewController?, toViewController: LTMainContentViewController, animated: Bool, forward: Bool) {
        if false == isViewLoaded() {
            return
        }
        
        let containerView = rootView.contentView
        let destinationView = toViewController.rootView
        destinationView.translatesAutoresizingMaskIntoConstraints = true
        destinationView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        if let _ = fromViewController as LTMainContentViewController! {
            commitFeedController(toViewController)
            
            return
        }
        
        let context = LTTransitionContext(source: fromViewController, destination: toViewController, containerView: containerView, animated: animated, forward: forward)
        context.animator = animator
        
        let interactiveFeedScrollController = false == context.isInteractive() ? LTSliderAnimator() : animator
        if let interactiveFeedScrollController = interactiveFeedScrollController as LTSliderAnimator! {
            interactiveFeedScrollController.operation = forward ? .Pop : .Push
            interactiveFeedScrollController.duration = 0.75
            context.completionBlock = {complete in
                if true == complete {
                    self.commitFeedController(toViewController)
                } else {
                    toViewController.rootView.removeFromSuperview()
                    if let fromViewController = fromViewController as LTMainContentViewController! {
                         fromViewController.rootView.frame = containerView.bounds
                    }
                }
                
                interactiveFeedScrollController.animationEnded(complete)
                containerView.userInteractionEnabled = true
            }
            
            containerView.userInteractionEnabled = false
            
            if context.isInteractive() {
                context.animator.startInteractiveTransition(context)
            } else {
                interactiveFeedScrollController.animateTransition(context)
            }
        }
    }
    
    func commitFeedController(feedController: LTMainContentViewController) {
        if currentController != feedController {
            removeChildViewController(currentController)
            currentController = feedController
            feedController.didMoveToParentViewController(self)
        }
    }
    
    private func downloadChanges(date: NSDate) {
        let view = self.rootView
        
        view.fillSearchButton(date)
        
        if let _ = LTChangeModel.changesForDate(date) as [LTChangeModel]! {
            setChangesModel(date)
            
            return
        }
        
        view.showLoadingViewInViewWithMessage(view.contentView, message: "Завантажую новини за \(date.longString()) \nЗалишилося кілька секунд...")
        LTClient.sharedInstance().downloadChanges(date) { (success, error) -> Void in
            view.hideLoadingView()
            if success {
                self.setChangesModel(date)
                let settingsModel = VTSettingModel()
                settingsModel.lastDownloadDate = date
            } else {
                self.processError(error!)
            }
        }
    }
    
    private func setChangesModel(date: NSDate) {
        changesModel = LTArrayModel(entityName: "LTChangeModel", predicate: NSPredicate(format: "date = %@", date))
        
        if (loadedAtFirst) && (changesModel.count() == 0) && (loadingCount < kLTMaxLoadingCount) {
            loadingCount += 1
            downloadChanges(date.previousDay())
            
            return
        }
        
        loadedAtFirst = false
        
        byCommitteesArray = changesModel.changesByKey(.byCommittees)
        byInitiatorsArray = changesModel.changesByKey(.byInitiators)
        byLawsArray = changesModel.changesByKey(.byLaws)
        
        switch filterType {
        case .byCommittees:
            selectedArray = byCommitteesArray
            
        case .byInitiators:
            selectedArray = byInitiatorsArray
            
        case .byLaws:
            selectedArray = byLawsArray
        }
    }
    
    private func loadData() {
        rootView.showLoadingViewInViewWithMessage(rootView.contentView, message: "Зачекайте, будь ласка.\nТриває завантаження законопроектів, комітетів та ініціаторів...")
        
        let client = LTClient.sharedInstance()
        
        client.downloadConvocations({ (success, error) -> Void in
            if success {
                client.downloadCommittees({ (success, error) -> Void in
                    if success {
                        client.downloadInitiatorTypes({ (success, error) -> Void in
                            if success {
                                client.downloadPersons({ (success, error) -> Void in
                                    if success {
                                        client.downloadLaws({ (success, error) -> Void in
                                            if success {
                                                let settings = VTSettingModel()
                                                if settings.firstLaunch != true {
                                                    settings.setup()
                                                }
                                                
                                                self.rootView.hideLoadingView()
                                                self.downloadChanges(NSDate().previousDay())
                                            } else {
                                                self.processError(error!)
                                            }
                                        })
                                    } else {
                                        self.processError(error!)
                                    }
                                })
                            } else {
                                self.processError(error!)
                            }
                        })
                    } else {
                        self.processError(error!)
                    }
                })
            } else {
                self.processError(error!)
            }
        })
    }
    
    private func processError(error:NSError) {
        rootView.hideLoadingView()
        
        self.displayError(error)
    }
    
    private func setCurrentController(controller: LTMainContentViewController) {
        setCurrentController(controller, animated: false, forwardDirection: false)
    }
    
    //MARK: - LTFilterDelegate methods
    func filtersDidApplied() {
        setChangesModel(rootView.datePicker.date)
    }
    
}
