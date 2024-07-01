import OpenAPIURLSession
import SwiftUI

extension Components.Schemas.Scope: Identifiable {
  public var id: String { scope }
}

struct ProfileView: View {
  @AppStorage("accessToken") var accessToken: String = ""
  @AppStorage("loggedIn") var loggedIn: Bool?

  @State var user: Components.Schemas.User?
  @State var scopes: [Components.Schemas.Scope]?
  @ObservedObject var client: ClientObj

  func fetchUser() async {
    do {
      let response = try await client.client.getSelfUser()
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          user = res
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      case .unauthorized(let e):
        print(e)
        print("🙈 Unauthorized")
      }
    } catch {
      print(error)
    }

    do {
      let response = try await client.client.listSelfUserScopes()
      switch response {
      case .ok(let okResponse):
        switch okResponse.body {
        case .json(let res):
          scopes = res
        }
      case .undocumented(let statusCode, _):
        print("🙉 \(statusCode)")
      case .unauthorized(let e):
        print(e)
        print("🙈 Unauthorized")
      }

    } catch {
      print(error)
    }
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading) {
        if let user = user {
          HStack {
            AsyncImage(url: URL(string: user.avatarUrl)) { image in
              image
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } placeholder: {
              ProgressView()
            }

            VStack(alignment: .leading) {
              Text(user.name)
                .fontWeight(.bold)

              Text(user.email ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
          }
          .padding()
        } else if loggedIn == true {
          ProgressView()
        } else {
          List {
            NavigationLink(destination: SettingsView(client: client)) {
              HStack {
                Image(systemName: "key")
                Text("Set auth token")
              }
            }.buttonStyle(.bordered)
          }
          .refreshable {
            await fetchUser()
          }
        }

        if let scopes = scopes {
          Section(header: Text("Scopes").font(.title3).fontWeight(.bold).padding(.horizontal)) {
            List {
              ForEach(scopes) { scope in
                NavigationLink(destination: ScopesView(client: client, scope: scope)) {
                  Text(scope.scope)
                }
              }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
          }
        }

        Spacer()
      }
      .navigationTitle("Profile")
    }
    .onChange(of: accessToken) { _, _ in
      print("on change")
      if accessToken.isEmpty {
        user = nil
        scopes = nil
      } else {
        Task { await fetchUser() }
      }
    }
    .task {
      await fetchUser()
    }
    .refreshable {
      await fetchUser()
    }
  }
}
