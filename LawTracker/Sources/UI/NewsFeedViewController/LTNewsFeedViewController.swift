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
    var shownDate         : NSDate! = NSDate() {
        didSet {
            rootView.fillSearchButton(shownDate)
        }
    }
    
    var isLoading     : Bool = false
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
        set {
            currentController.arrayModel = newValue
        }

        get {
            switch filterType {
            case .byCommittees:
                return byCommitteesArray
                
            case .byInitiators:
                return byInitiatorsArray
                
            case .byLaws:
                return byLawsArray
            }
        }
    }
    
    var byLawsArray       = LTChangesModel() {
        didSet {
            if oldValue != byLawsArray {
                if filterType == .byLaws {
                    selectedArray = byLawsArray
                }
                
                rootView.byBillsButton.filtersSet = byLawsArray.filtersApplied
            }
        }
    }
    
    var byCommitteesArray = LTChangesModel() {
        didSet {
            if oldValue != byCommitteesArray {
                if filterType == .byCommittees {
                    selectedArray = byCommitteesArray
                }
                
                rootView.byCommitteesButton.filtersSet = byCommitteesArray.filtersApplied
            }
        }
    }
    
    var byInitiatorsArray = LTChangesModel() {
        didSet {
            if oldValue != byInitiatorsArray {
                if filterType == .byInitiators {
                    selectedArray = byInitiatorsArray
                }
                
                rootView.byInitiatorsButton.filtersSet = byInitiatorsArray.filtersApplied
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
    
    var rootView : LTNewsFeedRootView! {
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
        
        automaticallyAdjustsScrollViewInsets = false
        
        setupContent()
        
        let settingsModel = VTSettingModel()
        let date = NSDate().previousDay()
        if true != settingsModel.firstLaunch {
            //download data from server
            loadData()
        } else {
            downloadChanges(date, choosenInPicker: false)
        }
        
        shownDate = date
        
        //add menuViewController as a childViewController to menuContainerView
        addChildViewController(menuViewController, view: rootView.menuContainerView)
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
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "contentDidChange:",
            name: "contentDidChange",
            object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "contentDidChange", object: nil)
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
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView, weak byCommitteesArray = byCommitteesArray] in
            if rootView!.selectedButton != sender {
                self.scrollToTop()
                rootView!.selectedButton = sender
                self.selectedArray = byCommitteesArray!
            }
        }
    }
    
    @IBAction func onByInitializersButton(sender: LTSwitchButton) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView, weak byInitiatorsArray = byInitiatorsArray] in
            if rootView!.selectedButton != sender {
                self.scrollToTop()
                rootView!.selectedButton = sender
                self.selectedArray = byInitiatorsArray!
            }
        }
    }
    
    @IBAction func byLawsButton(sender: LTSwitchButton) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView, weak byLawsArray = byLawsArray] in
            self.scrollToTop()
            if rootView!.selectedButton != sender {
                self.scrollToTop()
                rootView!.selectedButton = sender
                self.selectedArray = byLawsArray!
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
        dispatch_async(dispatch_get_main_queue()) {[unowned self, weak rootView = rootView] in
            rootView!.hideDatePicker()
            
            if self.isLoading {
                return
            }
            
            self.scrollToTop()
            let date = rootView!.datePicker.date
            
            self.downloadChanges(date, choosenInPicker: true)
        }
    }
    
    func refreshData() {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            let alertViewController: UIAlertController = UIAlertController(title: "Оновити базу законопроектів, ініціаторів та комітетів?", message:"Це може зайняти кілька хвилин", preferredStyle: .Alert)
            alertViewController.addAction(UIAlertAction(title: "Так", style: .Default, handler: {[unowned self] (UIAlertAction) in
                self.loadData()
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
            
            let tableView = currentController.rootView.contentTableView
            let bounds = tableView.bounds
            let shouldAnimateToTop = (CGRectGetMinY(bounds) <= 0 && .Down == navigationGesture.direction && shownDate.dateWithoutTime().compare(NSDate().dateWithoutTime()) == .OrderedAscending)
            let shouldAnimateToBottom = ((CGRectGetMaxY(bounds) >= (tableView.contentSize.height - 1)) && .Up == navigationGesture.direction)
            let shouldBegin = shouldAnimateToTop || shouldAnimateToBottom
            
            if !shouldBegin && (CGRectGetMinY(bounds) <= 0 && .Down == navigationGesture.direction && shownDate.dateWithoutTime().compare(NSDate().dateWithoutTime()) == .OrderedSame) {
                refreshData()
            }
            
            return shouldBegin
        }
        
        return false
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
        currentController.rootView.contentTableView.setContentOffset(CGPointZero, animated: false)
    }
    
    private func handlePageSwitchingGesture(recognizer: LTPanGestureRacognizer) {
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
                    
                    if .Down == direction && translation.y > 0 {
                        if shownDate.compare(NSDate()) == .OrderedAscending {
                            downloadChanges(shownDate.nextDay(), choosenInPicker: false)
                        }
                    } else if translation.y < 0 {
                        downloadChanges(shownDate.previousDay(), choosenInPicker: false)
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
            transitionFromViewController(currentController, toViewController: controller, animated: animated, forward: forwardDirection)
            currentController = controller
        }
    }
    
    func transitionFromViewController(fromViewController: LTMainContentViewController?, toViewController: LTMainContentViewController, animated: Bool, forward: Bool) {
        if false == isViewLoaded() {
            return
        }
        
        let containerView = rootView.contentView
        
        toViewController.view.translatesAutoresizingMaskIntoConstraints = true
        toViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addChildViewController(toViewController, view:containerView)
        
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
                    if let arrayModel = fromViewController!.arrayModel as LTChangesModel! {
                        self.shownDate = arrayModel.date
                    }
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
        if currentController != feedController {
            removeChildViewController(currentController)
            currentController = feedController
            feedController.didMoveToParentViewController(self)
        }
    }
    
    private func downloadChanges(date: NSDate, choosenInPicker: Bool) {
        let view = self.rootView
        
        view.fillSearchButton(date)
            
        if let changes = LTChangeModel.changesForDate(date) as [LTChangeModel]! {
            if changes.count > 0 {
                setChangesModel(date, choosenInPicker: choosenInPicker)
                
                return
            }
        }
        
        view.showLoadingViewInViewWithMessage(view.contentView, message: "Завантажую новини за \(date.longString()) \nЗалишилося кілька секунд...")
        let client = LTClient.sharedInstance()
        client.downloadChanges(date) {[unowned self] (success, error) -> Void in
            view.hideLoadingView()
            if success {
                dispatch_async(dispatch_get_main_queue()) {[unowned self] in
                    self.setChangesModel(date, choosenInPicker: choosenInPicker)
                    let settingsModel = VTSettingModel()
                    settingsModel.firstLaunch = true
                    settingsModel.lastDownloadDate = date
                }
            } else {
                self.processError(error!){[unowned self] (void) in
                    self.downloadChanges(date, choosenInPicker: choosenInPicker)
                }
            }
        }
    }
    
    private func setChangesModel(date: NSDate, choosenInPicker: Bool) {
        dispatch_async(CoreDataStackManager.coreDataQueue()) { [weak shownDate = shownDate, weak currentController = currentController] in
            let changesModel = LTArrayModel(entityName: "LTChangeModel", predicate: NSPredicate(format: "date = %@", date.dateWithoutTime()), date: date.dateWithoutTime())
            
            changesModel.changes {(byBills, byInitiators, byCommittees, finish) in
                dispatch_async(dispatch_get_main_queue()) {[unowned self] in
                    self.changesModel = changesModel
                    if finish {
                        self.byLawsArray = byBills
                        self.byInitiatorsArray = byInitiators
                        self.byCommitteesArray = byCommittees
                    }
                    
                    print(self.byLawsArray, byBills)
                    
                    if !choosenInPicker && (self.selectedArray.count() == 0) && (date.compare(NSDate().dateWithoutTime()) != .OrderedSame) && (self.loadingCount < kLTMaxLoadingCount) {
                        self.loadingCount += 1
                        var newDate = date
                        if shownDate!.dateWithoutTime().compare(date.dateWithoutTime()) == .OrderedAscending {
                            newDate = date.nextDay()
                        } else {
                            newDate = date.previousDay()
                        }
                        
                        self.downloadChanges(newDate, choosenInPicker: false)
                        
                        return
                    }
                    
                    if self.loadingCount == kLTMaxLoadingCount {
                        currentController!.rootView.noSubscriptionsLabel.text = "За встановленими фільтрами немає змін протягом \(kLTMaxLoadingCount) днів з \(shownDate!.longString())"
                    }
                    
                    self.shownDate = date
                    self.loadingCount = 0
                }
            }
        }
    }
    
    private func loadData() {
        isLoading = true
        rootView.showLoadingViewInViewWithMessage(rootView.contentView, message: "Зачекайте, будь ласка.\nТриває завантаження законопроектів, комітетів та ініціаторів...")
        
        let client = LTClient.sharedInstance()
        client.downloadConvocations({[unowned self, weak rootView = rootView] (success, error) -> Void in
            if success {
                client.downloadCommittees({ (success, error) -> Void in
                    if success {
                        client.downloadInitiatorTypes({ (success, error) -> Void in
                            if success {
                                client.downloadPersons({ (success, error) -> Void in
                                    if success {
                                        client.downloadLaws({ (success, error) -> Void in
                                            if success {
                                                rootView!.hideLoadingView()
                                                self.isLoading = false
                                                self.downloadChanges(NSDate().previousDay(), choosenInPicker: false)
                                            } else {
                                                self.processError(error!){[unowned self] void in
                                                    self.loadData()
                                                }
                                            }
                                        })
                                    } else {
                                        self.processError(error!){[unowned self] void in
                                            self.loadData()
                                        }
                                    }
                                })
                            } else {
                                self.processError(error!){[unowned self] void in
                                    self.loadData()
                                }
                            }
                        })
                    } else {
                        self.processError(error!){[unowned self] void in
                            self.loadData()
                        }
                    }
                })
            } else {
                self.processError(error!){[unowned self] void in
                    self.loadData()
                }
            }
        })
    }
    
    private func clearData(completionHandler:(success: Bool, error: NSError?) -> Void) {
        rootView.showLoadingViewInViewWithMessage(rootView.contentView, message: "Зачекайте, будь ласка.\nТриває очищення данних...")
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
                                                completionHandler(success: false, error: error)
                                                self.processError(error!){[unowned self] void in
                                                    self.loadData()
                                                }
                                            }
                                        })
                                        
                                    } else {
                                        completionHandler(success: false, error: error)
                                        self.processError(error!){[unowned self] void in
                                            self.loadData()
                                        }
                                    }
                                })
                            } else {
                                completionHandler(success: false, error: error)
                                self.processError(error!){[unowned self] void in
                                    self.loadData()
                                }
                            }
                        })
                    } else {
                        completionHandler(success: false, error: error)
                        self.processError(error!){[unowned self] void in
                            self.loadData()
                        }
                    }
                })
            } else {
                completionHandler(success: false, error: error)
                self.processError(error!){[unowned self] void in
                        self.loadData()
                }
            }
        }
    }
    
    private func processError(error:NSError, completionHandler:(UIAlertAction) -> Void) {
        rootView.hideLoadingView()
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
        
        setChangesModel(rootView.datePicker.date, choosenInPicker: false)
    }
    
    //MARK: - NSNotificationCenter
    func contentDidChange(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            if let userInfo = notification.userInfo as [NSObject: AnyObject]! {
                if let changesModel = userInfo["changesModel"] as? LTChangesModel {
                    if let keyValue = userInfo["key"] as? Int {
                        switch keyValue {
                        case 0:
                            self.byCommitteesArray = changesModel
                            if self.filterType == .byCommittees {
                                self.selectedArray = changesModel
                            }
                            
                            break
                            
                        case 1:
                            self.byInitiatorsArray = changesModel
                            if self.filterType == .byInitiators {
                                self.selectedArray = changesModel
                            }
                            
                            break
                            
                        case 2:
                            self.byLawsArray = changesModel
                            if self.filterType == .byLaws {
                                self.selectedArray = changesModel
                            }
                            
                            break
                            
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
}
