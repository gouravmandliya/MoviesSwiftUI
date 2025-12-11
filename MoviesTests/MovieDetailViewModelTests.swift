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
    var sut: MovieDetailViewModel!
    var mockRepository: MockMovieRepository!
    let testMovieId = 123
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        sut = MovieDetailViewModel(movieId: testMovieId, repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_hasNoMovieDetail() {
        XCTAssertNil(sut.movieDetail)
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
    
    // MARK: - Load Movie Detail Success Tests
    
    func test_loadMovieDetail_success_updatesMovieDetail() async {
        // Given
        let expectedDetail = MovieDetail.mock(id: testMovieId)
        mockRepository.detailResult = .success(expectedDetail)
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertNotNil(sut.movieDetail)
        XCTAssertEqual(sut.movieDetail?.id, testMovieId)
        XCTAssertEqual(sut.movieDetail?.title, "Test Movie Detail")
    }
    
    func test_loadMovieDetail_success_setsLoadingToFalse() async {
        // Given
        mockRepository.detailResult = .success(MovieDetail.mock())
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_loadMovieDetail_success_clearsError() async {
        // Given
        mockRepository.detailResult = .success(MovieDetail.mock())
        sut.error = .noData
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertNil(sut.error)
    }
    
    func test_loadMovieDetail_success_callsRepositoryWithCorrectId() async {
        // Given
        mockRepository.detailResult = .success(MovieDetail.mock())
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertEqual(mockRepository.lastRequestedMovieId, testMovieId)
        XCTAssertEqual(mockRepository.fetchDetailCallCount, 1)
    }
    
    func test_loadMovieDetail_success_hasCorrectGenres() async {
        // Given
        let detail = MovieDetail.mock()
        mockRepository.detailResult = .success(detail)
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertEqual(sut.movieDetail?.genres.count, 2)
        XCTAssertEqual(sut.movieDetail?.genres.first?.name, "Action")
    }
    
    func test_loadMovieDetail_success_hasCorrectRuntime() async {
        // Given
        mockRepository.detailResult = .success(MovieDetail.mock())
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertEqual(sut.movieDetail?.runtime, 120)
        XCTAssertEqual(sut.movieDetail?.formattedRuntime, "2h 0m")
    }
    
    // MARK: - Load Movie Detail Failure Tests
    
    func test_loadMovieDetail_failure_setsError() async {
        // Given
        mockRepository.detailResult = .failure(.noData)
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error, .noData)
    }
    
    func test_loadMovieDetail_failure_setsIsShowingError() async {
        // Given
        mockRepository.detailResult = .failure(.invalidURL)
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertTrue(sut.isShowingError)
    }
    
    func test_loadMovieDetail_failure_keepsMovieDetailNil() async {
        // Given
        mockRepository.detailResult = .failure(.noData)
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertNil(sut.movieDetail)
    }
    
    func test_loadMovieDetail_failure_setsLoadingToFalse() async {
        // Given
        mockRepository.detailResult = .failure(.noData)
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_loadMovieDetail_serverError_setsCorrectError() async {
        // Given
        mockRepository.detailResult = .failure(.serverError(statusCode: 404))
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        if case .serverError(let code) = sut.error {
            XCTAssertEqual(code, 404)
        } else {
            XCTFail("Expected server error")
        }
    }
    
    // MARK: - Loading State Tests
    
    func test_loadMovieDetail_setsLoadingToTrue_duringExecution() async {
        // Given
        mockRepository.detailResult = .success(MovieDetail.mock())
        
        // When/Then
        let loadTask = Task {
            await sut.loadMovieDetail()
        }
        
        // Check loading state immediately
        try? await Task.sleep(nanoseconds: 10_000_000)
        XCTAssertTrue(sut.isLoading)
        
        await loadTask.value
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Multiple Load Tests
    
    func test_loadMovieDetail_multipleCalls_overwritesPreviousDetail() async {
        // Given
        let detail1 = MovieDetail.mock(id: 1)
        let detail2 = MovieDetail.mock(id: 2)
        
        mockRepository.detailResult = .success(detail1)
        await sut.loadMovieDetail()
        
        mockRepository.detailResult = .success(detail2)
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertEqual(sut.movieDetail?.id, 2)
    }
    
    func test_loadMovieDetail_afterError_canSucceed() async {
        // Given
        mockRepository.detailResult = .failure(.noData)
        await sut.loadMovieDetail()
        XCTAssertNotNil(sut.error)
        
        mockRepository.detailResult = .success(MovieDetail.mock())
        
        // When
        await sut.loadMovieDetail()
        
        // Then
        XCTAssertNotNil(sut.movieDetail)
        XCTAssertNil(sut.error)
    }
}
