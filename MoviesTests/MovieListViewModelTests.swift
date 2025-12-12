//
//  MovieListViewModelTests.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import XCTest
@testable import Movies

@MainActor
final class MovieListViewModelTests: XCTestCase {
    var movieListViewModel: MovieListViewModel!
    var mockMovieRepository: MockMovieRepository!
    
    override func setUp() {
        super.setUp()
        mockMovieRepository = MockMovieRepository()
        movieListViewModel = MovieListViewModel(repository: mockMovieRepository)
    }
    
    override func tearDown() {
        movieListViewModel = nil
        mockMovieRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_hasEmptyMovies() {
        XCTAssertTrue(movieListViewModel.movies.isEmpty)
    }
    
    func test_initialState_isNotLoading() {
        XCTAssertFalse(movieListViewModel.isLoading)
    }
    
    func test_initialState_hasNoError() {
        XCTAssertNil(movieListViewModel.error)
    }
    
    func test_initialState_isNotShowingError() {
        XCTAssertFalse(movieListViewModel.isShowingError)
    }
    
    // MARK: - Load Movies Success Tests
    
    func test_loadMovies_success_updatesMovies() async {
        // Given
        let expectedMovies = Movie.mockArray(count: 3)
        mockMovieRepository.moviesResult = .success(expectedMovies)
        
        // When
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertEqual(movieListViewModel.movies.count, 3)
        XCTAssertEqual(movieListViewModel.movies.first?.title, "Movie 1")
    }
    
    func test_loadMovies_success_setsLoadingToFalse() async {
        // Given
        mockMovieRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertFalse(movieListViewModel.isLoading)
    }
    
    func test_loadMovies_success_clearsError() async {
        // Given
        mockMovieRepository.moviesResult = .success(Movie.mockArray())
        movieListViewModel.error = .noData
        
        // When
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertNil(movieListViewModel.error)
    }
    
    func test_loadMovies_success_callsRepositoryWithCorrectPage() async {
        // Given
        mockMovieRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertEqual(mockMovieRepository.lastRequestedPage, 1)
        XCTAssertEqual(mockMovieRepository.fetchMoviesCallCount, 1)
    }
    
    func test_loadMovies_multipleCalls_incrementsPage() async {
        // Given
        mockMovieRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await movieListViewModel.loadMovies()
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertEqual(mockMovieRepository.lastRequestedPage, 2)
    }
    
    func test_loadMovies_multipleCalls_appendsMovies() async {
        // Given
        mockMovieRepository.moviesResult = .success(Movie.mockArray(count: 2))
        
        // When
        await movieListViewModel.loadMovies()
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertEqual(movieListViewModel.movies.count, 4)
    }
    
    // MARK: - Load Movies Failure Tests
    
    func test_loadMovies_failure_setsError() async {
        // Given
        mockMovieRepository.moviesResult = .failure(.noData)
        
        // When
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertNotNil(movieListViewModel.error)
        XCTAssertEqual(movieListViewModel.error, .noData)
    }
    
    func test_loadMovies_failure_setsIsShowingError() async {
        // Given
        mockMovieRepository.moviesResult = .failure(.invalidURL)
        
        // When
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertTrue(movieListViewModel.isShowingError)
    }
    
    func test_loadMovies_failure_keepsMoviesEmpty() async {
        // Given
        mockMovieRepository.moviesResult = .failure(.noData)
        
        // When
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertTrue(movieListViewModel.movies.isEmpty)
    }
    
    func test_loadMovies_failure_setsLoadingToFalse() async {
        // Given
        mockMovieRepository.moviesResult = .failure(.noData)
        
        // When
        await movieListViewModel.loadMovies()
        
        // Then
        XCTAssertFalse(movieListViewModel.isLoading)
    }
    
    func test_loadMovies_networkError_setsCorrectError() async {
        // Given
        mockMovieRepository.moviesResult = .failure(.serverError(statusCode: 500))
        
        // When
        await movieListViewModel.loadMovies()
        
        // Then
        if case .serverError(let code) = movieListViewModel.error {
            XCTAssertEqual(code, 500)
        } else {
            XCTFail("Expected server error")
        }
    }
    
    // MARK: - Refresh Tests
    
    func test_refresh_resetsCurrentPage() async {
        // Given
        mockMovieRepository.moviesResult = .success(Movie.mockArray())
        await movieListViewModel.loadMovies() // Page becomes 2
        
        // When
        await movieListViewModel.refresh()
        
        // Then
        XCTAssertEqual(mockMovieRepository.lastRequestedPage, 1)
    }
    
    func test_refresh_clearsExistingMovies() async {
        // Given
        movieListViewModel.movies = Movie.mockArray(count: 5)
        mockMovieRepository.moviesResult = .success([])
        
        // When
        await movieListViewModel.refresh()
        
        // Then
        XCTAssertTrue(movieListViewModel.movies.isEmpty)
    }
    
    func test_refresh_loadsNewMovies() async {
        // Given
        let newMovies = Movie.mockArray(count: 3)
        mockMovieRepository.moviesResult = .success(newMovies)
        
        // When
        await movieListViewModel.refresh()
        
        // Then
        XCTAssertEqual(movieListViewModel.movies.count, 3)
    }
    
    func test_refresh_clearsError() async {
        // Given
        movieListViewModel.error = .noData
        mockMovieRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await movieListViewModel.refresh()
        
        // Then
        XCTAssertNil(movieListViewModel.error)
    }
    
    // MARK: - Load More Tests
    
    func test_loadMoreIfNeeded_withLastMovie_loadsMore() async {
        // Given
        let movies = Movie.mockArray(count: 3)
        movieListViewModel.movies = movies
        mockMovieRepository.moviesResult = .success(Movie.mockArray(count: 2))
        
        // When
        await movieListViewModel.loadMoreIfNeeded(currentMovie: movies.last!)
        
        // Then
        XCTAssertEqual(movieListViewModel.movies.count, 5)
    }
    
    func test_loadMoreIfNeeded_withMiddleMovie_doesNotLoad() async {
        // Given
        let movies = Movie.mockArray(count: 3)
        movieListViewModel.movies = movies
        mockMovieRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await movieListViewModel.loadMoreIfNeeded(currentMovie: movies[1])
        
        // Then
        XCTAssertEqual(movieListViewModel.movies.count, 3)
        XCTAssertEqual(mockMovieRepository.fetchMoviesCallCount, 0)
    }
    
    func test_loadMoreIfNeeded_whileLoading_doesNotLoadAgain() async {
        // Given
        let movies = Movie.mockArray(count: 3)
        movieListViewModel.movies = movies
        movieListViewModel.isLoading = true
        
        // When
        await movieListViewModel.loadMoreIfNeeded(currentMovie: movies.last!)
        
        // Then
        XCTAssertEqual(mockMovieRepository.fetchMoviesCallCount, 0)
    }
    
    func test_loadMoreIfNeeded_withEmptyMovies_doesNotLoad() async {
        // Given
        let movie = Movie.mock()
        
        // When
        await movieListViewModel.loadMoreIfNeeded(currentMovie: movie)
        
        // Then
        XCTAssertEqual(mockMovieRepository.fetchMoviesCallCount, 0)
    }
    
    // MARK: - Loading State Tests
    
    func test_loadMovies_setsLoadingToTrue_duringExecution() async {
        // Given
        mockMovieRepository.moviesResult = .success(Movie.mockArray())
        
        // When/Then
        let loadTask = Task {
            await movieListViewModel.loadMovies()
        }
        
        // Check loading state immediately
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        XCTAssertTrue(movieListViewModel.isLoading)
        
        await loadTask.value
        XCTAssertFalse(movieListViewModel.isLoading)
    }
    
    // MARK: - Error Message Tests
    
    func test_error_invalidURL_hasCorrectMessage() {
        // Given
        movieListViewModel.error = .invalidURL
        
        // Then
        XCTAssertEqual(movieListViewModel.error?.localizedDescription, "Invalid URL")
    }
    
    func test_error_noData_hasCorrectMessage() {
        // Given
        movieListViewModel.error = .noData
        
        // Then
        XCTAssertEqual(movieListViewModel.error?.localizedDescription, "No data received")
    }
}
