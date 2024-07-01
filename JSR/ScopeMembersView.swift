import OpenAPIURLSession
import SwiftUI

extension Components.Schemas.ScopeMember: Identifiable {
  public var id: String { user.id }
}

struct ScopeMembersView: View {
  @ObservedObject var client: ClientObj
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
