//
//  NetworkError.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int)
    case networkFailure(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkFailure(let error):
            return "Network failure: \(error.localizedDescription)"
        }
    }
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.noData, .noData):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.decodingError, .decodingError):
            return true
        case (.networkFailure, .networkFailure):
            return true
        default:
            return false
        }
    }
}

