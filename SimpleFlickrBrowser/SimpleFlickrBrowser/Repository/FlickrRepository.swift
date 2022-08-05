//
//  FlickrRepository.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/1/22.
//

import Foundation
import RxSwift

protocol FlickrRepositoryProtocol {
    func searchPhotos(model: SearchRequestModel) -> Observable<SearchResponseModel>
}

struct FlickrRepository: FlickrRepositoryProtocol {
    func searchPhotos(model: SearchRequestModel) -> Observable<SearchResponseModel> {
        NetworkService.default.request(
            PhotosEndPoint.search(model: model),
            model: SearchResponseModel.self
        ).asObservable()
    }
}
