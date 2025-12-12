//
//  NetworkManager.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import Foundation

protocol NetworkManaging {
    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class NetworkManager: NetworkManaging {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            #if DEBUG
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                
                print(json)
            } catch {
                print("errorMsg")
            }
            #endif
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkFailure(error)
        }
    }
}
