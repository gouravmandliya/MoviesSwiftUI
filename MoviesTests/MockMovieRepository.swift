//
//  MockMovieRepository.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import Foundation
@testable import Movies

final class MockMovieRepository: MovieRepositoryProtocol {
    var moviesResult: Result<[Movie], NetworkError> = .success([])
    var detailResult: Result<MovieDetail, NetworkError> = .success(.mock())
    var fetchMoviesCallCount = 0
    var fetchDetailCallCount = 0
    var lastRequestedPage: Int?
    var lastRequestedMovieId: Int?
    
    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        fetchMoviesCallCount += 1
        lastRequestedPage = page
        
        // Simulate delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        return try moviesResult.get()
    }
    
    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        fetchDetailCallCount += 1
        lastRequestedMovieId = id
        
        // Simulate delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        return try detailResult.get()
    }
    
    func reset() {
        fetchMoviesCallCount = 0
        fetchDetailCallCount = 0
        lastRequestedPage = nil
        lastRequestedMovieId = nil
    }
}

// MARK: - Mock Data Extensions
extension Movie {
    static func mock(id: Int = 1, title: String = "Test Movie") -> Movie {
        Movie(
            id: id,
            title: title,
            overview: "Test overview for \(title)",
            posterPath: "/test.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2024-01-01",
            voteAverage: 7.5,
            voteCount: 1000
        )
    }
    
    static func mockArray(count: Int = 5) -> [Movie] {
        (1...count).map { Movie.mock(id: $0, title: "Movie \($0)") }
    }
}

extension MovieDetail {
    static func mock(id: Int = 1, runtime: Int? = 120, voteAverage: Double = 8.5) -> MovieDetail {
        MovieDetail(
            id: id,
            title: "Test Movie Detail",
            overview: "Detailed test overview",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2024-01-01",
            voteAverage: voteAverage,
            voteCount: 2000,
            runtime: runtime,
            genres: [
                Genre(id: 1, name: "Action"),
                Genre(id: 2, name: "Adventure")
            ],
            tagline: "Test tagline"
        )
    }
}
