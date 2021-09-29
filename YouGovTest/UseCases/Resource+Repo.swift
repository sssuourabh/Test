//
//  Resource+Repo.swift
//  YouGovTest
//
//  Created by Sourabh Singh on 29/09/21.
//

import Foundation

extension Resource {
    static func repos(query: String, userId: String = "sssuourabh") -> Resource<Repos> {
        let url = APIConstants.baseUrl.appendingPathComponent("/search/repositories")
        let parameters: [String : CustomStringConvertible] = [
            "q": query
        ]
        return Resource<Repos>(url: url, parameters: parameters)
    }
}
