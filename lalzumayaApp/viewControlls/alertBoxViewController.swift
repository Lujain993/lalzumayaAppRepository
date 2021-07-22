//
//  alertBoxViewController.swift
//  lalzumayaApp
//
//  Created by Lujain Z on 22/07/2021.
//

import UIKit

class alertBoxViewController: UIViewController {

    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertMessage: UILabel!
    @IBOutlet weak var dissmissButton: UIButton!
    
    var AlertTitle = String()
    var AlertMessage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    func setupView() {
        alertTitle.text = AlertTitle
        alertMessage.text = AlertMessage
    }
    @IBAction func dismissTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
