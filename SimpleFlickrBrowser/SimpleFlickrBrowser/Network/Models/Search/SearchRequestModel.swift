//
//  SearchRequestModel.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/4/22.
//

import Foundation

struct SearchRequestModel: APIRequestProtocol, Encodable {
    var api_key = Constants.Network.api_key
    var method = "flickr.photos.search"
    let format = Constants.Network.format
    let nojsoncallback = Constants.Network.nojsoncallback
    var text: String
    var page: Int
}
