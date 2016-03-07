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
    
    var currentController     : LTMainContentViewController?
    var destinationController : LTMainContentViewController?
    var animator              : LTSliderAnimator?
    var shownDate             : NSDate?
    
    var dateIsChoosenFromPicker : Bool = false
    var isLoading               : Bool = false
    var loadingCount            : Int = 0
    
    var filterType: LTType = .byCommittees {
        didSet {
            if oldValue != filterType && !isLoading {
                if let currentController = currentController as LTMainContentViewController! {
                    currentController.type = filterType
                } else if let destinationController = destinationController as LTMainContentViewController! {
                    destinationController.type = filterType
                }
                
            }
        }
    }

    var menuViewController: LTMenuViewController {
        get {
            let menuViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LTMenuViewController") as! LTMenuViewController
            menuViewController.delegate = self
            
            return menuViewController
        }
    }
    
    var rootView : LTNewsFeedRootView? {
        get {
            if isViewLoaded() && view.isKindOfClass(LTNewsFeedRootView) {
                return view as? LTNewsFeedRootView
            } else {
                return nil
            }
        }
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if nil == rootView {
            return
        }
        
        setupContent()
        
        let date = NSDate().previousDay()
        rootView!.fillSearchButton(date)
        
        let settingsModel = VTSettingModel()
        if true != settingsModel.firstLaunch {
            //download data from server
            loadData({[unowned self, weak rootView = rootView, weak destinationController = destinationController, weak currentController = currentController] (finish, success) -> Void in
                if success {
                    rootView!.setFilterImages()
                    self.downloadChanges(date, choosenInPicker: false, completionHandler: {(finish, success) -> Void in
                        if success {
                            if let destinationController = destinationController as LTMainContentViewController! {
                                destinationController.loadingDate = date
                                destinationController.type = self.filterType
                            } else {
                                currentController!.loadingDate = date
                                currentController!.type = self.filterType
                            }
                        }
                    })
                }
            })
        } else {
            rootView!.setFilterImages()
            self.downloadChanges(date, choosenInPicker: false, completionHandler: {[weak destinationController = destinationController, weak currentController = currentController] (finish, success) -> Void in
                if success {
                    if let destinationController = destinationController as LTMainContentViewController! {
                        destinationController.loadingDate = date
                        destinationController.type = self.filterType
                    } else {
                        currentController!.loadingDate = date
                        currentController!.type = self.filterType
                    }
                }
            })
        }
        
        //add menuViewController as a childViewController to menuContainerView
        addChildViewControllerInView(menuViewController, view: rootView!.menuContainerView)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({[weak rootView = rootView] (UIViewControllerTransitionCoordinatorContext) -> Void in
            if rootView!.menuShown {
                rootView!.showMenu()
            }}, completion: {(UIViewControllerTransitionCoordinatorContext) -> Void in })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadChangesForAnotherDate:", name: "loadChangesForAnotherDate", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "loadChangesForAnotherDate", object: nil)
    }
    
    //MARK: - Interface Handling
    @IBAction func onGesture(sender: LTPanGestureRacognizer) {
        if isLoading {
            return
        }
        
        let direction = sender.direction
        if direction != .Right {
            handlePageSwitchingGesture(sender)
        }
    }
    
    @IBAction func onDismissFilterViewButton(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {[weak rootView = rootView] in
            rootView!.hideMenu() {finished in}
        }
    }
    
    @IBAction func onMenuButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {[weak rootView = rootView] in
            rootView!.showMenu()
        }
    }
    
    @IBAction func onFilterButton(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak storyboard = storyboard, weak rootView = rootView] in
            let filterController = storyboard!.instantiateViewControllerWithIdentifier("LTFilterViewController") as! LTFilterViewController
            filterController.delegate = self
            
            if !self.isLoading {
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
                
                dispatch_async(CoreDataStackManager.coreDataQueue()) {[unowned self] in
                    let arrayModel = LTArrayModel(entityName: entityName, predicate: NSPredicate(value: true), date: NSDate())
                    rootView!.showLoadingViewInViewWithMessage(rootView!.contentView, message: "Завантаження фільтрів...")
                    arrayModel.filters(self.filterType, completionHandler: { (result, finish) -> Void in
                        if finish {
                            rootView!.hideLoadingView()
                            dispatch_async(dispatch_get_main_queue()) {[unowned self] in
                                filterController.filters = result
                                self.presentViewController(filterController, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func onByCommitteesButton(sender: LTSwitchButton) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView] in
            if rootView!.selectedButton != sender {
                self.scrollToTop()
                rootView!.selectedButton = sender
                self.filterType = .byCommittees
            }
        }
    }
    
    @IBAction func onByInitializersButton(sender: LTSwitchButton) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView] in
            if rootView!.selectedButton != sender {
                self.scrollToTop()
                rootView!.selectedButton = sender
                self.filterType = .byInitiators
            }
        }
    }
    
    @IBAction func byLawsButton(sender: LTSwitchButton) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView] in
            self.scrollToTop()
            if rootView!.selectedButton != sender {
                self.scrollToTop()
                rootView!.selectedButton = sender
                self.filterType = .byLaws
            }
        }
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {[weak rootView = rootView] in
            rootView!.showDatePicker()
        }
    }
    
    @IBAction func onHidePickerButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {[weak rootView = rootView] in
            rootView!.hideDatePicker()
        }
    }
    
    @IBAction func onDonePickerButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView, weak destinationController = destinationController, weak currentController = currentController] in
            rootView!.hideDatePicker()
            
            if self.isLoading {
                return
            }
            
            self.scrollToTop()
            let date = rootView!.datePicker.date
            
            self.downloadChanges(date, choosenInPicker: true, completionHandler: {(finish, success) -> Void in
                if success {
                    if let destinationController = destinationController as LTMainContentViewController! {
                        destinationController.loadingDate = date
                    } else {
                        currentController!.loadingDate = date
                    }
                }
            })
        }
    }
    
    func refreshData() {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak date = rootView!.datePicker.date, weak destinationController = destinationController, weak currentController = currentController] in
            let alertViewController: UIAlertController = UIAlertController(title: "Оновити базу законопроектів, ініціаторів та комітетів?", message:"Це може зайняти кілька хвилин", preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction(title: "Так", style: .Default, handler: {(UIAlertAction) in
                self.loadData({(finish, success) -> Void in
                    if success {
                        self.downloadChanges(date!, choosenInPicker: false, completionHandler: {(finish, success) -> Void in
                            if success {
                                if let destinationController = destinationController as LTMainContentViewController! {
                                    destinationController.loadingDate = date
                                } else {
                                    currentController!.loadingDate = date
                                }
                            }
                        })
                    }
                })
            }))
            
            alertViewController.addAction(UIAlertAction(title: "Ні", style: .Default, handler: nil))
    
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationGesture == gestureRecognizer || navigationGesture == otherGestureRecognizer
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isLoading {
            return false
        }
        
        if nil == currentController {
            return false
        }
        
        if nil == currentController!.rootView {
            return false
        }
        
        if nil == rootView {
            return false
        }
        
        navigationGesture.changeDirection()
        if let navigationController = navigationController as UINavigationController! {
            let shouldPop = navigationController.viewControllers.count > 1
            var isNavigationGesture = false
            if let gestureRecognizer = navigationGesture as LTPanGestureRacognizer! {
                let direction = gestureRecognizer.direction
                isNavigationGesture = .Right == direction
            }
            
            if shouldPop && isNavigationGesture {
                return true
            }
            
            if self != navigationController.topViewController {
                return false
            }
            
            let tableView = currentController!.rootView!.contentTableView
            let bounds = tableView.bounds
            let dateInPicker = rootView!.datePicker.date
            let shouldAnimateToTop = (CGRectGetMinY(bounds) <= 0 && .Down == navigationGesture.direction && dateInPicker.dateWithoutTime().compare(NSDate().dateWithoutTime()) == .OrderedAscending)
            let shouldAnimateToBottom = ((CGRectGetMaxY(bounds) >= (tableView.contentSize.height - 1)) && .Up == navigationGesture.direction)
            let shouldBegin = shouldAnimateToTop || shouldAnimateToBottom
            
            if !shouldBegin && (CGRectGetMinY(bounds) <= 0 && .Down == navigationGesture.direction && dateInPicker.dateWithoutTime().compare(NSDate().dateWithoutTime()) == .OrderedSame) {
                refreshData()
            }
            
            return shouldBegin
        }
        
        return false
    }
    
    // MARK: - Public
    func setupContent() {
        if let rootView = rootView as LTNewsFeedRootView! {
            currentController = storyboard!.instantiateViewControllerWithIdentifier("LTMainContentViewController") as? LTMainContentViewController
            let containerView = rootView.contentView
            addChildViewControllerInView(currentController!, view: containerView)
            
            setCurrentController(currentController!)
            scrollToTop()
        }
    }
    
    // MARK: - Private
    private func scrollToTop() {
        if let currentController = currentController as LTMainContentViewController! {
            if let currentControllerView = currentController.rootView as LTMainContentRootView! {
                currentControllerView.contentTableView.setContentOffset(CGPointZero, animated: false)
            }
        } else if let destinationController = destinationController as LTMainContentViewController! {
            if let destinationControllerView = destinationController.rootView as LTMainContentRootView! {
                destinationControllerView.contentTableView.setContentOffset(CGPointZero, animated: false)
            }
        }
        
    }
    
    private func handlePageSwitchingGesture(recognizer: LTPanGestureRacognizer) {
        if nil == rootView {
            return
        }
        
        let recognizerView = recognizer.view
        let location = recognizer.locationInView(recognizerView)
        let direction = recognizer.direction
        let translation = recognizer.translationInView(recognizerView)
        let state = recognizer.state
        
        if .Changed == state {
            let dx = recognizer.startLocation.x - location.x
            let dy = recognizer.startLocation.y - location.y
            
            let distance = sqrt(dx*dx + dy*dy)
            if distance >= 0.0 {
                if let animator = animator as LTSliderAnimator! {
                    let percent = (.Down == direction && location.y < recognizer.startLocation.y) || (.Up == direction && location.y > recognizer.startLocation.y) ? 0.0 : fabs(distance/CGRectGetHeight(recognizerView!.bounds))
                    animator.updateInteractiveTransition(percent)
                } else {
                    animator = LTSliderAnimator()
                    
                    //instantiate LTMainContentViewController with LTChangesModel
                    let nextController = storyboard!.instantiateViewControllerWithIdentifier("LTMainContentViewController") as! LTMainContentViewController
                    setCurrentController(nextController, animated: true, forwardDirection: .Up == direction)
                    
                    let dateInPicker = rootView!.datePicker.date
                    if .Down == direction && translation.y > 0 {
                        if dateInPicker.compare(NSDate()) == .OrderedAscending {
                            let date = dateInPicker.nextDay()
                            downloadChanges(date, choosenInPicker: false, completionHandler: {[weak destinationController = destinationController, weak currentController = currentController] (finish, success) -> Void in
                                if success {
                                    if let destinationController = destinationController as LTMainContentViewController! {
                                        destinationController.loadingDate = date
                                        destinationController.type = self.filterType
                                    } else {
                                        currentController!.loadingDate = date
                                        currentController!.type = self.filterType
                                    }
                                }
                            })
                        }
                    } else if translation.y < 0 {
                        let date = dateInPicker.previousDay()
                        downloadChanges(date, choosenInPicker: false, completionHandler: {[weak destinationController = destinationController, weak currentController = currentController] (finish, success) -> Void in
                            if success {
                                if let destinationController = destinationController as LTMainContentViewController! {
                                    destinationController.loadingDate = date
                                    destinationController.type = self.filterType
                                } else {
                                    currentController!.loadingDate = date
                                    currentController!.type = self.filterType
                                }
                            }
                        })
                    }
                }
            }
        } else if .Ended == state {
            let velocity = recognizer.velocityInView(recognizerView)
            if (velocity.y > 0 && .Down == direction) || (velocity.y < 0 && .Up == direction) {
                scrollToTop()
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
            destinationController = controller
            transitionFromViewController(currentController, toViewController: controller, animated: animated, forward: forwardDirection)
        }
    }
    
    func transitionFromViewController(fromViewController: LTMainContentViewController?, toViewController: LTMainContentViewController, animated: Bool, forward: Bool) {
        if false == isViewLoaded() {
            return
        }
        
        let containerView = rootView!.contentView
        
        toViewController.view.translatesAutoresizingMaskIntoConstraints = true
        toViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addChildViewControllerInView(toViewController, view:containerView)
        
        if nil == fromViewController {
            commitFeedController(toViewController)
            
            return
        }
        
        let context = LTTransitionContext(source: fromViewController, destination: toViewController, containerView: containerView, animated: animated, forward: forward)
        context.animator = animator
        
        let interactiveFeedScrollController = false == context.isInteractive() ? LTSliderAnimator() : animator
        if let interactiveFeedScrollController = interactiveFeedScrollController as LTSliderAnimator! {
            interactiveFeedScrollController.operation = forward ? .Pop : .Push
            interactiveFeedScrollController.duration = 0.5
            context.completionBlock = {[unowned self] (complete) in
                if true == complete {
                    self.commitFeedController(toViewController)
                } else {
                    toViewController.view.removeFromSuperview()
                    fromViewController!.view.frame = containerView.bounds
                    self.currentController = fromViewController
                    self.destinationController = nil
                }
                
                interactiveFeedScrollController.animationEnded(complete)
                containerView.userInteractionEnabled = true
            }
            
            containerView.userInteractionEnabled = false
            
            if context.isInteractive() {
                if let _ = animator as LTSliderAnimator! {
                    context.animator!.startInteractiveTransition(context)
                }
            } else {
                interactiveFeedScrollController.animateTransition(context)
            }
        }
    }
    
    func commitFeedController(feedController: LTMainContentViewController) {
        //remove rootView of previous currentController from superview
        if currentController != feedController {
            if nil != currentController {
                removeChildController(currentController!)
            }
            
            currentController = feedController
            destinationController = nil
            feedController.didMoveToParentViewController(self)
        }
    }
    
    private func downloadChanges(date: NSDate, choosenInPicker: Bool, completionHandler:(finish: Bool, success: Bool) -> Void) {
        if let rootView = rootView as LTNewsFeedRootView! {
            rootView.fillSearchButton(date)
            dateIsChoosenFromPicker = choosenInPicker
            
            dispatch_async(CoreDataStackManager.coreDataQueue()) {[unowned self, weak rootView = rootView] in
                if let changes = LTChangeModel.changesForDate(date) as [LTChangeModel]! {
                    if changes.count > 0 {
                        completionHandler(finish: true, success: true)
                        
                        return
                    }
                }
                
                //self.isLoading = true
                rootView!.showLoadingViewInViewWithMessage(rootView!.contentView, message: "Завантажую новини за \(date.longString()) \nЗалишилося кілька секунд...")
                let client = LTClient.sharedInstance()
                client.downloadChanges(date) {[unowned self] (success, error) -> Void in
                    rootView!.hideLoadingView()
                    //self.isLoading = false
                    
                    if success {
                        let settingsModel = VTSettingModel()
                        settingsModel.firstLaunch = true
                        settingsModel.lastDownloadDate = date
                        
                        completionHandler(finish: true, success: success)
                    } else {
                        self.processError(error!){[unowned self] (void) in
                            self.downloadChanges(date, choosenInPicker: choosenInPicker, completionHandler: completionHandler)
                        }
                        
                        completionHandler(finish: true, success: success)
                    }
                }
            }
        }
    }
    
    private func loadData(completionHandler:(finish: Bool, success: Bool) -> Void) {
        if nil == rootView {
            return
        }
        
        isLoading = true
        rootView!.showLoadingViewInViewWithMessage(rootView!.contentView, message: "Зачекайте, будь ласка.\nТриває завантаження законопроектів, комітетів та ініціаторів...")
        
        let client = LTClient.sharedInstance()
        client.downloadConvocations({[unowned self, weak rootView = rootView] (success, error) -> Void in
            self.isLoading = false
            if success {
                self.isLoading = true
                client.downloadCommittees({ (success, error) -> Void in
                    self.isLoading = false
                    if success {
                        self.isLoading = true
                        client.downloadInitiatorTypes({ (success, error) -> Void in
                            self.isLoading = false
                            if success {
                                self.isLoading = true
                                client.downloadPersons({ (success, error) -> Void in
                                    self.isLoading = false
                                    if success {
                                        self.isLoading = true
                                        client.downloadLaws({ (success, error) -> Void in
                                            self.isLoading = false
                                            if success {
                                                rootView!.hideLoadingView()
                                                completionHandler(finish: true, success: true)
                                            } else {
                                                completionHandler(finish: true, success: false)
                                                self.processError(error!){[unowned self] void in
                                                    self.loadData(completionHandler)
                                                }
                                            }
                                        })
                                    } else {
                                        completionHandler(finish: true, success: false)
                                        self.processError(error!){[unowned self] void in
                                            self.loadData(completionHandler)
                                        }
                                     }
                                })
                            } else {
                                completionHandler(finish: true, success: false)
                                self.processError(error!){[unowned self] void in
                                    self.loadData(completionHandler)
                                }
                             }
                        })
                    } else {
                        completionHandler(finish: true, success: false)
                        self.processError(error!){[unowned self] void in
                            self.loadData(completionHandler)
                        }
                    }
                })
            } else {
                completionHandler(finish: true, success: false)
                self.processError(error!){[unowned self] void in
                    self.loadData(completionHandler)
                }
            }
        })
    }
    
    private func clearData(completionHandler:(success: Bool, error: NSError?) -> Void) {
        if nil == rootView {
            completionHandler(success: false, error: nil)
        }
        
        rootView!.showLoadingViewInViewWithMessage(rootView!.contentView, message: "Зачекайте, будь ласка.\nТриває очищення данних...")
        let manager = CoreDataStackManager.sharedInstance()
        manager.clearEntity("LTChangeModel") {[unowned self, weak rootView = rootView] (success, error) -> Void in
            if success {
                manager.clearEntity("LTLawModel", completionHandler: { (success, error) -> Void in
                    if success {
                        manager.clearEntity("LTInitiatorModel", completionHandler: { (success, error) -> Void in
                            if success {
                                manager.clearEntity("LTInitiatorTypeModel", completionHandler: { (success, error) -> Void in
                                    if success {
                                        manager.clearEntity("LTCommitteeModel", completionHandler: { (success, error) -> Void in
                                            if success {
                                                rootView!.hideLoadingView()
                                                print("coreData is clean!")
                                                completionHandler(success: true, error: nil)
                                            } else {
                                                completionHandler(success: false, error: error!)
                                                self.processError(error!){[unowned self] void in
                                                    self.clearData(completionHandler)
                                                }
                                            }
                                        })
                                        
                                    } else {
                                        completionHandler(success: false, error: error!)
                                        self.processError(error!){[unowned self] void in
                                            self.clearData(completionHandler)
                                        }
                                    }
                                })
                            } else {
                                completionHandler(success: false, error: error!)
                                self.processError(error!){[unowned self] void in
                                    self.clearData(completionHandler)
                                }
                            }
                        })
                    } else {
                        completionHandler(success: false, error: error!)
                        self.processError(error!){[unowned self] void in
                            self.clearData(completionHandler)
                        }
                    }
                })
            } else {
                completionHandler(success: false, error: error!)
                self.processError(error!){[unowned self] void in
                    self.clearData(completionHandler)
                }
            }
        }
    }
    
    private func processError(error:NSError, completionHandler:(UIAlertAction) -> Void) {
        rootView!.hideLoadingView()
        isLoading = false
        var title = String()

        switch error.code {
        case -998:
            title = "Щось негаразд."
            break
            
        case -1000:
            title = "Не вдалося згенерувати URL."
            break
            
        case -1001:
            title = "Перевищено час очікування відповіді серверу."
            break
            
        case -1003, -1004:
            title = "Не вдалось зв’язатися з сервером."
            break
            
        case -1005:
            title = "Інтернет-зв’язок перервався."
            break
            
        case -1009:
            title = "Немає доступу до Інтернету."
            break
            
        case -1011:
            title = "Некоректна відповідь сервера."
            break
            
        case -1015, -1016:
            title = "Не вдалося декодувати дані."
            break
            
        case -1017:
            title = "Некоректна структура відповіді сервера."
            break
            
        default:
            title = error.localizedDescription
            break
        }
        
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            let alertViewController: UIAlertController = UIAlertController(title: title, message: "Повторити спробу завантаження?", preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction(title: "Так", style: .Default, handler: completionHandler))
            
            alertViewController.addAction(UIAlertAction(title: "Ні", style: .Default, handler: nil))
            
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
    }
    
    private func setCurrentController(controller: LTMainContentViewController) {
        setCurrentController(controller, animated: false, forwardDirection: false)
    }
    
    //MARK: - LTFilterDelegate methods
    func filtersDidApplied() {
        if isLoading {
            return
        }
        
        rootView!.setFilterImages()
        if let currentController = currentController as LTMainContentViewController! {
            currentController.arrayModelFromChanges()
        }
    }
    
    //MARK: - NSNotificationCenter
    func loadChangesForAnotherDate(notification: NSNotification) {
        if nil == rootView {
            return
        }
        
        let date = nil == shownDate ? NSDate().previousDay() : shownDate
        if let userInfo = notification.userInfo as NSDictionary! {
            let dateInPicker = rootView!.datePicker.date
            
            if let needLoadChangesForAnotherDate = userInfo["needLoadChangesForAnotherDay"] as? Bool {
                if needLoadChangesForAnotherDate {
                    if !dateIsChoosenFromPicker && (dateInPicker.compare(NSDate().dateWithoutTime()) != .OrderedSame) && (loadingCount < kLTMaxLoadingCount) {
                        loadingCount += 1
                        var newDate = date
                        if date!.dateWithoutTime().compare(dateInPicker.dateWithoutTime()) == .OrderedAscending {
                            newDate = dateInPicker.nextDay()
                        } else {
                            newDate = dateInPicker.previousDay()
                        }
                        
                        downloadChanges(newDate!, choosenInPicker: false, completionHandler: {[weak currentController = currentController, weak destinationController = destinationController] (finish, success) -> Void in
                            if success {
                                if let destinationController = destinationController as LTMainContentViewController! {
                                    destinationController.loadingDate = newDate
                                } else {
                                    currentController!.loadingDate = newDate
                                }
                            }
                        })
                        
                        return
                    }
                    
                    shownDate = dateInPicker
                    if loadingCount == kLTMaxLoadingCount {
                        if let currentController = currentController as LTMainContentViewController! {
                            currentController.rootView!.noSubscriptionsLabel.text = "За встановленими фільтрами немає змін протягом \(kLTMaxLoadingCount) днів з \(shownDate!.longString())"
                        }
                    }
                } else {
                    shownDate = dateInPicker
                }
                
                loadingCount = 0
            }
        }
    }
    
}
