//
//  LoadingView.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Loading...")
                .foregroundColor(.secondary)
                .padding(.top)
        }
    }
}
