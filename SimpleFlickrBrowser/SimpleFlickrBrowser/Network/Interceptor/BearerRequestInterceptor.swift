//
//  BearerRequestInterceptor.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/6/22.
//

import Foundation
import Alamofire
import RxSwift

class BearerRequestInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        if let accessToken = KeyChain.loadAsString(key: Constants.KeyChain.accessToken) {
            adaptedRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(adaptedRequest))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if (((error as? AFError)?.underlyingError) as? URLError)?.code == .some(.timedOut) {
            guard request.retryCount < Constants.Network.retryCount else {
                completion(.doNotRetry)
                return
            }
            completion(.retry)
        } else {
            completion(.doNotRetry)
        }
    }
}
