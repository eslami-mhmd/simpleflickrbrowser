//
//  APIRequestProtocol.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/4/22.
//

import Foundation

protocol APIRequestProtocol: Encodable {
    var method: String { get }
    var api_key: String { get }
    var format: ResponseFormat { get }
    var nojsoncallback: Int { get }
}

enum ResponseFormat: String, Encodable {
    case json
}
