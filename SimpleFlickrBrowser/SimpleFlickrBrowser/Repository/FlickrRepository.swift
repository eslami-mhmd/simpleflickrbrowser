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

class FlickrRepository: FlickrRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func searchPhotos(model: SearchRequestModel) -> Observable<SearchResponseModel> {
        networkService.request(
            PhotosEndPoint.search(model: model),
            model: SearchResponseModel.self
        ).asObservable()
    }
}
