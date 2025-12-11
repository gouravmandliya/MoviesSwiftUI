//
//  MovieListViewModel.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import Combine

@MainActor
final class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var isShowingError = false
    
    private let repository: MovieRepositoryProtocol
    private var currentPage = 1
    private var canLoadMore = true
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadMovies() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let newMovies = try await repository.fetchPopularMovies(page: currentPage)
            movies.append(contentsOf: newMovies)
            currentPage += 1
        } catch let networkError as NetworkError {
            error = networkError
            isShowingError = true
        } catch {
            self.error = .networkFailure(error)
            isShowingError = true
        }
        
        isLoading = false
    }
    
    func refresh() async {
        currentPage = 1
        movies.removeAll()
        canLoadMore = true
        await loadMovies()
    }
    
    func loadMoreIfNeeded(currentMovie: Movie) async {
        guard let lastMovie = movies.last,
              lastMovie.id == currentMovie.id,
              !isLoading,
              canLoadMore else {
            return
        }
        
        await loadMovies()
    }
    
    func makeDetailViewModel(movieId: Int) -> MovieDetailViewModel {
        MovieDetailViewModel(movieId: movieId, repository: repository)
    }
}
