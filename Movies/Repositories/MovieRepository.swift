//
//  MovieRepository.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import Foundation

protocol MovieRepositoryProtocol {
    func fetchPopularMovies(page: Int) async throws -> [Movie]
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
}

final class MovieRepository: MovieRepositoryProtocol {
    private let networkManager: NetworkManaging
    private let persistenceManager: PersistenceManaging
    
    init(networkManager: NetworkManaging, persistenceManager: PersistenceManaging) {
        self.networkManager = networkManager
        self.persistenceManager = persistenceManager
    }
    
    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        do {
            let response: MovieResponse = try await networkManager.fetch(.popularMovies(page: page))
            try await persistenceManager.saveMovies(response.results)
            return response.results
        } catch {
            // Fallback to cached data
            return try await persistenceManager.fetchMovies()
        }
    }
    
    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        do {
            let detail: MovieDetail = try await networkManager.fetch(.movieDetail(id: id))
            try await persistenceManager.saveMovieDetail(detail)
            return detail
        } catch {
            // Fallback to cached data
            if let cached = try await persistenceManager.fetchMovieDetail(id: id) {
                return cached
            }
            throw error
        }
    }
}
