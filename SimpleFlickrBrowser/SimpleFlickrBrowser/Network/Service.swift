//
//  Service.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/3/22.
//

import Alamofire
import Foundation
import RxSwift

enum NetworkError: Error {
    case noInternet
    case badRequest
    case unauthorized
    case unknown
}

protocol NetworkServiceProtocol: AnyObject {
    func request<T: Decodable>(_ urlConvertible: URLRequestBuilder, model: T.Type) -> Observable<T>
}

class NetworkService: NetworkServiceProtocol {
    private var sessionManager = SessionManager.session(authType: .none)

    func request<T: Decodable>(_ urlConvertible: URLRequestBuilder, model: T.Type) -> Observable<T> {
        sessionManager = SessionManager.session(authType: urlConvertible.authType)
        return  Observable<T>.create { [weak self] observer in
            let request = self?.sessionManager.request(urlConvertible).responseDecodable { (response: DataResponse<T, AFError>) in
                switch response.result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure:
                    switch response.response?.statusCode {
                    case 400:
                        observer.onError(NetworkError.badRequest)
                    case 401:
                        observer.onError(NetworkError.unauthorized)
                    default:
                        let isReachable = NetworkReachabilityManager()?.isReachable ?? false
                        if !isReachable {
                            observer.onError(NetworkError.noInternet)
                        } else {
                            observer.onError(NetworkError.unknown)
                        }
                    }
                }
            }
            //Finally, we return a disposable to stop the request
            return Disposables.create {
                request?.cancel()
            }
        }
    }
}
