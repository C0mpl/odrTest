//
//  ContentView.swift
//  ODRTest
//
//  Created by Ilias Mirzoiev on 04.01.2024.
//

import SwiftUI

struct ContentView: View { 
    
    @StateObject private var viewModel = ODRViewModel()

    var body: some View {
        VStack {
            if viewModel.isDownloading {
                ProgressView("Downloading...", value: viewModel.downloadProgress, total: 1.0)
            } else if viewModel.downloadComplete {
                Text("Download Complete!")
            } else {
                Button("Download the File", action: viewModel.requestODRResources)
            }
        }
        .padding()
        .sheet(item: $viewModel.htmlFilePath, onDismiss: {
            WebServerManager.shared.stopServer()
        }) { filePath in
            WebView(url: filePath.url)
        }
        .alert("Error", isPresented: $viewModel.isErrorPresented, actions: {}) {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.htmlFilePath) { oldValue, newValue in
            if newValue == nil {
                viewModel.downloadComplete = false
            }
        }
    }
}

#Preview {
    ContentView()
}
