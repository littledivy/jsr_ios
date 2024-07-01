//
//  ContentView.swift
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

struct ContentView: View {
  @State private var activeTab = 0
  @StateObject var client: HTTPClient = HTTPClient()

  @AppStorage("accessToken") var accessToken = ""
  @AppStorage("avatarURL") var avatarURL: String?

  var body: some View {
    TabView(selection: $activeTab) {
      HomeView(client: client)
        .tabItem {
          Image(systemName: "house")
          Text("Home")
        }
        .tag(1)

      ExploreView(client: client)
        .tabItem {
          Image(systemName: "magnifyingglass")
          Text("Explore")
        }
        .tag(2)

      ProfileView(client: client)
        .tabItem {
          if let url = avatarURL {
            AsyncImage(url: URL(string: url)) { image in
              let size = CGSize(width: 30, height: 30)
              Image(size: size) { gfx in
                gfx.clip(to: Path(ellipseIn: .init(origin: .zero, size: size)))
                gfx.draw(image, in: .init(origin: .zero, size: size))
                if activeTab == 3 {
                  gfx.stroke(
                    Path(ellipseIn: .init(origin: .zero, size: size)), with: .color(.blue),
                    lineWidth: 2)
                }
              }
            } placeholder: {
              ProgressView()
            }
            .frame(width: 30, height: 30)
          } else {
            Image(systemName: "person")
              .frame(width: 30, height: 30)
          }

          Text("Profile")
        }
        .tag(3)
    }
    .onChange(of: accessToken) { _, _ in
      client.withAuth(token: accessToken)
    }
    .onAppear {
      client.withAuth(token: accessToken)
    }
  }
}

#Preview {
  ContentView()
}
