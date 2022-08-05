//
//  FlickrListViewModel.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/1/22.
//

import Foundation
import RxSwift
import RxSwiftExt
import RxRelay

class FlickrListViewModel {
    private var disposeBag = DisposeBag()
    private var repository: FlickrRepositoryProtocol
    let error = PublishSubject<String>()
    var flickrPhotosBehavior = BehaviorRelay<[FlickrPhoto]>(value: [])
    private var isFetching = false
    private var totalPages: Int = 0
    private var currentPage: Int = 0
    private var searchedValue = BehaviorRelay<String?>(value: nil)
    
    init(repository: FlickrRepositoryProtocol) {
        self.repository = repository
        bindSearchText()
    }
    
    func searchPhotos(text: String, pageNo: Int = 1) {
        let model = SearchRequestModel(text: text, page: pageNo)
        isFetching = true
        repository.searchPhotos(model: model)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] responseResult in
                print(responseResult)
                guard let strongSelf = self else {
                    return
                }
                strongSelf.isFetching = false
                if responseResult.stat == .fail {
                    strongSelf.error.onNext(responseResult.message ?? "Error.General".localized)
                } else if let photos = responseResult.photos {
                    strongSelf.currentPage = photos.page
                    strongSelf.totalPages = photos.pages
                    
                    var items: [FlickrPhoto] = []
                    if pageNo > 1 {
                        items = strongSelf.flickrPhotosBehavior.value
                    }
                    items.append(contentsOf: photos.photo)
                    
                    strongSelf.flickrPhotosBehavior.accept(items)
                } else {
                    strongSelf.error.onNext("Error.General".localized)
                }
            }, onError: { [weak self] error in
                print(error)
                self?.isFetching = false
                if error as? NetworkError == NetworkError.noInternet {
                    self?.error.onNext("Error.NoInternet".localized)
                } else {
                    self?.error.onNext("Error.General".localized)
                }
            })
            .disposed(by: disposeBag)
    }

    private func bindSearchText() {
        searchedValue.asObservable()
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .distinct()
            .subscribe { [weak self] value in
                guard let text = value.element ?? nil else {
                    return
                }
                self?.searchPhotos(text: text)
        }.disposed(by: disposeBag)
    }
    
    func updateSearchValue(value: String) {
        searchedValue.accept(value)
    }
    
    func getNextPage() {
        if currentPage + 1 <= totalPages {
            if !isFetching, let lastSearchedValue = searchedValue.value {
                searchPhotos(text: lastSearchedValue, pageNo: currentPage + 1)
            }
        }
    }
}
