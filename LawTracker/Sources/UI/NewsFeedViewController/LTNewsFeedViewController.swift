//
//  LTNewsFeedViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 2/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit
let kLTMaxLoadingCount = 30

class LTNewsFeedViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate, LTMenuDelegate, LTFilterDelegate {
    @IBOutlet var navigationGesture: LTPanGestureRacognizer!
    
    var currentController     : LTMainContentViewController?
    var destinationController : LTMainContentViewController?
    var animator              : LTSliderAnimator?
    var shownDate             : Date?
    
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
    
    var minDate : Date {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            return dateFormatter.date(from: "2000-01-01")!
        }
    }

    var menuViewController: LTMenuViewController {
        get {
            let menuViewController = self.storyboard!.instantiateViewController(withIdentifier: "LTMenuViewController") as! LTMenuViewController
            menuViewController.menuDelegate = self
            
            return menuViewController
        }
    }
    
    var rootView : LTNewsFeedRootView? {
        get {
            if isViewLoaded && view.isKind(of: LTNewsFeedRootView.self) {
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
        
        let date = Date().previousDay()
        rootView!.fillSearchButton(date)
        
        //observe internet connection
        NotificationCenter.default.addObserver(self, selector: #selector(LTNewsFeedViewController.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: {[weak rootView = rootView] (UIViewControllerTransitionCoordinatorContext) -> Void in
            if rootView!.menuShown {
                rootView!.showMenu()
            }}, completion: {(UIViewControllerTransitionCoordinatorContext) -> Void in })
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LTNewsFeedViewController.loadChangesForAnotherDate(_:)), name: NSNotification.Name(rawValue: "loadChangesForAnotherDate"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loadChangesForAnotherDate"), object: nil)
    }
    
    func networkStatusChanged(_ notification: Notification) {
        let userInfo = notification.userInfo
        print(userInfo ?? "nil")
    }
    
    //MARK: - Interface Handling
    @IBAction func onGesture(_ sender: LTPanGestureRacognizer) {
        let direction = sender.direction
        if direction != .right {
            handlePageSwitchingGesture(sender)
        }
    }
    
    @IBAction func onDismissFilterViewButton(_ sender: UIButton) {
        DispatchQueue.main.async {[weak rootView = rootView] in
            rootView!.hideMenu() {finished in}
        }
    }
    
    @IBAction func onMenuButton(_ sender: AnyObject) {
        DispatchQueue.main.async {[weak rootView = rootView] in
            rootView!.showMenu()
        }
    }
    
    @IBAction func onFilterButton(_ sender: UIButton) {
        DispatchQueue.main.async {[unowned self, weak storyboard = storyboard, weak rootView = rootView] in
            let filterController = storyboard!.instantiateViewController(withIdentifier: "LTFilterViewController") as! LTFilterViewController
            filterController.type = self.filterType
            filterController.filterDelegate = self
            
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
                
                CoreDataStackManager.coreDataQueue().async {[unowned self] in
                    let arrayModel = LTArrayModel(entityName: entityName, predicate: NSPredicate(value: true), date: Date())
                    rootView!.showLoadingViewInViewWithMessage(rootView!.contentView, message: "Завантаження фільтрів...")
                    arrayModel.filters(self.filterType, completionHandler: { (result, finish) -> Void in
                        if finish {
                            rootView!.hideLoadingView()
                            DispatchQueue.main.async {[unowned self] in
                                filterController.filters = result
                                self.present(filterController, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func onByCommitteesButton(_ sender: LTSwitchButton) {
        DispatchQueue.main.async {[unowned self, weak rootView = rootView] in
            if rootView!.selectedButton != sender {
                self.scrollToTop()
                rootView!.selectedButton = sender
                self.filterType = .byCommittees
            }
        }
    }
    
    @IBAction func onByInitializersButton(_ sender: LTSwitchButton) {
        DispatchQueue.main.async {[unowned self, weak rootView = rootView] in
            if rootView!.selectedButton != sender {
                self.scrollToTop()
                rootView!.selectedButton = sender
                self.filterType = .byInitiators
            }
        }
    }
    
    @IBAction func byLawsButton(_ sender: LTSwitchButton) {
        DispatchQueue.main.async {[unowned self, weak rootView = rootView] in
            self.scrollToTop()
            if rootView!.selectedButton != sender {
                self.scrollToTop()
                rootView!.selectedButton = sender
                self.filterType = .byLaws
            }
        }
    }
    
    @IBAction func onSearchButton(_ sender: AnyObject) {
        DispatchQueue.main.async {[weak rootView = rootView] in
            rootView!.showDatePicker()
        }
    }
    
    @IBAction func onHidePickerButton(_ sender: AnyObject) {
        DispatchQueue.main.async {[weak rootView = rootView] in
            rootView!.hideDatePicker()
        }
    }
    
    @IBAction func onDonePickerButton(_ sender: AnyObject) {
        let client = LTClient.sharedInstance()
        if let task = client.downloadTask as URLSessionDataTask! {
            task.cancel()
        }
        
        isLoading = false
        
        DispatchQueue.main.async {[unowned self, weak rootView = rootView, weak destinationController = destinationController, weak currentController = currentController] in
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
        DispatchQueue.main.async {[unowned self, date = rootView!.datePicker.date, weak destinationController = destinationController, weak currentController = currentController] in
            let alertViewController: UIAlertController = UIAlertController(title: "Оновити базу законопроектів, ініціаторів та комітетів?", message:"Це може зайняти кілька хвилин", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "Так", style: .default, handler: {(UIAlertAction) in
                self.loadData({(finish, success) -> Void in
                    if success {
                        self.downloadChanges(date, choosenInPicker: false, completionHandler: {(finish, success) -> Void in
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
            
            alertViewController.addAction(UIAlertAction(title: "Ні", style: .default, handler: nil))
    
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationGesture == gestureRecognizer || navigationGesture == otherGestureRecognizer
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
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
                isNavigationGesture = .right == direction
            }
            
            if shouldPop && isNavigationGesture {
                return true
            }
            
            if self != navigationController.topViewController {
                return false
            }
            
            let tableView = currentController!.rootView!.contentTableView
            let bounds = tableView?.bounds
            let dateInPicker = rootView!.datePicker.date
            let shouldAnimateToTop = (bounds!.minY <= 0 && .down == navigationGesture.direction && dateInPicker.dateWithoutTime().compare(Date().dateWithoutTime()) == .orderedAscending)
            let shouldAnimateToBottom = ((bounds!.maxY >= (tableView!.contentSize.height - 1)) && .up == navigationGesture.direction)
            let shouldBegin = shouldAnimateToTop || shouldAnimateToBottom
            
            if !shouldBegin && (bounds!.minY <= 0 && .down == navigationGesture.direction && dateInPicker.dateWithoutTime().compare(Date().dateWithoutTime()) == .orderedSame) {
                refreshData()
            }
            
            if (.up == navigationGesture.direction && dateInPicker.dateWithoutTime().compare(minDate) == .orderedSame) {
                return false
            }
            
            return shouldBegin
        }
        
        return false
    }
    
    // MARK: - Public
    func setupContent() {
        if let rootView = rootView as LTNewsFeedRootView! {
            currentController = storyboard!.instantiateViewController(withIdentifier: "LTMainContentViewController") as? LTMainContentViewController
            let containerView = rootView.contentView
            addChildViewControllerInView(currentController!, view: containerView!)
            
            setCurrentController(currentController!, animated: false, forwardDirection: false)
            scrollToTop()
        }
    }
    
    // MARK: - Private
    fileprivate func scrollToTop() {
        if let currentController = currentController as LTMainContentViewController! {
            if let currentControllerView = currentController.rootView as LTMainContentRootView! {
                currentControllerView.contentTableView.setContentOffset(CGPoint.zero, animated: false)
            }
        } else if let destinationController = destinationController as LTMainContentViewController! {
            if let destinationControllerView = destinationController.rootView as LTMainContentRootView! {
                destinationControllerView.contentTableView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
        
    }
    
    fileprivate func handlePageSwitchingGesture(_ recognizer: LTPanGestureRacognizer) {
        if nil == rootView {
            return
        }
        
        let recognizerView = recognizer.view
        let location = recognizer.location(in: recognizerView)
        let direction = recognizer.direction
        let translation = recognizer.translation(in: recognizerView)
        let state = recognizer.state
        
        if .changed == state {
            let dx = recognizer.startLocation.x - location.x
            let dy = recognizer.startLocation.y - location.y
            
            let distance = sqrt(dx*dx + dy*dy)
            if distance >= 0.0 {
                if let animator = animator as LTSliderAnimator! {
                    let percent = (.down == direction && location.y < recognizer.startLocation.y) || (.up == direction && location.y > recognizer.startLocation.y) ? 0.0 : fabs(distance/recognizerView!.bounds.height)
                    animator.updateInteractiveTransition(percent)
                } else {
                    animator = LTSliderAnimator()
                    
                    //instantiate LTMainContentViewController with LTChangesModel
                    let nextController = storyboard!.instantiateViewController(withIdentifier: "LTMainContentViewController") as! LTMainContentViewController
                    setCurrentController(nextController, animated: true, forwardDirection: .up == direction)
                    
                    let dateInPicker = rootView!.datePicker.date
                    if .down == direction && translation.y > 0 {
                        if dateInPicker.compare(Date()) == .orderedAscending {
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
        } else if .ended == state {
            let velocity = recognizer.velocity(in: recognizerView)
            if (velocity.y > 0 && .down == direction) || (velocity.y < 0 && .up == direction) {
                scrollToTop()
                animator?.finishInteractiveTransition()
            } else {
                animator?.cancelInteractiveTransition()
            }
        } else if .cancelled == state {
            animator?.cancelInteractiveTransition()
        }
        
        if .cancelled == state || .ended == state {
            animator = nil
        }
    }
    
    func setCurrentController(_ controller: LTMainContentViewController, animated: Bool, forwardDirection: Bool) {
        if currentController != controller {
            destinationController = controller
            transitionFromViewController(currentController, toViewController: controller, animated: animated, forward: forwardDirection)
        }
    }
    
    func transitionFromViewController(_ fromViewController: LTMainContentViewController?, toViewController: LTMainContentViewController, animated: Bool, forward: Bool) {
        if false == isViewLoaded {
            return
        }
        
        let containerView = rootView!.contentView
        
        toViewController.view.translatesAutoresizingMaskIntoConstraints = true
        toViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChildViewControllerInView(toViewController, view:containerView!)
        
        if nil == fromViewController {
            commitFeedController(toViewController)
            
            return
        }
        
        let context = LTTransitionContext(source: fromViewController, destination: toViewController, containerView: containerView!, animated: animated, forward: forward)
        context.animator = animator
        
        let interactiveFeedScrollController = false == context.isInteractive ? LTSliderAnimator() : animator
        if let interactiveFeedScrollController = interactiveFeedScrollController as LTSliderAnimator! {
            interactiveFeedScrollController.operation = forward ? .pop : .push
            interactiveFeedScrollController.duration = 0.5
            context.completionBlock = {[unowned self] (complete) in
                if true == complete {
                    self.commitFeedController(toViewController)
                } else {
                    toViewController.view.removeFromSuperview()
                    fromViewController!.view.frame = (containerView?.bounds)!
                    self.currentController = fromViewController
                    self.destinationController = nil
                }
                
                interactiveFeedScrollController.animationEnded(complete)
                containerView?.isUserInteractionEnabled = true
            }
            
            containerView?.isUserInteractionEnabled = false
            
            if context.isInteractive {
                if let _ = animator as LTSliderAnimator! {
                    context.animator!.startInteractiveTransition(context)
                }
            } else {
                interactiveFeedScrollController.animateTransition(using: context)
            }
        }
    }
    
    func commitFeedController(_ feedController: LTMainContentViewController) {
        //remove rootView of previous currentController from superview
        if currentController != feedController {
            if nil != currentController {
                removeChildController(currentController!)
            }
            
            currentController = feedController
            destinationController = nil
            feedController.didMove(toParentViewController: self)
        }
    }
    
    fileprivate func downloadChanges(_ date: Date, choosenInPicker: Bool, completionHandler:@escaping (_ finish: Bool, _ success: Bool) -> Void) {
        
        let status = Reach().connectionStatus()
        
        switch status {
        case .unknown, .offline:
            let userInfo = [NSLocalizedDescriptionKey : "Немає доступу до Інтернету."]
            let error = NSError(domain: "ConnectionError", code: -1009, userInfo: userInfo)
            processError(error){[unowned self] (void) in
                self.downloadChanges(date, choosenInPicker: choosenInPicker, completionHandler: completionHandler)
            }
            
            completionHandler(true, false)
            self.isLoading = false
            
            return
            
        default:
            break
        }
        
        isLoading = true
        if let rootView = rootView as LTNewsFeedRootView! {
            rootView.fillSearchButton(date)
            dateIsChoosenFromPicker = choosenInPicker
            
            CoreDataStackManager.coreDataQueue().async {[unowned self, weak rootView = rootView] in
                if let changes = LTChangeModel.changesForDate(date) as [LTChangeModel]! {
                    if changes.count > 0 {
                        completionHandler(true, true)
                        self.isLoading = false
                        return
                    }
                }
                
                rootView!.showLoadingViewInViewWithMessage(rootView!.contentView, message: "Завантажую новини за \(date.longString()) \nЗалишилося кілька секунд...")
                let client = LTClient.sharedInstance()
                client.downloadChanges(date) {[unowned self] (success, error) -> Void in
                    rootView!.hideLoadingView()
                    self.isLoading = false
                    if success {
                        let settingsModel = VTSettingModel()
                        settingsModel.firstLaunch = true
                        settingsModel.lastDownloadDate = date
                        
                        completionHandler(true, success)
                    } else {
                        self.processError(error!){[unowned self] (void) in
                            self.downloadChanges(date, choosenInPicker: choosenInPicker, completionHandler: completionHandler)
                        }
                        
                        completionHandler(true, success)
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    fileprivate func loadData(_ completionHandler:@escaping (_ finish: Bool, _ success: Bool) -> Void) {
        if nil == rootView {
            return
        }
        
        let status = Reach().connectionStatus()
        
        switch status {
        case .unknown, .offline:
            let userInfo = [NSLocalizedDescriptionKey : "Немає доступу до Інтернету."]
            let error = NSError(domain: "ConnectionError", code: -1009, userInfo: userInfo)
            processError(error){[unowned self] (void) in
                self.loadData(completionHandler)
            }
            
            completionHandler(true, false)
            self.isLoading = false
            
            return
            
        default:
            break
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
                                                completionHandler(true, true)
                                            } else {
                                                completionHandler(true, false)
                                                self.processError(error!){[unowned self] void in
                                                    self.loadData(completionHandler)
                                                }
                                            }
                                        })
                                    } else {
                                        completionHandler(true, false)
                                        self.processError(error!){[unowned self] void in
                                            self.loadData(completionHandler)
                                        }
                                     }
                                })
                            } else {
                                completionHandler(true, false)
                                self.processError(error!){[unowned self] void in
                                    self.loadData(completionHandler)
                                }
                             }
                        })
                    } else {
                        completionHandler(true, false)
                        self.processError(error!){[unowned self] void in
                            self.loadData(completionHandler)
                        }
                    }
                })
            } else {
                completionHandler(true, false)
                self.processError(error!){[unowned self] void in
                    self.loadData(completionHandler)
                }
            }
        })
    }
    
    fileprivate func processError(_ error:NSError, completionHandler:@escaping (UIAlertAction) -> Void) {
        rootView!.hideLoadingView()
        isLoading = false
        var title = String()

        switch error.code {
        case -998:
            title = "Щось негаразд."
            break
            
        case -999:
            title = "Скасовано."
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
            
        case 3840:
            title = "Некоректний формат даних."
            break
            
        default:
            title = error.localizedDescription
            break
        }
        
        DispatchQueue.main.async {[unowned self] in
            let alertViewController: UIAlertController = UIAlertController(title: title, message: "Повторити спробу завантаження?", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "Так", style: .default, handler: completionHandler))
            
            alertViewController.addAction(UIAlertAction(title: "Ні", style: .default, handler: nil))
            
            self.present(alertViewController, animated: true, completion: nil)
        }
    }
    
    //MARK: - LTMenuDelegate methods
    func hideMenu(_ completionHandler: @escaping (_ finished: Bool) -> Void) {
        if let rootView = rootView {
            rootView.hideMenu({ (finished) -> Void in
                completionHandler(finished)
            })
            
            return
        }
        
        completionHandler(false)
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
    func loadChangesForAnotherDate(_ notification: Notification) {
        isLoading = false
        if nil == rootView {
            return
        }
    
        let date = nil == shownDate ? Date().previousDay() : shownDate
        if let userInfo = notification.userInfo as NSDictionary! {
            let dateInPicker = rootView!.datePicker.date
            
            if let needLoadChangesForAnotherDate = userInfo["needLoadChangesForAnotherDay"] as? Bool {
                if needLoadChangesForAnotherDate {
                    if !dateIsChoosenFromPicker && (dateInPicker.compare(Date().dateWithoutTime()) != .orderedSame) && (loadingCount < kLTMaxLoadingCount) && dateInPicker.compare(minDate) != .orderedSame {
                        loadingCount += 1
                        var newDate = date
                        if date!.dateWithoutTime().compare(dateInPicker.dateWithoutTime()) == .orderedAscending {
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
                    
                    if loadingCount == kLTMaxLoadingCount {
                        if let currentController = currentController as LTMainContentViewController! {
                            currentController.rootView!.noSubscriptionsLabel.text = "За встановленими фільтрами немає змін протягом останніх \(kLTMaxLoadingCount) днів"
                        }
                    }
                    
                }
                
                shownDate = dateInPicker
                loadingCount = 0
            }
        }
    }
    
}
