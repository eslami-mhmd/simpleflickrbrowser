//
//  FlickrListController.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 7/31/22.
//

import Combine
import UIKit
import RxSwift

class DirectionSupportedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
}

class FlickrListController: UIViewController, UICollectionViewDelegate {
    // MARK: Properties
    private var disposeBag = DisposeBag()
    private lazy var cellWidth: Double = 80
    private let offset: Double = 15
    var viewModel: FlickrListViewModel

    let searchController = UISearchController(searchResultsController: nil)
    private lazy var newFlowLayout: DirectionSupportedCollectionViewFlowLayout = {
        let layout = DirectionSupportedCollectionViewFlowLayout()
        layout.itemSize = .init(width: cellWidth, height: cellWidth)
        layout.minimumLineSpacing = offset
        layout.minimumInteritemSpacing = offset
        return layout
    }()
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.newFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(FlickrListCell.self, forCellWithReuseIdentifier: FlickrListCell.reuseIdentifier)
        return collectionView
    }()
    // MARK: Life cycle methods
    init(viewModel: FlickrListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind()
        viewModel.mockPhotos()
    }
}

// MARK: Private methods
private extension FlickrListController {
    func setupViews() {
        setupSearchController()
        navigationItem.title = "FlickrListController.title".localized
        view.backgroundColor = .lightGray

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { snp in
            snp.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            snp.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            snp.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            snp.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
    }

    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "FlickrListController.Search".localized
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    func bind() {
        viewModel.error.subscribe(onNext: { error in
            print(error)
        }).disposed(by: disposeBag)
        
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.flickrItemsBehavior.asObservable()
            .bind(to: collectionView.rx
                    .items(cellIdentifier: FlickrListCell.reuseIdentifier,
                           cellType: FlickrListCell.self))
        { index, element, cell in
            cell.setData(data: element)
        }
        .disposed(by: disposeBag)
        
        collectionView
            .rx
            .itemSelected
                .subscribe(onNext:{ [weak self] indexPath in
                    print("\(indexPath) tapped")
                    if let item = self?.viewModel.flickrItemsBehavior.value[safe: indexPath.item] {
                    }
                }).disposed(by: disposeBag)

    }
}

// MARK: UISearchResultsUpdating
extension FlickrListController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
      viewModel.updateSearchValue(value: searchController.searchBar.text)
  }
}

