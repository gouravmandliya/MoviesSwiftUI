//
//  MovieDetail.swift
//  Movies
//
//  Created by Gourav Mandliya on 13/12/25.
//

import Foundation

struct MovieDetail: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [Genre]
    let tagline: String?
    
    struct Genre: Codable, Identifiable {
        let id: Int
        let name: String
    }
    
    var formattedRating: String {
        return String(format: "%.1f", voteAverage)
    }
    
    var formattedRuntime: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)h \(minutes)m"
    }
    
    var backdropURL: URL? {
        TMDBConfig.Image.url(path: backdropPath, size: TMDBConfig.Image.backdropSize)
    }
}
