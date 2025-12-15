//
//  MovieDetailEntity.swift
//  Movies
//
//  Created by Gourav Mandliya on 15/12/25.
//

import Foundation

extension MovieDetailEntity {
    func toMovieDetail() -> MovieDetail {
        let genreNames = genres?.components(separatedBy: ", ") ?? []
        let genreObjects = genreNames.enumerated().map { index, name in
            MovieDetail.Genre(id: index, name: name)
        }
        
        return MovieDetail(
            id: Int(id),
            title: title ?? "",
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: Int(voteCount),
            runtime: runtime > 0 ? Int(runtime) : nil,
            genres: genreObjects,
            tagline: tagline
        )
    }
}
