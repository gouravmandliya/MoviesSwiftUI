//
//  Movie.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import Foundation

struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    
    var posterURL: URL? {
        TMDBConfig.Image.url(path: posterPath, size: TMDBConfig.Image.posterSize)
    }
    
    var backdropURL: URL? {
        TMDBConfig.Image.url(path: backdropPath, size: TMDBConfig.Image.backdropSize)
    }
    
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    var formattedReleaseYear: String? {
        guard let date = releaseDate else { return nil }
        return String(date.prefix(4))
    }
}
