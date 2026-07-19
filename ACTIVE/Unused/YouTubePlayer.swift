//
//  YouTubePlayer.swift
//  ACTIVE
//
//  Created by Emma Bian on 2026-01-08.
//

import Foundation
import SwiftUI
import WebKit

struct YouTubePlayer: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let embedURL = "https://www.youtube.com/embed/\(videoID)?playsinline=1"
        let request = URLRequest(url: URL(string: embedURL)!)
        uiView.scrollView.isScrollEnabled = false
        uiView.load(request)
    }
}
