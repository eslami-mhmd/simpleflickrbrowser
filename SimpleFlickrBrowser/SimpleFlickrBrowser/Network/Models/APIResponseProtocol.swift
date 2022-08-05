//
//  APIResponseProtocol.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/4/22.
//

import Foundation

protocol APIResponseProtocol: Decodable {
    var stat: ResponseStatus { get }
    var code: Int? { get }
    var message: String? { get }
}

enum ResponseStatus: String, Decodable {
    case ok
    case fail
}
