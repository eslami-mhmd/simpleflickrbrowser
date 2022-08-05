//
//  SearchResponseModel.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/4/22.
//

import Foundation

struct SearchResponseModel: APIResponseProtocol {
    var stat: ResponseStatus
    var code: Int?
    var message: String?
    var photos: FlickrModel?
}

struct FlickrModel: Decodable {
    let page: Int
    let pages: Int
    let photo: [FlickrPhoto]
    let perpage: Int
    let total: Int
}

struct FlickrPhoto: Decodable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int

    ///https://live.staticflickr.com/{server-id}/{id}_{o-secret}_o.{o-format}
    var smallSizeURL: URL? {
        let prefixURL = URL(string: "https://live.staticflickr.com")
        return prefixURL?.appendingPathComponent(server).appendingPathComponent(id
            .appending("_").appending(secret)
            .appending("_")
            .appending("w.jpg"))
    }
}
