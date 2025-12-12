import Foundation

// Centralized TMDB image URL configuration and helper
enum TMDB {
    enum Image {
        static let baseURL = "https://image.tmdb.org/t/p/"
        static let posterSize = "w500"
        static let backdropSize = "original"
        
        static func url(path: String?, size: String) -> URL? {
            guard let path = path else { return nil }
            return URL(string: baseURL + size + path)
        }
    }
    
    
}
