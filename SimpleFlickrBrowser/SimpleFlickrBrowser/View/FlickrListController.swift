//
//  FlickrListController.swift
//  SimpleFlickrBrowser
//
//  Created by Mohammad Eslami on 7/31/22.
//

import UIKit
import RxSwift
import SnapKit

class FlickrListController: UIViewController, UICollectionViewDelegate {
    // MARK: Properties
    private var disposeBag = DisposeBag()
    private let cellOffset: Double = 5
    private let cellSize: Double = 120
    private let horizontalOffset: Double = 10
    private let verticalOffset: Double = 10
    private var viewModel: FlickrListViewModel
    private let searchController = UISearchController(searchResultsController: nil)
    private let photoDetailsVC = PhotoDetailsController(viewModel: PhotoDetailsViewModel())
    private var smallFrame: CGRect?
    private var bigFrame: CGRect?
    private var photoDetailsViewWidthConstraint: Constraint?
    private var photoDetailsViewHeightConstraint: Constraint?
    private var photoDetailsViewTopConstraint: Constraint?
    private var photoDetailsViewLeadingConstraint: Constraint?
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoDetailsViewTapped))


    private lazy var newFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: cellSize, height: cellSize)
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
        setupPhotoDetailsView()
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
    
    func setupPhotoDetailsView() {
        addChild(photoDetailsVC)
        view.addSubview(photoDetailsVC.view)
        photoDetailsVC.view.isHidden = true
        photoDetailsVC.view.snp.makeConstraints { snp in
            photoDetailsViewWidthConstraint = snp.width.equalTo(cellSize).constraint
            photoDetailsViewHeightConstraint = snp.height.equalTo(cellSize).constraint
            photoDetailsViewTopConstraint = snp.top.equalToSuperview().constraint
            photoDetailsViewLeadingConstraint = snp.leading.equalToSuperview().constraint
        }
        photoDetailsVC.view.addGestureRecognizer(tapGestureRecognizer)
        bigFrame = view.frame
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
                .subscribe(onNext:{ [weak self] indexPath in
                    print("\(indexPath) tapped")
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.photoDetailsVC.view.isHidden = false
                    strongSelf.photoDetailsVC.viewModel.setData(imageURL: strongSelf.viewModel.flickrPhotosBehavior.value[indexPath.item].smallSizeURL)
                    
                    guard let cell = strongSelf.collectionView.cellForItem(at: indexPath) else { return
                    }
                    strongSelf.smallFrame = strongSelf.collectionView.convert(cell.frame, to: strongSelf.view)
                    guard let smallFrame = strongSelf.smallFrame else {
                        return
                    }
                    strongSelf.updatePhotoDetailsConstraints(frame: smallFrame)
                    strongSelf.view.layoutIfNeeded()

                    strongSelf.collectionView.isUserInteractionEnabled = false
                    UIView.animate(withDuration: 0.5, animations: { [weak self] in
                        guard let frame = self?.bigFrame else {
                            return
                        }
                        strongSelf.navigationController?.setNavigationBarHidden(true, animated: true)
                        strongSelf.updatePhotoDetailsConstraints(frame: frame)
                        strongSelf.view.layoutIfNeeded()
                    })
                }).disposed(by: disposeBag)
    }
    
    func shouldGetNextPage(for index: Int) -> Bool {
        let offset = 10
        let count = viewModel.flickrPhotosBehavior.value.count
        return count > 0 && index >= count - offset
    }
    
    @objc private func photoDetailsViewTapped() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let smallFrame = self?.smallFrame else { return }
            self?.updatePhotoDetailsConstraints(frame: smallFrame)
            self?.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.photoDetailsVC.view.isHidden = true
            self?.collectionView.isUserInteractionEnabled = true
        }
    }
    
    func updatePhotoDetailsConstraints(frame: CGRect) {
        photoDetailsViewTopConstraint?.update(offset: frame.origin.y)
        photoDetailsViewLeadingConstraint?.update(offset: frame.origin.x)
        photoDetailsViewWidthConstraint?.update(offset: frame.width)
        photoDetailsViewHeightConstraint?.update(offset: frame.height)
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
