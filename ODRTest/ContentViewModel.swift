//
//  ContentViewModel.swift
//  ODRTest
//
//  Created by Ilias Mirzoiev on 04.01.2024.
//

import Foundation
import Combine

class ODRViewModel: ObservableObject {
    @Published var isDownloading: Bool = false
    @Published var downloadProgress: Double = 0.0
    @Published var downloadComplete: Bool = false
    @Published var htmlFilePath: IdentifiableURL?
    @Published var isErrorPresented: Bool = false

    private var resourceRequest: NSBundleResourceRequest?
    private var progressObserver: NSKeyValueObservation?
    
    var errorMessage: String?

    func requestODRResources() {
        let tags = Set<String>(["tag"])
        resourceRequest = NSBundleResourceRequest(tags: tags)
        
        self.isDownloading = true
        self.resourceRequest?.conditionallyBeginAccessingResources { [weak self] available in
            guard let self = self else { return }

            if available {
                DispatchQueue.main.async {
                    self.downloadComplete = true
                    self.isDownloading = false
                    self.openDownloadedHTMLFile()
                }
            } else {
//                self.openDownloadedHTMLFile()
                self.beginDownloadingResources()
            }
        }
    }
    
    private func beginDownloadingResources() {
        guard let resourceRequest = resourceRequest else { return }

        progressObserver = resourceRequest.progress.observe(\.fractionCompleted, options: [.new], changeHandler: { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.downloadProgress = progress.fractionCompleted
            }
        })
        
        resourceRequest.beginAccessingResources { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isDownloading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isErrorPresented = true
                } else {
                    self.downloadComplete = true
                    self.openDownloadedHTMLFile()
                }
            }
        }
    }
    
    private func openDownloadedHTMLFile() {
        DispatchQueue.main.async {
            guard let resourcePath = Bundle.main.path(forResource: "index", ofType: "html") else {
                self.errorMessage = "Failed to find the HTML file."
                self.isErrorPresented = true
                return
            }
            do {
                try WebServerManager.shared.startServer()
                try WebServerManager.shared.copyFileToServerDirectory(fileURL: URL(fileURLWithPath: resourcePath))
                guard let url = WebServerManager.shared.getServerURL() else {
                    self.errorMessage = "Something wrong with server url"
                    self.isErrorPresented = true
                    return
                }
                self.htmlFilePath = IdentifiableURL(url: url)
            } catch {
                self.errorMessage = error.localizedDescription
                self.isErrorPresented = true
            }
        }
    }

    deinit {
        progressObserver?.invalidate()
        resourceRequest?.endAccessingResources()
    }
}
