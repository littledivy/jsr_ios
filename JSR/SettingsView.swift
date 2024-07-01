//
//  SettingsView.swift
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

import OpenAPIURLSession
import SwiftUI

struct SettingsView: View {
  @AppStorage("accessToken") var accessToken: String = ""
  @AppStorage("loggedIn") var loggedIn: Bool?
  @AppStorage("avatarURL") var avatarURL: String?

  @ObservedObject var client: HTTPClient
  @State var accessTokenField: String = ""

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Authentication")) {
          HStack {
            SecureField("Access Token", text: $accessTokenField)
              .disableAutocorrection(true)
              .autocapitalization(.none)
            Spacer()
            if loggedIn == true {
              Spacer()
              Image(systemName: "checkmark")
                .foregroundColor(.green)
            } else if loggedIn == nil {
              ProgressView()
            }
          }

          if loggedIn == true {
            Button("Logout") {
              self.accessToken = ""
              self.accessTokenField = ""
              self.loggedIn = false
              self.avatarURL = nil
            }
            .foregroundColor(.red)
          } else {
            Button("Login") {
              self.loggedIn = nil
              self.accessToken = accessTokenField
              Task {
                do {
                  let response = try await client.client.getSelfUser()
                  switch response {
                  case .ok(let okResponse):
                    switch okResponse.body {
                    case .json(let user):
                      self.avatarURL = user.avatarUrl
                      self.loggedIn = true
                    }
                  case .undocumented(statusCode: _, _):
                    self.loggedIn = false
                  case .unauthorized(_):
                    self.loggedIn = false
                  }
                } catch {
                  self.loggedIn = false
                  print(error)
                }
              }
            }
          }
        }
      }
      .onAppear {
        accessTokenField = accessToken
      }
      .navigationTitle("Settings")
    }
  }
}
