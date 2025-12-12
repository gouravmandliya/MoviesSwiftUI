//
//  ErrorView.swift
//  Movies
//
//  Created by Gourav Mandliya on 11/12/25.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Retry", action: retryAction)
                .buttonStyle(.glassProminent)
        }
        .padding()
    }
}

