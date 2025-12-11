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
    var sut: MovieListViewModel!
    var mockRepository: MockMovieRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        sut = MovieListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_hasEmptyMovies() {
        XCTAssertTrue(sut.movies.isEmpty)
    }
    
    func test_initialState_isNotLoading() {
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_initialState_hasNoError() {
        XCTAssertNil(sut.error)
    }
    
    func test_initialState_isNotShowingError() {
        XCTAssertFalse(sut.isShowingError)
    }
    
    // MARK: - Load Movies Success Tests
    
    func test_loadMovies_success_updatesMovies() async {
        // Given
        let expectedMovies = Movie.mockArray(count: 3)
        mockRepository.moviesResult = .success(expectedMovies)
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertEqual(sut.movies.count, 3)
        XCTAssertEqual(sut.movies.first?.title, "Movie 1")
    }
    
    func test_loadMovies_success_setsLoadingToFalse() async {
        // Given
        mockRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_loadMovies_success_clearsError() async {
        // Given
        mockRepository.moviesResult = .success(Movie.mockArray())
        sut.error = .noData
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertNil(sut.error)
    }
    
    func test_loadMovies_success_callsRepositoryWithCorrectPage() async {
        // Given
        mockRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertEqual(mockRepository.lastRequestedPage, 1)
        XCTAssertEqual(mockRepository.fetchMoviesCallCount, 1)
    }
    
    func test_loadMovies_multipleCalls_incrementsPage() async {
        // Given
        mockRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await sut.loadMovies()
        await sut.loadMovies()
        
        // Then
        XCTAssertEqual(mockRepository.lastRequestedPage, 2)
    }
    
    func test_loadMovies_multipleCalls_appendsMovies() async {
        // Given
        mockRepository.moviesResult = .success(Movie.mockArray(count: 2))
        
        // When
        await sut.loadMovies()
        await sut.loadMovies()
        
        // Then
        XCTAssertEqual(sut.movies.count, 4)
    }
    
    // MARK: - Load Movies Failure Tests
    
    func test_loadMovies_failure_setsError() async {
        // Given
        mockRepository.moviesResult = .failure(.noData)
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error, .noData)
    }
    
    func test_loadMovies_failure_setsIsShowingError() async {
        // Given
        mockRepository.moviesResult = .failure(.invalidURL)
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertTrue(sut.isShowingError)
    }
    
    func test_loadMovies_failure_keepsMoviesEmpty() async {
        // Given
        mockRepository.moviesResult = .failure(.noData)
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertTrue(sut.movies.isEmpty)
    }
    
    func test_loadMovies_failure_setsLoadingToFalse() async {
        // Given
        mockRepository.moviesResult = .failure(.noData)
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_loadMovies_networkError_setsCorrectError() async {
        // Given
        mockRepository.moviesResult = .failure(.serverError(statusCode: 500))
        
        // When
        await sut.loadMovies()
        
        // Then
        if case .serverError(let code) = sut.error {
            XCTAssertEqual(code, 500)
        } else {
            XCTFail("Expected server error")
        }
    }
    
    // MARK: - Refresh Tests
    
    func test_refresh_resetsCurrentPage() async {
        // Given
        mockRepository.moviesResult = .success(Movie.mockArray())
        await sut.loadMovies() // Page becomes 2
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertEqual(mockRepository.lastRequestedPage, 1)
    }
    
    func test_refresh_clearsExistingMovies() async {
        // Given
        sut.movies = Movie.mockArray(count: 5)
        mockRepository.moviesResult = .success([])
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertTrue(sut.movies.isEmpty)
    }
    
    func test_refresh_loadsNewMovies() async {
        // Given
        let newMovies = Movie.mockArray(count: 3)
        mockRepository.moviesResult = .success(newMovies)
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertEqual(sut.movies.count, 3)
    }
    
    func test_refresh_clearsError() async {
        // Given
        sut.error = .noData
        mockRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await sut.refresh()
        
        // Then
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Load More Tests
    
    func test_loadMoreIfNeeded_withLastMovie_loadsMore() async {
        // Given
        let movies = Movie.mockArray(count: 3)
        sut.movies = movies
        mockRepository.moviesResult = .success(Movie.mockArray(count: 2))
        
        // When
        await sut.loadMoreIfNeeded(currentMovie: movies.last!)
        
        // Then
        XCTAssertEqual(sut.movies.count, 5)
    }
    
    func test_loadMoreIfNeeded_withMiddleMovie_doesNotLoad() async {
        // Given
        let movies = Movie.mockArray(count: 3)
        sut.movies = movies
        mockRepository.moviesResult = .success(Movie.mockArray())
        
        // When
        await sut.loadMoreIfNeeded(currentMovie: movies[1])
        
        // Then
        XCTAssertEqual(sut.movies.count, 3)
        XCTAssertEqual(mockRepository.fetchMoviesCallCount, 0)
    }
    
    func test_loadMoreIfNeeded_whileLoading_doesNotLoadAgain() async {
        // Given
        let movies = Movie.mockArray(count: 3)
        sut.movies = movies
        sut.isLoading = true
        
        // When
        await sut.loadMoreIfNeeded(currentMovie: movies.last!)
        
        // Then
        XCTAssertEqual(mockRepository.fetchMoviesCallCount, 0)
    }
    
    func test_loadMoreIfNeeded_withEmptyMovies_doesNotLoad() async {
        // Given
        let movie = Movie.mock()
        
        // When
        await sut.loadMoreIfNeeded(currentMovie: movie)
        
        // Then
        XCTAssertEqual(mockRepository.fetchMoviesCallCount, 0)
    }
    
    // MARK: - Loading State Tests
    
    func test_loadMovies_setsLoadingToTrue_duringExecution() async {
        // Given
        mockRepository.moviesResult = .success(Movie.mockArray())
        
        // When/Then
        let loadTask = Task {
            await sut.loadMovies()
        }
        
        // Check loading state immediately
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        XCTAssertTrue(sut.isLoading)
        
        await loadTask.value
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Error Message Tests
    
    func test_error_invalidURL_hasCorrectMessage() {
        // Given
        sut.error = .invalidURL
        
        // Then
        XCTAssertEqual(sut.error?.localizedDescription, "Invalid URL")
    }
    
    func test_error_noData_hasCorrectMessage() {
        // Given
        sut.error = .noData
        
        // Then
        XCTAssertEqual(sut.error?.localizedDescription, "No data received")
    }
}
