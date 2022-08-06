//
//  PhotoDetailsController.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 8/6/22.
//

import UIKit
import RxSwift

class PhotoDetailsController: UIViewController, UICollectionViewDelegate {
    // MARK: Properties
    private var disposeBag = DisposeBag()
    private(set) var viewModel: PhotoDetailsViewModel
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // MARK: Life cycle methods
    init(viewModel: PhotoDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        binds()
    }
}

// MARK: Private methods
private extension PhotoDetailsController {
    func setupViews() {
        view.backgroundColor = .lightGray
        setupImageView()
    }

    func setupImageView() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { snp in
            snp.edges.equalToSuperview()
        }
    }
    
    func binds() {
        viewModel.imageURLBehavior.asObservable()
            .subscribe { [weak self] url in
                if let url = url.element ?? nil {
                    self?.imageView.kf.setImage(with: url)
                }
        }.disposed(by: disposeBag)
    }
}
