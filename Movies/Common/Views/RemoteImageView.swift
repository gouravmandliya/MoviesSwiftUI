//
//  RemoteImageView.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import SwiftUI
import SDWebImageSwiftUI

/// A reusable image loader built on SDWebImageSwiftUI's `WebImage`.
/// Use this anywhere you previously used `AsyncImage` to get consistent
/// caching, activity indicator, fade transition, and placeholders.
struct RemoteImageView<Placeholder: View>: View {
    let url: URL?
    let contentMode: ContentMode
    let options: SDWebImageOptions
    @ViewBuilder var placeholder: Placeholder
    private let customContent: ((Image) -> AnyView)?

    /// Designated initializer.
    /// - Parameters:
    ///   - url: The remote image URL.
    ///   - contentMode: How the image should scale inside its bounds.
    ///   - options: SDWebImage options. Defaults enable retry, background continue and scale down.
    ///   - placeholder: Placeholder view shown while loading.
    init(
        url: URL?,
        contentMode: ContentMode = .fit,
        options: SDWebImageOptions = [.retryFailed, .continueInBackground, .scaleDownLargeImages],
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.options = options
        self.placeholder = placeholder()
        self.customContent = nil
    }

    init<I: View, P: View>(
        url: URL?,
        options: SDWebImageOptions = [.retryFailed, .continueInBackground, .scaleDownLargeImages],
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: () -> P
    ) where Placeholder == P {
        self.url = url
        self.contentMode = .fit
        self.options = options
        self.placeholder = placeholder()
        self.customContent = { image in AnyView(content(image)) }
    }

    var body: some View {
        WebImage(url: url, options: options) { image in
            if let customContent {
                customContent(image)
            } else {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            }
        } placeholder: {
            placeholder
        }
        .indicator(.activity)
        .transition(.fade(duration: 0.25))
    }
}

// Convenience initializer with a default placeholder
extension RemoteImageView where Placeholder == Color {
    init(
        url: URL?,
        contentMode: ContentMode = .fit,
        options: SDWebImageOptions = [.retryFailed, .continueInBackground, .scaleDownLargeImages]
    ) {
        self.init(url: url, contentMode: contentMode, options: options) {
            Color.gray.opacity(0.3)
        }
    }
}
