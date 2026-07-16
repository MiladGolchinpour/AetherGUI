import SwiftUI

struct LogsView: View {
    @EnvironmentObject var aether: AetherManager
    @State private var filterText: String = ""

    var filteredLogs: [LogEntry] {
        if filterText.isEmpty { return aether.logs }
        return aether.logs.filter { $0.message.localizedCaseInsensitiveContains(filterText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass").font(.system(size: 11)).foregroundColor(Color.aetherTextDim)
                    TextField("Filter...", text: $filterText)
                        .textFieldStyle(.plain).font(.system(size: 11)).foregroundColor(Color.aetherText)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.black.opacity(0.3))
                    .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Color.aetherBorder, lineWidth: 1)))

                Spacer()

                Button(action: { withAnimation { aether.clearLogs() } }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash").font(.system(size: 10, weight: .medium))
                        Text("Clear").font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(Color.aetherRed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.aetherRed.opacity(0.1))
                        .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Color.aetherRed.opacity(0.2), lineWidth: 1)))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 10)

            Divider().background(Color.white.opacity(0.06))

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    if filteredLogs.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 28))
                                .foregroundColor(Color.aetherTextDim.opacity(0.4))
                            Text("No logs")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.aetherTextDim)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 1) {
                            ForEach(filteredLogs) { entry in
                                LogEntryRow(entry: entry).id(entry.id)
                            }
                        }
                        .padding(14)
                    }
                }
                .onChange(of: aether.logs.count) {
                    if let last = aether.logs.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            .background(Color.black.opacity(0.2))
        }
    }
}

struct LogEntryRow: View {
    let entry: LogEntry
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text(formatTimestamp(entry.timestamp))
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(Color.aetherTextDim.opacity(0.5))
                .frame(width: 55, alignment: .leading)

            Image(systemName: entry.level.icon)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(entry.level.color)
                .frame(width: 10)

            Text(entry.message)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(entry.level.color.opacity(0.9))
                .textSelection(.enabled)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(isHovered ? Color.white.opacity(0.03) : Color.clear)
        .onHover { isHovered = $0 }
    }

    func formatTimestamp(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }
}
