//
//  LTMenuViewController.swift
//  LawTracker
//
//  Created by Varvara Mironova on 12/11/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit

let kLTChesnoURL = "http://www.chesno.org"

enum LTMenuCells: Int {
    case manual = 0,
    webSite     = 1
    
    static let cellTypes = [manual, webSite]
};

class LTMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var menuDelegate: LTMenuDelegate?
    
    //MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LTMenuCells.cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LTMenuTableViewCell", for: indexPath) as! LTMenuTableViewCell
        var string = ""
        switch indexPath.row {
        case 0:
            string = "Мануал"
            break
            
        case 1:
            string = "На веб-сайт Чесно"
            break
            
        default:
            break
        }
        
        cell.fill(string)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menuDelegate = menuDelegate {
            menuDelegate.hideMenu() {[weak storyboard = self.storyboard, weak navigationController = navigationController] (finished) in
                if finished {
                    switch indexPath.row {
                    case 0:
                        DispatchQueue.main.async {
                            let helpViewController = storyboard!.instantiateViewController(withIdentifier: "LTHelpController") as! LTHelpController
                            navigationController!.present(helpViewController, animated: true, completion: nil)
                            //navigationController!.pushViewController(helpViewController, animated: true)
                        }
                        
                        break
                        
                    case 1:
                        let url = URL(string: kLTChesnoURL)
                        let app = UIApplication.shared
                        if app.canOpenURL(url!) {
                            app.openURL(url!)
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
