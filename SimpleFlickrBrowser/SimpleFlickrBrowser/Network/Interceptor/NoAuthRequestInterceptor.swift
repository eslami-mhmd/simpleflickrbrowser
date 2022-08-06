//
//  NoAuthRequestInterceptor.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/6/22.
//

import Alamofire
import Foundation

class NoAuthRequestInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
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
