//
//  PersistenceManager.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import CoreData

protocol PersistenceManaging {
    func saveMovies(_ movies: [Movie]) async throws
    func fetchMovies() async throws -> [Movie]
    func saveMovieDetail(_ detail: MovieDetail) async throws
    func fetchMovieDetail(id: Int) async throws -> MovieDetail?
}

final class PersistenceManager: PersistenceManaging {
    static let shared = PersistenceManager()
    
    private let container: NSPersistentContainer
    
    private var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: "Movies")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveMovies(_ movies: [Movie]) async throws {
        try await context.perform {
            for movie in movies {
                let entity = MovieEntity(context: self.context)
                entity.id = Int64(movie.id)
                entity.title = movie.title
                entity.overview = movie.overview
                entity.posterPath = movie.posterPath
                entity.backdropPath = movie.backdropPath
                entity.releaseDate = movie.releaseDate
                entity.voteAverage = movie.voteAverage
                entity.voteCount = Int64(movie.voteCount)
            }
            
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }
    
    func fetchMovies() async throws -> [Movie] {
        try await context.perform {
            let request = MovieEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MovieEntity.voteAverage, ascending: false)]
            
            let entities = try self.context.fetch(request)
            return entities.map { $0.toMovie() }
        }
    }
    
    func saveMovieDetail(_ detail: MovieDetail) async throws {
        try await context.perform {
            let request = MovieDetailEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", detail.id)
            
            let existing = try self.context.fetch(request).first
            let entity = existing ?? MovieDetailEntity(context: self.context)
            
            entity.id = Int64(detail.id)
            entity.title = detail.title
            entity.overview = detail.overview
            entity.posterPath = detail.posterPath
            entity.backdropPath = detail.backdropPath
            entity.releaseDate = detail.releaseDate
            entity.voteAverage = detail.voteAverage
            entity.voteCount = Int64(detail.voteCount)
            entity.runtime = Int64(detail.runtime ?? 0)
            entity.tagline = detail.tagline
            entity.genres = detail.genres.map { $0.name }.joined(separator: ", ")
            
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }
    
    func fetchMovieDetail(id: Int) async throws -> MovieDetail? {
        try await context.perform {
            let request = MovieDetailEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            
            guard let entity = try self.context.fetch(request).first else {
                return nil
            }
            
            return entity.toMovieDetail()
        }
    }
}


// Core Data Model Extensions
extension MovieEntity {
    func toMovie() -> Movie {
        Movie(
            id: Int(id),
            title: title ?? "",
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: Int(voteCount)
        )
    }
}

extension MovieDetailEntity {
    func toMovieDetail() -> MovieDetail {
        let genreNames = genres?.components(separatedBy: ", ") ?? []
        let genreObjects = genreNames.enumerated().map { index, name in
            MovieDetail.Genre(id: index, name: name)
        }
        
        return MovieDetail(
            id: Int(id),
            title: title ?? "",
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: Int(voteCount),
            runtime: runtime > 0 ? Int(runtime) : nil,
            genres: genreObjects,
            tagline: tagline
        )
    }
}
