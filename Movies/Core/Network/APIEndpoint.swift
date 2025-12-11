//
//  APIEndpoint.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import Foundation

enum APIEndpoint {
    case popularMovies(page: Int)
    case movieDetail(id: Int)
    
    private var baseURL: String {
        "https://api.themoviedb.org/3"
    }
    
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
    
    private var path: String {
        switch self {
        case .popularMovies:
            return "/movie/popular"
        case .movieDetail(let id):
            return "/movie/\(id)"
        }
    }
    
    private var queryItems: [URLQueryItem] {
        var items = [URLQueryItem(name: "api_key", value: Config.apiKey)]
        switch self {
        case .popularMovies(let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        case .movieDetail:
            break
        }
        return items
    }
}
