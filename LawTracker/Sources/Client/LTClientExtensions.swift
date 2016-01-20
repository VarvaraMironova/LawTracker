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
let init3 = "Національний банк України"
let init4 = "Депутат"

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
        let laws = [["id":"3100-12", "title":law1, "filing_date":"2015-12-03", "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642", "committee":"commettee1ID", "initiators":["person1"]], ["id":"3100-15", "title":law2, "filing_date":"2015-12-03", "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57640", "committee":"commettee2ID", "initiators":["person5", "person6"]], ["id":"3185", "title":law3, "filing_date":"2015-12-03", "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642", "committee":"commettee3ID", "initiators":["person3"]]]
        CoreDataStackManager.sharedInstance().storeLawsFromArray(laws){finished in
            if finished {
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    func downloadCommittees(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //MOCK!
        let committees = [["id":"commettee1ID", "title":Commitee1, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642", "starts":"null", "ends":"null"], ["id":"commettee2ID", "title":Commitee2, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642", "starts":"null", "ends":"null"], ["id":"commettee3ID", "title":Commitee3, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642", "starts":"null", "ends":"null"], ["id":"commettee4ID", "title":Commitee4, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642", "starts":"null", "ends":"null"], ["id":"commettee5ID", "title":Commitee5, "url":"http://w1.c1.rada.gov.ua/pls/zweb2/webproc4_1?pf3511=57642", "starts":"null", "ends":"null"]]
        CoreDataStackManager.sharedInstance().storeCommitteesFromArray(committees){finished in
            if finished {
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    func downloadPersons(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //MOCK!
        let persons = [["id":"person1", "first_name":"Петро", "second_name":"Олексійович", "last_name":"Порошенко", "initiator_type":"president"], ["id":"person2", "first_name":"Віктор", "second_name":"Федорович", "last_name":"Янукович", "initiator_type":"president"], ["id":"person3", "first_name":"Арсеній", "second_name":"Петрович", "last_name":"Яценюк", "initiator_type":"cabmin"], ["id":"person4", "first_name":"Валерія", "second_name":"Олексіївна", "last_name":"Гонтарьова", "initiator_type":"bank"], ["id":"person5", "first_name":"Олександр", "second_name":"Рафкатович", "last_name":"Абдуллін", "initiator_type":"deputy"], ["id":"person6", "first_name":"Арсен", "second_name":"Борисович", "last_name":"Аваков", "initiator_type":"deputy"]]
        CoreDataStackManager.sharedInstance().storePersonsFromArray(persons){finished in
            if finished {
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    func downloadInitiatorTypes(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //MOCK!
        let types = ["president":init1, "cabmin":init2, "bank":init3, "deputy":init4]
        CoreDataStackManager.sharedInstance().storeInitiatorTypesFromArray(types){finished in
            if finished {
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    func downloadChanges(completionHandler:(success: Bool, error: NSError?) -> Void) {
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
    
    func getPersonWithId(id: String, completionHandler:(person: LTPersonModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func getInitiatorTypeWithId(id: String, completionHandler:(type:LTInitiatorTypeModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func getCommitteeWithId(id: String, completionHandler:(committee:LTCommitteeModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func cancel() {
        if nil != downloadTask {
            downloadTask!.cancel()
        }
    }

}