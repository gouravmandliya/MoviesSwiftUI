//
//  MovieDetailView.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import SwiftUI

struct MovieDetailView: View {
    @StateObject var viewModel: MovieDetailViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if let detail = viewModel.movieDetail {
                detailContent(detail)
            } else {
                ErrorView(
                    message: "Failed to load movie details",
                    retryAction: { Task { await viewModel.loadMovieDetail() } }
                )
            }
        }
        .task {
            await viewModel.loadMovieDetail()
        }
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK", role: .cancel) { }
            Button("Retry") {
                Task { await viewModel.loadMovieDetail() }
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "Unknown error")
        }
    }
    
    @ViewBuilder
    private func detailContent(_ detail: MovieDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let backdropURL = detail.backdropURL {
                    SDRemoteImageView(url: backdropURL, contentMode: .fill) {
                        Color.gray.opacity(0.3)
                            .frame(maxWidth: .infinity, minHeight: 250, maxHeight: 400)
                            .clipped()
                    }
                    .frame(maxWidth: .infinity, minHeight: 250, maxHeight: 400)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.3), Color.clear]),
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .accessibilityHidden(true)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(detail.title)
                        .font(.largeTitle)
                        .bold()
                    
                    if let tagline = detail.tagline {
                        Text(tagline)
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        if let year = detail.releaseDate?.prefix(4) {
                            Label(String(year), systemImage: "calendar")
                        }
                        
                        if let runtime = detail.formattedRuntime {
                            Label(runtime, systemImage: "clock")
                        }
                        
                        Label(detail.formattedRating, systemImage: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .font(.subheadline)
                    
                    if !detail.genres.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(detail.genres) { genre in
                                    Text(genre.name)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    Text("Overview")
                        .font(.title2)
                        .bold()
                        .padding(.top)
                    
                    Text(detail.overview)
                        .font(.body)
                }
                .padding(.top, 8)
                .padding()
            }
            .padding(.bottom, 16)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

