import SwiftUI
import OpenAPIURLSession

extension String: Identifiable {
    public var id: String { self }
}

struct PackageCardView: View {
    var package: Components.Schemas.Package

    @State var compatCount: [String] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(package.scope)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(package.name)
                        .font(.title)
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(package.description
                            .trimmingCharacters(in: .whitespacesAndNewlines))
                            .lineLimit(1)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .frame(width: 300)
                VStack {
                    HStack(spacing: 2) {
                        Spacer()
                        if package.runtimeCompat != nil {
                            ZStack {
                                ForEach(compatCount, id: \.self) { compat in
                                    let index = compatCount.firstIndex(of: compat)!
                                    Image(compat)
                                        .resizable()
                                        .foregroundColor(.green)
                                        .frame(width: 20, height: 20)
                                        .offset(x: -10 * CGFloat(index), y: 0)
                                }
                            }.onAppear {
                                if package.runtimeCompat != nil {
                                    let compat = package.runtimeCompat!
                                    if compat.bun == true {
                                        compatCount.append("bun")
                                    }
                                    if compat.node == true {
                                        compatCount.append("node")
                                    }
                                    if compat.deno == true {
                                        compatCount.append("deno")
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        if package.score != nil {
                            Image(systemName: "gauge.open.with.lines.needle.33percent")
                                .foregroundColor(.green)
                            Text(String(package.score!))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .border(width: 0.2, edges: [.bottom], color: .secondary)
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            PackageCardView(package: Components.Schemas.Package(
                scope: "@std",
                name: "fmt",
                description: "SDL2 module for Deno",
                runtimeCompat: Components.Schemas.RuntimeCompat(
                    deno: true,
                    node: true,
                    bun: true
                ),
                createdAt: Date.now,
                updatedAt: Date.now,
                score: 100
            ))
            PackageCardView(package: Components.Schemas.Package(
                scope: "@std",
                name: "encoding-stream",
                description: "Encoding Stream module",
                runtimeCompat: Components.Schemas.RuntimeCompat(
                    deno: true,
                    node: true,
                    bun: true
                ),
                createdAt: Date.now,
                updatedAt: Date.now,
                score: 100
            ))
        }
        
        Spacer()
    }
}
