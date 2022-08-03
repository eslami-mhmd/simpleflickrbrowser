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
    var flickrItemsBehavior = BehaviorRelay<[FlickrItemData]>(value: [])

    private var searchedValue = BehaviorRelay<String?>(value: nil)
    
    init(repository: FlickrRepositoryProtocol) {
        self.repository = repository
    }
    
    func mockPhotos() {
        flickrItemsBehavior.accept([FlickrItemData(imageAddress: "https://picsum.photos/seed/picsum/200/300"),
                                   FlickrItemData(imageAddress: "https://picsum.photos/id/870/200/300?grayscale&blur=2")])
    }
    
    func updateSearchValue(value: String?) {
        searchedValue.accept(value)
    }

    private func bindSearchText() {
        searchedValue
            .asObservable()
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .distinct()
            .subscribe(onNext: { [weak self] value in
                guard let strongSelf = self,
                      let text = value else { return }
                if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                    
                }
            })
            .disposed(by: disposeBag)
    }
}

struct FlickrItemData {
    let imageAddress: String
}
