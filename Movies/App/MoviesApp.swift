//
//  MoviesApp.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import SwiftUI

@main
struct MoviesApp: App {
    let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            MovieListView(viewModel: container.makeMovieListViewModel())
        }
    }
}
