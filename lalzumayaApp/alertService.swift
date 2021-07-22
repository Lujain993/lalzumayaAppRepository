//
//  alertService.swift
//  lalzumayaApp
//
//  Created by Lujain Z on 22/07/2021.
//

import UIKit

class alertService {
    
    func alert(title: String, message: String) -> alertBoxViewController {
        
        let storyboard = UIStoryboard(name: "AlertBox", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "alertVC") as! alertBoxViewController
        
        alertVC.AlertMessage = message
        alertVC.AlertTitle = title
        
        return alertVC
    }
}
