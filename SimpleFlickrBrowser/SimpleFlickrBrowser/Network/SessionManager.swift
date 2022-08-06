//
//  SessionManager.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/6/22.
//

import Foundation
import Alamofire

enum AuthType {
    case basic, bearer, none
}

class SessionManager {
    static func session(authType: AuthType) -> Alamofire.Session {
        switch authType {
        case .basic:
            return Alamofire.Session(
                configuration: URLSessionConfiguration.default,
                interceptor: BasicRequestInterceptor()
            )
        case .bearer:
            return Alamofire.Session(
                configuration: URLSessionConfiguration.default,
                interceptor: BearerRequestInterceptor()
            )
        case .none:
            return Alamofire.Session(
                configuration: URLSessionConfiguration.default,
                interceptor: NoAuthRequestInterceptor()
            )
        }
    }
}
