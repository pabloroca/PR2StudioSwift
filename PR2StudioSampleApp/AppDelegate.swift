//
//  AppDelegate.swift
//  PR2StudioSampleApp
//
//  Created by Pablo Roca on 08/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import UIKit
import PR2StudioSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let retryConfiguration = RetryConfiguration(retryDelay: 0, maximumretryDelay: 15)
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        NetworkSession.shared.setup(urlSession: session, logger: nil, retryConfiguration: retryConfiguration, userAgent: "aaa")
        NetworkSession.shared.userAgent = "sssssss"

        let joder = URLRequest("https://jsonplaceholder.typicode.com/todos/1", method: .get)

        var jar = URLRequest("http://ssss.com/getrequest1", method: .get, bearerToken: "mytoken")
        jar?.setBearerToken("ddddd")

        let jar1 = URLRequest("http://ssss.com/getrequest2", method: .post, parameters: ["client_id": "ios", "client_secret": "secret"], encoding: .json, headers: ["Asagent": "myPC"], bearerToken: "mytoken2")

        let jar2 = URLRequest("http://ssss.com/getrequest2", method: .post, parameters: ["client_id": "ios", "client_secret": "secret"], encoding: .url)

        guard let request = joder else {
            return true
        }
        NetworkSession.shared.dataTask(request) { (response) in
            print("aqui")
            print(response)
        }

        debugPrint(jar!)
        debugPrint(jar1!)
        debugPrint(jar2!)

        return true
    }

}
