//
//  ScopeMembersView.swift
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

struct ScopeMembersView: View {
  @ObservedObject var client: HTTPClient
  @State var members: [Components.Schemas.ScopeMember]?

  var scope: String

  func getMembers() async {
    do {
      let response = try await client.client.listScopeMembers(path: .init(scope: scope))
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          members = res
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      case .badRequest(_):
        print("err")
      case .notFound(_):
        print("err")
      case .unauthorized(_):
        print("err")
      }
    } catch {
      print(error)
    }

  }

  var body: some View {
    NavigationStack {
      VStack {
        if let members = members {
          List(members) { member in
            HStack {
              Text(member.user.name)

              Spacer()

              Text(member.isAdmin ? "admin" : "member")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
        } else {
          ProgressView()
        }
      }
      .navigationTitle("Members")
    }.task {
      await getMembers()
    }
  }
}
