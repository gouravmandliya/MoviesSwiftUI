//
//  MovieListView.swift
//  Movies
//
//  Created by Gourav Mandliya on 10/12/25.
//

import SwiftUI

struct MovieListView: View {
    @StateObject var viewModel: MovieListViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    LoadingView()
                } else if viewModel.movies.isEmpty {
                    ErrorView(
                        message: "No movies available",
                        retryAction: { Task { await viewModel.refresh() } }
                    )
                } else {
                    movieList
                }
            }
            .navigationTitle("Popular Movies")
            .task {
                if viewModel.movies.isEmpty {
                    await viewModel.loadMovies()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .alert("Error", isPresented: $viewModel.isShowingError) {
                Button("OK", role: .cancel) { }
                Button("Retry") {
                    Task { await viewModel.loadMovies() }
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    private var movieList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink(value: movie) {
                        MovieRowView(movie: movie)
                    }
                    .buttonStyle(.plain)
                    .task {
                        await viewModel.loadMoreIfNeeded(currentMovie: movie)
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
        .navigationDestination(for: Movie.self) { movie in
            MovieDetailView(
                viewModel: viewModel.makeDetailViewModel(movieId: movie.id)
            )
        }
    }
}
