//
//  SearchEndpoint.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/4/22.
//

import Alamofire
import Foundation

enum PhotosEndPoint {
    case search(model: SearchRequestModel)
}

extension PhotosEndPoint: URLRequestBuilder {
    var parameters: Parameters? {
        switch self {
        case .search(let model):
            return model.dictionary
        }
    }

    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        switch self {
        case .search:
            return HTTPMethod.get
        }
    }
}
