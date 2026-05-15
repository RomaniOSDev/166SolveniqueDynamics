import SwiftUI

struct TermFamilyGraphListView: View {
    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(LearningContent.graphClusters) { cluster in
                        NavigationLink {
                            TermFamilyGraphView(cluster: cluster)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(cluster.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.appTextPrimary)
                                Text(cluster.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                Text("\(cluster.nodes.count) terms · \(cluster.edges.count) links")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color.appAccent)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appListCard()
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded { FeedbackManager.lightTap() })
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Term Families")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct TermFamilyGraphView: View {
    @EnvironmentObject private var store: AppDataStore
    let cluster: TermGraphCluster

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(cluster.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, 4)

                    graphCanvas
                        .frame(height: 320)
                        .appHeroCard(padding: 12)

                    nodeList
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(cluster.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var graphCanvas: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                ForEach(cluster.edges) { edge in
                    if let from = cluster.nodes.first(where: { $0.id == edge.fromNodeId }),
                       let to = cluster.nodes.first(where: { $0.id == edge.toNodeId }) {
                        Path { path in
                            let start = CGPoint(x: from.x * size.width, y: from.y * size.height)
                            let end = CGPoint(x: to.x * size.width, y: to.y * size.height)
                            path.move(to: start)
                            path.addLine(to: end)
                        }
                        .stroke(Color.appPrimary.opacity(0.45), lineWidth: 2)

                        Text(edge.label)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color.appTextSecondary)
                            .position(
                                x: (from.x + to.x) * 0.5 * size.width,
                                y: (from.y + to.y) * 0.5 * size.height - 10
                            )
                    }
                }

                ForEach(cluster.nodes) { node in
                    graphNodeButton(node, size: size)
                }
            }
        }
    }

    @ViewBuilder
    private func graphNodeButton(_ node: TermGraphNode, size: CGSize) -> some View {
        let position = CGPoint(x: node.x * size.width, y: node.y * size.height)
        if let term = LegalGlossary.term(named: node.termName, enabledPacks: store.enabledPackIds) {
            NavigationLink {
                TermDetailView(term: term)
            } label: {
                Text(node.termName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .frame(width: 88, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppVisualStyle.surfaceGradient)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.appPrimary.opacity(0.5), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .position(position)
            .simultaneousGesture(TapGesture().onEnded { FeedbackManager.lightTap() })
        } else {
            Text(node.termName)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .position(position)
        }
    }

    private var nodeList: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Terms in this map", icon: "list.bullet")
            ForEach(cluster.nodes) { node in
                if let term = LegalGlossary.term(named: node.termName, enabledPacks: store.enabledPackIds) {
                    NavigationLink {
                        TermDetailView(term: term)
                    } label: {
                        ActionRowCell(title: term.name, icon: term.category.iconName, trailingIcon: "arrow.right")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .appCard(padding: 0, elevation: .raised)
    }
}
