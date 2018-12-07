//
//  ViewController.swift
//  SdkSampleApp
//
//  Created by Dimitris Papanikolaou on 27/11/2018.
//  Copyright © 2018 Pureprofile. All rights reserved.
//

import UIKit
import PureprofileSDK

func pureprofileLogin(parameters: [String:String], completionHandler: @escaping (String?) -> Swift.Void) {
    guard let url = URL(string: "https://pp-auth-api.pureprofile.com/api/v1/panel/login") else { completionHandler(nil); return }
    
    let request = NSMutableURLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard let data = data else { completionHandler(nil); return }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let token: PureprofileToken = try decoder.decode(PureprofileToken.self, from: data)
            print(token)
            completionHandler(token.ppToken)
        } catch let error {
            print("Error: \(error)")
            completionHandler(nil)
        }
    }
    task.resume()
}

struct PureprofileToken: Decodable {
    let ppToken: String
}

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton!
    
    var pureprofileToken = ""
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login()
    }

    @IBAction func openPureprofile(_ sender: Any) {
        Pureprofile().open(fromViewController: self, loginToken: pureprofileToken) { payment in
            print("Received payment of value \(payment.value) with uuid \(payment.uuid)")
        }
    }
    
    private func login() {
        /**
         panelKey - key which identifies partner or app, obtained by Pureprofile, contact us at product@pureprofile.com
         panelSecret - secret paired with panelKey, obtained by Pureprofile
         userKey - unique identifier of each user, see README.md for more
         email - email that can be used to match user (optional)
         */
        let parameters = ["panelKey": "f986e3ac-32c9-42e9-944d-9801dbe28d97", "panelSecret": "c0e6b322-f654-4583-8202-3136504e7843",
                          "userKey": "3467b2a9-c463-4fe5-96a3-e5c3c8934bcc", "email": "sdktest@pureprofile.com"]
        pureprofileLogin(parameters: parameters)  { token in
                                        if let token = token {
                                            self.pureprofileToken = token
                                            
                                            DispatchQueue.main.async {
                                                self.openButton.isEnabled = true
                                                self.statusLabel.text = "Ready!"
                                                self.activity.stopAnimating()
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                self.activity.stopAnimating()
                                                self.statusLabel.text = "Login failed, please try again"
                                                self.retryButton.isHidden = false
                                            }
                                        }
        }
    }
    
    @IBAction func retryLogin(_ sender: Any) {
        retryButton.isHidden = true
        self.statusLabel.text = "Logging in..."
        activity.startAnimating()
        login()
    }
    
}

