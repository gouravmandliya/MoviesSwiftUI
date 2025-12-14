//
//  MovieDetailViewModelTests.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import XCTest
@testable import Movies

@MainActor
final class MovieDetailViewModelTests: XCTestCase {
    var movieDetailViewModel: MovieDetailViewModel!
    var mockMovieRepository: MockMovieRepository!
    let testMovieId = 123
    
    override func setUp() {
        super.setUp()
        mockMovieRepository = MockMovieRepository()
        movieDetailViewModel = MovieDetailViewModel(movieId: testMovieId, repository: mockMovieRepository)
    }
    
    override func tearDown() {
        movieDetailViewModel = nil
        mockMovieRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_hasNoMovieDetail() {
        XCTAssertNil(movieDetailViewModel.movieDetail)
    }
    
    func test_initialState_isNotLoading() {
        XCTAssertFalse(movieDetailViewModel.isLoading)
    }
    
    func test_initialState_hasNoError() {
        XCTAssertNil(movieDetailViewModel.error)
    }
    
    func test_initialState_isNotShowingError() {
        XCTAssertFalse(movieDetailViewModel.isShowingError)
    }
    
    // MARK: - Load Movie Detail Success Tests
    
    func test_loadMovieDetail_success_updatesMovieDetail() async {
        // Given
        let expectedDetail = MovieDetail.mock(id: testMovieId)
        mockMovieRepository.detailResult = .success(expectedDetail)
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertNotNil(movieDetailViewModel.movieDetail)
        XCTAssertEqual(movieDetailViewModel.movieDetail?.id, testMovieId)
        XCTAssertEqual(movieDetailViewModel.movieDetail?.title, "Test Movie Detail")
    }
    
    func test_loadMovieDetail_success_setsLoadingToFalse() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock())
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertFalse(movieDetailViewModel.isLoading)
    }
    
    func test_loadMovieDetail_success_clearsError() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock())
        movieDetailViewModel.error = .noData
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertNil(movieDetailViewModel.error)
    }
    
    func test_loadMovieDetail_success_callsRepositoryWithCorrectId() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock())
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertEqual(mockMovieRepository.lastRequestedMovieId, testMovieId)
        XCTAssertEqual(mockMovieRepository.fetchDetailCallCount, 1)
    }
    
    func test_loadMovieDetail_success_hasCorrectGenres() async {
        // Given
        let detail = MovieDetail.mock()
        mockMovieRepository.detailResult = .success(detail)
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertEqual(movieDetailViewModel.movieDetail?.genres.count, 2)
        XCTAssertEqual(movieDetailViewModel.movieDetail?.genres.first?.name, "Action")
    }
    
    func test_loadMovieDetail_success_hasCorrectRuntime() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock())
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertEqual(movieDetailViewModel.movieDetail?.runtime, 120)
        XCTAssertEqual(movieDetailViewModel.movieDetail?.formattedRuntime, "2h 0m")
    }
    
    // MARK: - Load Movie Detail Failure Tests
    
    func test_loadMovieDetail_failure_setsError() async {
        // Given
        mockMovieRepository.detailResult = .failure(.noData)
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertNotNil(movieDetailViewModel.error)
        XCTAssertEqual(movieDetailViewModel.error, .noData)
    }
    
    func test_loadMovieDetail_failure_setsIsShowingError() async {
        // Given
        mockMovieRepository.detailResult = .failure(.invalidURL)
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertTrue(movieDetailViewModel.isShowingError)
    }
    
    func test_loadMovieDetail_failure_keepsMovieDetailNil() async {
        // Given
        mockMovieRepository.detailResult = .failure(.noData)
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertNil(movieDetailViewModel.movieDetail)
    }
    
    func test_loadMovieDetail_failure_setsLoadingToFalse() async {
        // Given
        mockMovieRepository.detailResult = .failure(.noData)
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertFalse(movieDetailViewModel.isLoading)
    }
    
    func test_loadMovieDetail_serverError_setsCorrectError() async {
        // Given
        mockMovieRepository.detailResult = .failure(.serverError(statusCode: 404))
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        if case .serverError(let code) = movieDetailViewModel.error {
            XCTAssertEqual(code, 404)
        } else {
            XCTFail("Expected server error")
        }
    }
    
    // MARK: - Loading State Tests
    
    func test_loadMovieDetail_setsLoadingToTrue_duringExecution() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock())
        
        // When/Then
        let loadTask = Task {
            await movieDetailViewModel.loadMovieDetail()
        }
        
        // Check loading state immediately
        try? await Task.sleep(nanoseconds: 10_000_000)
        XCTAssertTrue(movieDetailViewModel.isLoading)
        
        await loadTask.value
        XCTAssertFalse(movieDetailViewModel.isLoading)
    }
    
    // MARK: - Multiple Load Tests
    
    func test_loadMovieDetail_multipleCalls_overwritesPreviousDetail() async {
        // Given
        let detail1 = MovieDetail.mock(id: 1)
        let detail2 = MovieDetail.mock(id: 2)
        
        mockMovieRepository.detailResult = .success(detail1)
        await movieDetailViewModel.loadMovieDetail()
        
        mockMovieRepository.detailResult = .success(detail2)
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertEqual(movieDetailViewModel.movieDetail?.id, 2)
    }
    
    func test_loadMovieDetail_afterError_canSucceed() async {
        // Given
        mockMovieRepository.detailResult = .failure(.noData)
        await movieDetailViewModel.loadMovieDetail()
        XCTAssertNotNil(movieDetailViewModel.error)
        
        mockMovieRepository.detailResult = .success(MovieDetail.mock())
        
        // When
        await movieDetailViewModel.loadMovieDetail()
        
        // Then
        XCTAssertNotNil(movieDetailViewModel.movieDetail)
        XCTAssertNil(movieDetailViewModel.error)
    }
    
    // MARK: - Error Mapping & Edge Cases
    func test_loadMovieDetail_failure_invalidURL_setsInvalidURLError() async {
        // Given
        mockMovieRepository.detailResult = .failure(.invalidURL)

        // When
        await movieDetailViewModel.loadMovieDetail()

        // Then
        XCTAssertEqual(movieDetailViewModel.error, .invalidURL)
        XCTAssertTrue(movieDetailViewModel.isShowingError)
        XCTAssertNil(movieDetailViewModel.movieDetail)
    }

    func test_loadMovieDetail_failure_serverErrorRange_variousCodes() async {
        // Given
        let codes = [400, 401, 403, 404, 500, 503]
        for code in codes {
            mockMovieRepository.detailResult = .failure(.serverError(statusCode: code))

            // When
            await movieDetailViewModel.loadMovieDetail()

            // Then
            if case .serverError(let status) = movieDetailViewModel.error {
                XCTAssertEqual(status, code)
            } else {
                XCTFail("Expected serverError for code: \(code)")
            }
            XCTAssertTrue(movieDetailViewModel.isShowingError)
            XCTAssertNil(movieDetailViewModel.movieDetail)
        }
    }

    // MARK: - Additional Success State Tests
    func test_loadMovieDetail_success_setsIsShowingErrorFalse() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock())

        // When
        await movieDetailViewModel.loadMovieDetail()

        // Then
        XCTAssertFalse(movieDetailViewModel.isShowingError)
        XCTAssertNil(movieDetailViewModel.error)
    }

    func test_loadMovieDetail_multipleSequentialCalls_callsRepositoryTwice() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock())

        // When
        await movieDetailViewModel.loadMovieDetail()
        mockMovieRepository.detailResult = .success(MovieDetail.mock(id: 999))
        await movieDetailViewModel.loadMovieDetail()

        // Then
        XCTAssertEqual(mockMovieRepository.fetchDetailCallCount, 2)
        XCTAssertEqual(mockMovieRepository.lastRequestedMovieId, testMovieId)
    }

    // MARK: - Formatting Edge Cases
    func test_loadMovieDetail_formattedRating_handlesMixedRating() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock(voteAverage: 8.5))

        // When
        await movieDetailViewModel.loadMovieDetail()

        // Then
        XCTAssertEqual(movieDetailViewModel.movieDetail?.formattedRating, "8.5")
    }
    
    func test_loadMovieDetail_runtimeFormatting_handlesMixedMinutes() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock(runtime: 125))

        // When
        await movieDetailViewModel.loadMovieDetail()

        // Then
        XCTAssertEqual(movieDetailViewModel.movieDetail?.formattedRuntime, "2h 5m")
    }
    
    func test_loadMovieDetail_runtimeFormatting_handlesMixedMinutesNil() async {
        // Given
        mockMovieRepository.detailResult = .success(MovieDetail.mock(runtime: nil))

        // When
        await movieDetailViewModel.loadMovieDetail()

        // Then
        XCTAssertEqual(movieDetailViewModel.movieDetail?.formattedRuntime, nil)
    }
    
    func test_loadMovieDetail_runtimeFormatting_handlebackdropUrl() async {
        // Given
        let mock = MovieDetail.mock()
        let backdropURL = TMDBConfig.Image.url(path: mock.backdropPath, size: TMDBConfig.Image.backdropSize)
        mockMovieRepository.detailResult = .success(mock)

        // When
        await movieDetailViewModel.loadMovieDetail()

        // Then
        XCTAssertEqual(movieDetailViewModel.movieDetail?.backdropURL, backdropURL)
    }
}
