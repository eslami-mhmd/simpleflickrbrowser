//
//  BasicRequestInterceptor.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/6/22.
//

import Foundation
import Alamofire

class BasicRequestInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        if let basicCredentials = basicCredentials() {
            adaptedRequest.setValue("Basic \(basicCredentials)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(adaptedRequest))
    }
    
    private func basicCredentials() -> String? {
        guard let clientId = KeyChain.loadAsString(key: Constants.KeyChain.clientId),
              let clientSecret = KeyChain.loadAsString(key: Constants.KeyChain.clientSecret) else {
            return nil
        }
        return String(format: "%@:%@", clientId, clientSecret)
            .data(using: String.Encoding.utf8)?
            .base64EncodedString()
    }
}
