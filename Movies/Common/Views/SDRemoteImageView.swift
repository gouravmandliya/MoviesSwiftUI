//
//  RemoteImageView.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct SDRemoteImageView<Placeholder: View>: View {
    let url: URL?
    let contentMode: ContentMode
    let options: SDWebImageOptions
    @ViewBuilder var placeholder: Placeholder
    private let customContent: ((Image) -> AnyView)?

    init(url: URL?, contentMode: ContentMode = .fit, options: SDWebImageOptions = [.retryFailed, .continueInBackground, .scaleDownLargeImages], @ViewBuilder placeholder: () -> Placeholder) {
        self.url = url
        self.contentMode = contentMode
        self.options = options
        self.placeholder = placeholder()
        self.customContent = nil
    }

    init<I: View>(url: URL?, options: SDWebImageOptions = [.retryFailed, .continueInBackground, .scaleDownLargeImages], @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: () -> Placeholder) {
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
