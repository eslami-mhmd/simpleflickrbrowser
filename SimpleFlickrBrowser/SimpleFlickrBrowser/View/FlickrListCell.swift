//
//  FlickrListCell.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/1/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol ReuseIdentifierProtocol {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifierProtocol {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

class FlickrListCell: UICollectionViewCell, ReuseIdentifierProtocol {
}
