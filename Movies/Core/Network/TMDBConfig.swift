//
//  TMDBConfig.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import Foundation

enum TMDBConfig {

    // API configuration values used to build network requests.
    enum API {
        // Base URL for the TMDB v3 API.
        static let baseURL = "https://api.themoviedb.org/3"
        // API key for authenticating requests.
        static let apiKey = "019cdd171a3212b0a80c3de340f2587a"
    }

    // Image configuration and helpers for constructing TMDB image URLs.
    enum Image {
        static let baseURL = "https://image.tmdb.org/t/p/"
        static let posterSize = "w500"
        static let backdropSize = "original"

        static func url(path: String?, size: String) -> URL? {
            guard let path, !path.isEmpty else { return nil }
            return URL(string: baseURL + size + path)
        }
    }
}
