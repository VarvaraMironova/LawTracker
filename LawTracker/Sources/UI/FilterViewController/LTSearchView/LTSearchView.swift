//
//  LTSearchView.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/7/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

class LTSearchView: UIView {
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    weak var rootView  : UIView!
    var pickerViewShown: Bool = false
    
    //MARK: - Class Methods
    class func searchView(rootView: UIView) -> LTSearchView
    {
        let searchView = NSBundle.mainBundle().loadNibNamed("LTSearchView", owner: self, options: nil).first as! LTSearchView
        var frame = rootView.frame as CGRect
        frame.origin = CGPointZero;
        searchView.frame = frame;
        
        rootView.addSubview(searchView)
        
        searchView.rootView = rootView
        
        return searchView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nibForCell = UINib(nibName: "LTSearchTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(nibForCell, forCellReuseIdentifier: "LTSearchTableViewCell")
    }
    
    //MARK: - Public
    func show() {
        UIView.animateWithDuration(0.4, animations: {
            var tableViewCenter = self.tableView.center
            tableViewCenter.y += CGRectGetHeight(self.tableView.frame)
            self.tableView.center = tableViewCenter
            }, completion: {(finished: Bool) -> Void in
                self.pickerViewShown = true
        })
    }
    
    func hide() {
        UIView.animateWithDuration(0.4, animations: {
            var tableViewCenter = self.tableView.center
            tableViewCenter.y = -(CGRectGetHeight(self.tableView.frame) + CGRectGetHeight(self.searchTextField.frame))
            self.tableView.center = tableViewCenter
            }, completion: {(finished: Bool) -> Void in
                self.pickerViewShown = true
        })
    }
    
    func fillTextFild(searchString: String) {
        searchTextField.text = searchString
    }

}
