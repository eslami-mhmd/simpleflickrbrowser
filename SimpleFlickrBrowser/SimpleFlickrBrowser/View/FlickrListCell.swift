//
//  FlickrListCell.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/1/22.
//

import Kingfisher
import SnapKit
import UIKit

class FlickrListCell: UICollectionViewCell, ReuseIdentifierProtocol {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(data: FlickrPhoto) {
        setDefaultCellContents()
        if let url = data.smallSizeURL {
            imageView.kf.setImage(with: url)
        }
    }
}
// MARK: - Private Methods
private extension FlickrListCell {
    func setupViews() {
        backgroundColor = .clear
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { snp in
            snp.edges.edges.equalToSuperview()
        }
    }

    func setDefaultCellContents() {
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
}
