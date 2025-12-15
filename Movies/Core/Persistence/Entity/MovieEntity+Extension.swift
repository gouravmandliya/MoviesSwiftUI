//
//  MovieEntity+Extension.swift
//  Movies
//
//  Created by Gourav Mandliya on 15/12/25.
//

import Foundation

// Core Data Model Extensions
extension MovieEntity {
    func toMovie() -> Movie {
        Movie(
            id: Int(id),
            title: title ?? "",
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: Int(voteCount)
        )
    }
}
