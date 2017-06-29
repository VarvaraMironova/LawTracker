//
//  LTTableViewExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/4/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

extension UITableView {
    
    func reusableCell(_ cellClass: AnyClass, indexPath: IndexPath) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath)
    }
}
