//
//  MovieDetailViewModel.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published var movieDetail: MovieDetail?
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var isShowingError = false
    
    private let movieId: Int
    private let repository: MovieRepositoryProtocol
    
    init(movieId: Int, repository: MovieRepositoryProtocol) {
        self.movieId = movieId
        self.repository = repository
    }
    
    func loadMovieDetail() async {
        isLoading = true
        error = nil
        
        do {
            movieDetail = try await repository.fetchMovieDetail(id: movieId)
        } catch let networkError as NetworkError {
            error = networkError
            isShowingError = true
        } catch {
            self.error = .networkFailure(error)
            isShowingError = true
        }
        
        isLoading = false
    }
}
