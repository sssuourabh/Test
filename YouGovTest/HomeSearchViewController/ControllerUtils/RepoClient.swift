//
//  RepoClient.swift
//  YouGovTest
//
//  Created by Sourabh Singh on 29/09/21.
//

import Foundation
import Combine

protocol RepoClient {
    func getRepos() -> AnyPublisher<Result<Repos, Error>, Never>
}

final class RepoClientImpl: RepoClient {

    private let networkService: NetworkServiceType

    init(networkService: NetworkServiceType) {
        self.networkService = networkService
    }

    func getRepos() -> AnyPublisher<Result<Repos, Error>, Never> {
        return networkService
            .load(Resource<Repos>.repos(query: "swift"))
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<Repos, Error>, Never> in .just(.failure(error)) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

}
