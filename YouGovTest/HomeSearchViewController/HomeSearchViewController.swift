//
//  HomeSearchViewController.swift
//  YouGovTest
//
//  Created by Sourabh Singh on 20/09/21.
//

import Foundation
import UIKit
import Combine
import Carbon
import Cartography

class HomeSearchViewController: UIViewController {
    
    public let dataclient: RepoClient
    // MARK: // Properties
    private var activityIndicator = UIActivityIndicatorView(style: .large)
    private let cellReuseIdentifier = "cell"

    private var reposArray = [Repo]()
    private lazy var dataSource = makeDataSource()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .tertiarySystemGroupedBackground
        return tableView
    }()
    
    private var cancellables: [AnyCancellable] = []
    
    
    // MARK: Initialization
    init(dataclient: RepoClient) {
        self.dataclient = dataclient
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Github Repos", comment: "Title string")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        Cartography.constrain(tableView, activityIndicator) {
            $0.edges == $0.superview!.edges
            $1.width == 100
            $1.height == 100
            $1.centerX == $1.superview!.centerX
            $1.centerY == $1.superview!.centerY
        }
    }
    
    override func viewDidLoad() {
        tableView.register(RepoCell.self,
                           forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.dataSource = dataSource
        
        dataclient.getRepos()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure: break
                case .finished:
                    self.update(with: self.reposArray)
                    //update tableview
                }
            }, receiveValue: { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let repositories):
                    self.reposArray.append(contentsOf: repositories.items)
                }
            })
            .store(in: &cancellables)
    }
}

fileprivate extension HomeSearchViewController {
    enum Section: CaseIterable {
        case main
    }
    func makeDataSource() -> UITableViewDiffableDataSource<Section, Repo> {
        let reuseIdentifier = cellReuseIdentifier

        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, movieViewModel in
//                cell.accessibilityIdentifier = "\(AccessibilityIdentifiers.MoviesSearch.cellId).\(indexPath.row)"
//                cell.bind(to: movieViewModel)
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: indexPath
                ) as! RepoCell
                let repo = self.reposArray[indexPath.row]
                
                ImageLoaderService().loadImage(from: URL(string: repo.owner.avatarUrl)!)
                    .sink { image in
                        DispatchQueue.main.async {
                            cell.repoOwnerImage.image = image
                        }
                    }.store(in: &self.cancellables)
                cell.nameLabel.text = repo.fullName
                cell.descriptionLabel.text = repo.description
                cell.forkedCountLabel.text = "Forked Count = \(repo.forks)"
                cell.watchersLabel.text = "Watchers = \(repo.watchers)"
                cell.openIssuesCountLabel.text = "Open issues count = \(repo.openIssues)"
                return cell
            }
        )
    }
    
    func update(with repo: [Repo], animate: Bool = true) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, Repo>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(repo, toSection: .main)
            self.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }

}

//extension HomeSearchViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let snapshot = dataSource.snapshot()
//        selection.send(snapshot.itemIdentifiers[indexPath.row].id)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        searchController.searchBar.resignFirstResponder()
//    }
//}
