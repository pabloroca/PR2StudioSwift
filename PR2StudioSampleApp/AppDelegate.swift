//
//  AppDelegate.swift
//  PR2StudioSampleApp
//
//  Created by Pablo Roca on 08/02/2019.
//  Copyright © 2019 PR2Studio. All rights reserved.
//

import UIKit
import PR2StudioSwift

struct User: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

struct Joder2: Decodable {
}

public struct Customer2: Decodable {
    let id: String
    let email: String

    enum CustomerKeys: String, CodingKey {
        case id, email, metadata
    }
    public init (from decoder: Decoder) throws {
        let container =  try decoder.container (keyedBy: CustomerKeys.self)
        id = try container.decode (String.self, forKey: .id)
        email = try container.decode (String.self, forKey: .email)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //        let retryConfiguration = RetryConfiguration(retryDelay: 0, maximumretryDelay: 15)
        //        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        //        NetworkSession.shared.setup(urlSession: session, logger: nil, retryConfiguration: retryConfiguration)
        //
        //        var jar = URLRequest("http://ssss.com/getrequest1", method: .get, bearerToken: "mytoken")
        //        jar?.setBearerToken("ddddd")
        //
        //        let jar1 = URLRequest("http://ssss.com/getrequest2", method: .post, parameters: ["client_secret": "secret"], encoding: .json, headers: ["Asagent": "myPC"], bearerToken: "mytoken2")
        //
        //        let jar2 = URLRequest("http://ssss.com/getrequest2", method: .post, parameters: ["client_secret": "secret"], encoding: .url)
        //
        //        let requestOptional = URLRequest("https://jsonplaceholder.typicode.com/todos/1", method: .get)
        //        guard let request = requestOptional else {
        //            return true
        //        }
        //
        //        NetworkSession.shared.dataTask(request, toType: User.self) { (result) in
        //            switch result {
        //            case .success(let value):
        //                print(value)
        //            case .failure(let error):
        //                print(error)
        //            }
        //        }

        // with authorization
        let authorization: Authorization = AuthorizationJWT(authEndPoint: "https://apiccse.pr2studio.com/token", parameters: ["client_secret": "&@$!Jodertio1_IOS!$@&"])
        let sessionA = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let logger = NetworkLogger(logLevel: .networkLoggerLogLevelDebug)
        NetworkSession.shared.setup(urlSession: sessionA, logger: logger)

        // get token and store it in keychain
        authorization.authorize { (result) in
            switch result {
            case .success:
                print("success")

                let getVersionsOpt = URLRequest("https://apiccse.pr2studio.com/versions", method: .get, bearerToken: authorization.loadCredentials())
                if let getVersions = getVersionsOpt {
                    NetworkSession.shared.dataTask(getVersions, toType: Versions.self, authorization: authorization) { (result) in
                        switch result {
                        case .success:
                            print("success")
                        case .failure(let error):
                            print("feilure \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("feilure \(error)")
            }
        }

        //        debugPrint(jar!)
        //        debugPrint(jar1!)
        //        debugPrint(jar2!)

        return true
    }

}
