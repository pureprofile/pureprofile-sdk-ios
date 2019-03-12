//
//  ViewController.swift
//  SdkSampleApp
//
//  Created by Dimitris Papanikolaou on 27/11/2018.
//  Copyright © 2018 Pureprofile. All rights reserved.
//

import UIKit
import PureprofileSDK

enum Result<Value, Error : Swift.Error> {
    case success(Value)
    case failure(Error)
}

enum LoginError : Error {
    case membershipLimitReached
    case loginFailed
}

func pureprofileLogin(parameters: [String:String], completionHandler: @escaping (Result<PureprofileLoginModel, LoginError>) -> Swift.Void) {
    guard let url = URL(string: "https://pp-auth-api.pureprofile.com/api/v1/panel/login") else { completionHandler(.failure(.loginFailed)); return }
    
    let request = NSMutableURLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
        guard let data = data, let response = response as? HTTPURLResponse else { completionHandler(.failure(.loginFailed)); return }
        
        if response.statusCode >= 400 {
            //In case of HTTP 403 error code it is advisable to check for the panel_membership_limit_reached error case to inform
            //your users that the quota membership limit has been reached.
            //See https://github.com/pureprofile/pureprofile-sdk-ios#membership-limit-reached for more
            if response.statusCode == 403, let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let jsonDict = json as? [String: Any],
                let dataError = jsonDict["data"] as? [String: String],
                dataError["code"] == "panel_membership_limit_reached" {
                completionHandler(.failure(.membershipLimitReached))
            } else {
                completionHandler(.failure(.loginFailed))
            }
        } else {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let model: PureprofileLoginModel = try decoder.decode(PureprofileLoginModel.self, from: data)
                completionHandler(.success(model))
            } catch let error {
                print("Error: \(error)")
                completionHandler(.failure(.loginFailed))
            }
        }
    }
    task.resume()
}

struct PureprofileLoginModel: Decodable {
    /**
     ppToken - Used when calling open method of the SDK
     */
    let ppToken: String
    /**
     instanceUrl - Used when calling the transactions API. See https://github.com/pureprofile/pureprofile-sdk-ios#integrate-sdk-in-your-app for more
     */
    let instanceUrl: String
    /**
     instanceCode - Used when calling the transactions API. See https://github.com/pureprofile/pureprofile-sdk-ios#integrate-sdk-in-your-app for more
     */
    let instanceCode: String
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
         panelKey - key which identifies partner or app, obtained by Pureprofile. Contact us at product@pureprofile.com to get one
         panelSecret - secret paired with panelKey, obtained by Pureprofile
         userKey - unique identifier of each user, see README.md for more
         email - email that can be used to match user (optional)
         */
        let parameters = ["panelKey": "f986e3ac-32c9-42e9-944d-9801dbe28d97", "panelSecret": "c0e6b322-f654-4583-8202-3136504e7843",
                          "userKey": "3467b2a9-c463-4fe5-96a3-e5c3c8934bcc", "email": "sdktest@pureprofile.com"]
        pureprofileLogin(parameters: parameters)  { result in
            switch result {
            case .success(let loginModel):
                self.pureprofileToken = loginModel.ppToken
                
                DispatchQueue.main.async {
                    self.openButton.isEnabled = true
                    self.statusLabel.text = "Ready!"
                    self.activity.stopAnimating()
                }
            case .failure(let error):
                var errorMessage = "Login failed, please try again"
                if error == .membershipLimitReached {
                    errorMessage = "Membership limit has been reached. Please try again later"
                }
                
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.statusLabel.text = errorMessage
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

