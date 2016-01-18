//
//  LTClientExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

let Commitee1 = "Комітет з питань аграрної політики та земельних відносин"
let Commitee2 = "Комітет з питань будівництва, містобудування і житлово-комунального господарства"
let Commitee3 = "Комітет з питань бюджету"
let Commitee4 = "Комітет з питань державного будівництва, регіональної політики та місцевого самоврядування"
let Commitee5 = "Комітет з питань екологічної політики, природокористування та ліквідації наслідків Чорнобильської катастрофи"

let init1 = "Президент"
let init2 = "Кабінет містрів України"
let init3 = "Абдуллін Олександр Рафкатович"
let init4 = "Аваков Арсен Борисович"

let law1 = "Проект Закону про внесення змін до статті 1071 Цивільного кодексу України (щодо списання коштів з рахунка померлого потерпілого від нещасного випадку на виробництві)"
let law2 = "Проект Закону про внесення змін до деяких законів України щодо посилення гарантій безпеки дітей"
let law3 = "Проект Закону про внесення змін до Закону України \"Про підприємництво\""
let law4 = "Проект Закону про внесення змін до деяких законодавчих актів України щодо земельних ділянок багатоквартирних будинків"
let law5 = "Проект Постанови про відхилення проекту Закону України про внесення змін до Закону України \"Про основні принципи та вимоги до безпечності та якості харчових продуктів\" щодо приведення норм до вимог Митного кодексу"
let law6 = "Проект Закону про ратифікацію Угоди між Україною та Королівством Іспанія про взаємну охорону інформації з обмеженим доступом"

//news
let date1 = "2015-12-03 17:09"
let desc1 = "Направлений до комітетів та розміщений на Веб-сайті Верховної Ради України"
let date2 = "2015-12-03 17:07"
let desc2 = "Прийнятий на поточній сесії"
let date3 = "2015-12-03 17:04"
let desc3 = "Зареєстрований"
let date4 = "2015-12-03 17:04"
let date5 = "2015-12-03 17:04"
let date6 = "2015-12-03 17:04"

extension LTClient {
    
    func downloadLaws(completionHandler:(success: Bool, error: NSError?) -> Void) {
//        let urlString = kVTParameters.baseURL
//        let url = NSURL(string: urlString)!
//        let request = NSURLRequest(URL: url)
//        
//        downloadTask = self.task(request){data, error in
//            if nil != error {
//                completionHandler(success: false, error: error)
//            } else {
//                LTClient.parseJSONWithCompletionHandler(data) {result, error in
//                    if nil != error {
//                        completionHandler(success: false, error: error)
//                    } else {
//                        if let lawsDictionary = result.valueForKey(kVTKeys.laws) as! [[String: AnyObject]]! {
//                            CoreDataStackManager.sharedInstance().storeLawsFromArray(lawsDictionary){finished in
//                                if finished {
//                                    completionHandler(success: true, error: nil)
//                                }
//                            }
//                        } else {
//                            let contentError = LTClient.errorForMessage("Can't find key 'laws' in \(result)")
//                            completionHandler(success: false, error: contentError)
//                        }
//                    }
//                }
//            }
//        }
        
        //MOCK!
        sleep(2)
        let laws = [["id":"3100-12", "name":law1, "date":"2015-12-03", "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642", "committee":"commettee1ID", "initialisers":["initialiser1ID"]], ["id":"3100-15", "name":law2, "date":"2015-12-03", "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57640", "committee":"commettee2ID", "initialisers":["initialiser3ID", "initialiser4ID"]], ["id":"3185", "name":law3, "date":"2015-12-03", "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642", "committee":"commettee2ID", "initialisers":["initialiser2ID"]]]
        CoreDataStackManager.sharedInstance().storeLawsFromArray(laws){finished in
            if finished {
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    func downloadCommittees(completionHandler:(success: Bool, error: NSError?) -> Void) {
        sleep(2)
        //MOCK!
        let committees = [["id":"commettee1ID", "name":Commitee1, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642"], ["id":"commettee2ID", "name":Commitee2, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642"], ["id":"commettee3ID", "name":Commitee3, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642"], ["id":"commettee4ID", "name":Commitee4, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642"], ["id":"commettee5ID", "name":Commitee5, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642"]]
        CoreDataStackManager.sharedInstance().storeCommitteesFromArray(committees){finished in
            if finished {
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    func downloadInitialisers(completionHandler:(success: Bool, error: NSError?) -> Void) {
        sleep(2)
        //MOCK!
        let initialisers = [["id":"initialiser1ID", "name":init1, "deputy":0], ["id":"initialiser2ID", "name":init2, "deputy":0], ["id":"initialiser3ID", "name":init3, "deputy":1], ["id":"initialiser4ID", "name":init4, "deputy":1]]
        CoreDataStackManager.sharedInstance().storeInitialisersFromArray(initialisers){finished in
            if finished {
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    func downloadChanges(completionHandler:(success: Bool, error: NSError?) -> Void) {
        sleep(2)
        //MOCK!
        let changes = [["date":date1, "text":desc1, "law":"3100-12"], ["date":date2, "text":desc2, "law":"3100-15"], ["date":date3, "text":desc3, "law":"3185"]]
        CoreDataStackManager.sharedInstance().storeChangesFromArray(changes){finished in
            if finished {
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    func getLawWithId(id: String, completionHandler:(law: LTLawModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func getInitialiserWithId(id: String, completionHandler:(initialiser: LTInitialiserModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func getCommitteeWithId(id: String, completionHandler:(committee:LTCommitteeModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func cancel() {
        if nil != downloadTask {
            downloadTask!.cancel()
        }
    }

}