//
//  Constants.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/5/22.
//

import Foundation

struct Constants {
    struct KeyChain {
        static let accessToken = "accessToken"
        static let clientId = "clientId"
        static let clientSecret = "clientSecret"
    }
    
    struct Network {
        static let api_key = ""
        static let retryCount = 1
        static let format: ResponseFormat = .json
        static let nojsoncallback: Int = 1
    }
}
