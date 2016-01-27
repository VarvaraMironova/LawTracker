//
//  LTTableViewExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

extension UITableView {
    
    func reusableCell(cellClass: AnyClass, indexPath: NSIndexPath) -> UITableViewCell {
        return self.dequeueReusableCellWithIdentifier(String(cellClass), forIndexPath: indexPath)
    }
}
