import SwiftUI

/// Slim banner that appears at the top of the popover when an update is
/// available or an install is in progress. Hidden in `.idle`, `.upToDate`,
/// and `.checking` to avoid pestering the user during routine polls.
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

    // MARK: - Rows

    private func availableRow(version: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
            Text("Update \(version) available")
                .font(.system(size: 12, weight: .medium))
            Spacer()
            Button("Later") { checker.dismiss() }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                )
            Button("Update") { checker.installAvailableUpdate() }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.accentColor)
                )
        }
        .modifier(BannerContainer())
    }

    private func downloadingRow(progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("Downloading update…")
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.system(size: 11, weight: .medium))
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
                .font(.system(size: 12, weight: .medium))
            Spacer()
        }
        .modifier(BannerContainer())
    }

    private func failedRow(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.system(size: 11, weight: .semibold))
            Text("Update failed: \(message)")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer()
            Button("Retry") {
                Task { await checker.checkForUpdates(userInitiated: true) }
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.primary.opacity(0.06))
            )
        }
        .modifier(BannerContainer())
    }
}

private struct BannerContainer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
            .padding(.horizontal, 12)
            .padding(.top, 10)
    }
}
