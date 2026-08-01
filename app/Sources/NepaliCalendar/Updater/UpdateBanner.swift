import SwiftUI

struct UpdateBanner: View {
    @ObservedObject var checker: UpdateChecker

    var body: some View {
        switch checker.state {
        case .available(let manifest):
            availableRow(version: manifest.version)
        case .downloading(let progress):
            downloadingRow(progress: progress)
        case .installing:
            installingRow
        case .failed(let message):
            failedRow(message: message)
        default:
            EmptyView()
        }
    }

    private func availableRow(version: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.accentSuccess)
                .frame(width: 6, height: 6)
            Text("Update \(version) available")
                .font(.button)
            Spacer()
            Button("Later") { checker.dismiss() }
                .buttonStyle(BannerSecondaryButtonStyle())
            Button("Update") { checker.installAvailableUpdate() }
                .buttonStyle(BannerPrimaryButtonStyle())
        }
        .modifier(BannerContainer())
    }

    private func downloadingRow(progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("Downloading update…")
                    .font(.button)
                Spacer()
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            ProgressView(value: max(0, min(1, progress)))
                .progressViewStyle(.linear)
        }
        .modifier(BannerContainer())
    }

    private var installingRow: some View {
        HStack(spacing: 8) {
            ProgressView().controlSize(.small)
            Text("Installing update — app will relaunch…")
                .font(.button)
            Spacer()
        }
        .modifier(BannerContainer())
    }

    private func failedRow(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.badge)
            Text("Update failed: \(message)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer()
            Button("Retry") {
                Task { await checker.checkForUpdates(userInitiated: true) }
            }
            .buttonStyle(BannerSecondaryButtonStyle())
        }
        .modifier(BannerContainer())
    }
}

private struct BannerSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .frame(minHeight: Metrics.hitAreaMin)
            .background(
                RoundedRectangle(cornerRadius: Metrics.radiusControl, style: .continuous)
                    .fill(Color.surfaceHover)
            )
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? Metrics.pressScale : 1)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

private struct BannerPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.badge)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .frame(minHeight: Metrics.hitAreaMin)
            .background(
                RoundedRectangle(cornerRadius: Metrics.radiusControl, style: .continuous)
                    .fill(Color.accentSelected)
            )
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? Metrics.pressScale : 1)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

private struct BannerContainer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: Metrics.radiusCard, style: .continuous)
                    .fill(Color.surfaceElevated)
            )
            .cardShadow()
            .padding(.horizontal, 12)
            .padding(.top, 10)
    }
}
