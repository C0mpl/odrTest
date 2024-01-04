//
//  WebServerManager.swift
//  ODRTest
//
//  Created by Ilias Mirzoiev on 04.01.2024.
//

import Foundation
import GCDWebServer

class WebServerManager {
    static let shared = WebServerManager()
    private var webServer = GCDWebServer()
    private let indexPath = "index.html"
    private let webServerPort: UInt = 8000
    private let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiV2lucG90Iiwic2l0ZSI6IndpbnBvdC5teCJ9.qlqDprazOIXBVhEPqA6t3g_PI03si-XTetf8lYaM1jc"

    private init() {}

    func startServer() throws {
        do {
            let serverURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("www")
            try FileManager.default.createDirectory(at: serverURL, withIntermediateDirectories: true, attributes: nil)

            webServer.addGETHandler(forBasePath: "/", directoryPath: serverURL.path, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)

            webServer.start(withPort: webServerPort, bonjourName: "GCD Web Server")
        } catch {
            throw error
        }
    }

    func stopServer() {
        webServer.stop()
    }

    func copyFileToServerDirectory(fileURL: URL) throws {
        let serverURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("www")
        let destinationURL = serverURL.appendingPathComponent(fileURL.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: fileURL, to: destinationURL)
        } catch {
            throw error
        }
    }
    
    func getServerURL() -> URL? {
        guard let urlString = webServer.serverURL?.absoluteString, var urlComponents = URLComponents(string: urlString + indexPath) else {
            return nil
        }
        let queryItem = URLQueryItem(name: "token", value: token)
        urlComponents.queryItems = [queryItem]
        return urlComponents.url
    }
}
