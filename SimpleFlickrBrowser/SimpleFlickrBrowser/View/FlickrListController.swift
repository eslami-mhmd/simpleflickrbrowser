//
//  FlickrListController.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 7/31/22.
//

import UIKit
import RxSwift

class FlickrListController: UIViewController, UICollectionViewDelegate {
    // MARK: Properties
    private var disposeBag = DisposeBag()
    private let cellOffset: Double = 5
    private let horizontalOffset: Double = 10
    private let verticalOffset: Double = 10
    private var viewModel: FlickrListViewModel
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var newFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 120, height: 120)
        layout.minimumLineSpacing = cellOffset
        layout.minimumInteritemSpacing = cellOffset
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
        binds()
    }
}

// MARK: Private methods
private extension FlickrListController {
    func setupViews() {
        navigationItem.title = "FlickrListController.title".localized
        view.backgroundColor = .lightGray

        setupSearchController()
        setupCollectionView()
    }

    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "FlickrListController.Search".localized
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { snp in
            snp.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(verticalOffset)
            snp.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-verticalOffset)
            snp.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(horizontalOffset)
            snp.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-horizontalOffset)
        }
    }

    func binds() {
        bindFetchingState()
        bindErrors()
        bindCollectionView()
    }
    
    func bindFetchingState() {
        viewModel.isFetchingBehavior.asObservable()
            .subscribe { isFetching in
                print(isFetching)
                // TODO: - show activity indicator
        }.disposed(by: disposeBag)
    }
    
    func bindErrors() {
        viewModel.error.subscribe(onNext: { error in
            print(error)
            // TODO: - show error in a proper UI like toast
        }).disposed(by: disposeBag)
    }
    
    func bindCollectionView() {
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.flickrPhotosBehavior.asObservable()
            .bind(to: collectionView.rx
                    .items(cellIdentifier: FlickrListCell.reuseIdentifier,
                           cellType: FlickrListCell.self))
        { [weak self] index, element, cell in
            cell.setData(data: element)
            if self?.shouldGetNextPage(for: index) == true {
                self?.viewModel.getNextPage()
            }
        }
        .disposed(by: disposeBag)
        
        collectionView
            .rx
            .itemSelected
                .subscribe(onNext:{ indexPath in
                    print("\(indexPath) tapped")
                }).disposed(by: disposeBag)
    }
    
    func shouldGetNextPage(for index: Int) -> Bool {
        let offset = 10
        let count = viewModel.flickrPhotosBehavior.value.count
        return count > 0 && index >= count - offset
    }
}

// MARK: UISearchResultsUpdating
extension FlickrListController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
      if let searchText = searchController.searchBar.text, !searchText.isEmpty {
          viewModel.updateSearchValue(value: searchText)
      }
  }
}
