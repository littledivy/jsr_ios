//
//  WebView.swift
//
//  Copyright (c) 2024 Divy Srivastava
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
  @Binding var text: String
  @Binding var css: String
  @Binding var contentHeight: CGFloat

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.scrollView.isScrollEnabled = false
    webView.navigationDelegate = context.coordinator
    let html = """
      <html>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link rel="stylesheet" href="https://jsr.io/styles.css">
      <style>\(css)</style>
      <div class="ddoc" id="docMain">\(text)</div>
      </html>
      """

    webView
      .loadHTMLString(html, baseURL: nil)
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(contentHeight: $contentHeight)
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    @Binding var contentHeight: CGFloat
    var resized = false

    init(contentHeight: Binding<CGFloat>) {
      self._contentHeight = contentHeight
    }

    internal func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      if !self.resized {
        webView.evaluateJavaScript("document.readyState") { complete, _ in
          guard complete != nil else { return }
          webView.evaluateJavaScript("document.body.scrollHeight") { height, _ in
            guard let height = height as? CGFloat else { return }

            self.contentHeight = height
            self.resized = true
          }
        }
      }
    }
  }
}
