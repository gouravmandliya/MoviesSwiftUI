//
//  MovieResponse.swift
//  Movies
//
//  Created by Gourav Mandliya on 15/12/25.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}
