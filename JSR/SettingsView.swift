import OpenAPIURLSession
import SwiftUI

struct SettingsView: View {
  @AppStorage("accessToken") var accessToken: String = ""
  @AppStorage("loggedIn") var loggedIn: Bool?
  @AppStorage("avatarURL") var avatarURL: String?

  @ObservedObject var client: ClientObj
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
