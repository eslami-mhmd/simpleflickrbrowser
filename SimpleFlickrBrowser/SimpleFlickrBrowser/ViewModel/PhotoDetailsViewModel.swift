//
//  PhotoDetailsViewModel.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/6/22.
//

import UIKit
import RxSwift
import RxCocoa

class PhotoDetailsViewModel {
    let imageURLBehavior = BehaviorRelay<URL?>(value: nil)

    func setData(imageURL: URL?) {
        imageURLBehavior.accept(imageURL)
    }
}
