//
//  AppContainer.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import Foundation

final class AppContainer {
    private let networkManager: NetworkManaging
    private let persistenceManager: PersistenceManaging
    private let movieRepository: MovieRepositoryProtocol
    
    init() {
        self.networkManager = NetworkManager()
        self.persistenceManager = PersistenceManager()
        self.movieRepository = MovieRepository(networkManager: networkManager, persistenceManager: persistenceManager)
    }
    
    func makeMovieListViewModel() -> MovieListViewModel {
        MovieListViewModel(repository: movieRepository)
    }
    
    func makeMovieDetailViewModel(movieId: Int) -> MovieDetailViewModel {
        MovieDetailViewModel(movieId: movieId, repository: movieRepository)
    }
}
