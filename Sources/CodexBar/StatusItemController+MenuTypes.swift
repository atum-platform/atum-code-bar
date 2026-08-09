import AppKit
import CodexBarCore
import SwiftUI

extension StatusItemController {
    var selectedMenuProvider: ProviderInstanceID? {
        get { self.settings.selectedMenuProvider }
        set { self.settings.selectedMenuProvider = newValue }
    }

    var fallbackProvider: UsageProvider? {
        // Intentionally uses availability-filtered list: fallback activates when no provider
        // can actually work, ensuring at least a codex icon is always visible.
        self.store.enabledProviders().isEmpty ? .codex : nil
    }
}

extension ProviderSwitcherSelection {
    var provider: UsageProvider? {
        switch self {
        case .overview:
            nil
        case let .provider(instanceID):
            instanceID.firstPartyProvider
        }
    }

    var instanceID: ProviderInstanceID? {
        switch self {
        case .overview: nil
        case let .provider(instanceID): instanceID
        }
    }
}

struct OverviewMenuCardRowView: View {
    static let showsSectionDividers = false
    static let maximumVisibleMetrics = 3

    let model: UsageMenuCardView.Model
    let storageText: String?
    let width: CGFloat
    @Environment(\.menuItemHighlighted) private var isHighlighted
    @Environment(\.menuCardRefreshMonitor) private var refreshMonitor

    var body: some View {
        let liveModel = self.resolvedLiveModel(refreshMonitor: self.refreshMonitor)
        let visibleMetrics = self.visibleMetrics(for: liveModel)
        VStack(alignment: .leading, spacing: 9) {
            Text(liveModel.providerName)
                .font(.headline.weight(.semibold))
                .foregroundStyle(MenuHighlightStyle.primary(self.isHighlighted))
                .lineLimit(1)
                .truncationMode(.tail)

            if visibleMetrics.isEmpty {
                Text(self.compactStatusText(for: liveModel))
                    .font(.footnote)
                    .foregroundStyle(self.compactStatusColor(for: liveModel))
                    .lineLimit(1)
                    .truncationMode(.tail)
            } else {
                ForEach(visibleMetrics) { metric in
                    OverviewUsageMetricRow(
                        metric: metric,
                        title: UsageMenuCardView.popupMetricTitle(provider: liveModel.provider, metric: metric),
                        progressColor: liveModel.progressColor)
                }
            }
        }
        .padding(.horizontal, UsageMenuCardLayout.horizontalPadding)
        .padding(.vertical, 9)
        .frame(width: self.width, alignment: .leading)
    }

    @MainActor
    func resolvedLiveModel(refreshMonitor: MenuCardRefreshMonitor?) -> UsageMenuCardView.Model {
        guard self.model.usesLiveSubtitle else { return self.model }
        return refreshMonitor?.model(for: self.model.provider, fallback: self.model) ?? self.model
    }

    func visibleMetrics(for model: UsageMenuCardView.Model) -> [UsageMenuCardView.Model.Metric] {
        Array(model.metrics.prefix(Self.maximumVisibleMetrics))
    }

    func compactStatusText(for model: UsageMenuCardView.Model) -> String {
        if model.subtitleStyle == .loading {
            return "\(L("Refreshing"))…"
        }
        if model.subtitleStyle == .error {
            return L("No overview data available.")
        }
        if let placeholder = model.placeholder?.trimmingCharacters(in: .whitespacesAndNewlines), !placeholder.isEmpty {
            return placeholder
        }
        return L("No overview data available.")
    }

    private func compactStatusColor(for model: UsageMenuCardView.Model) -> Color {
        model.subtitleStyle == .error
            ? MenuHighlightStyle.error(self.isHighlighted)
            : MenuHighlightStyle.secondary(self.isHighlighted)
    }
}

private struct OverviewUsageMetricRow: View {
    let metric: UsageMenuCardView.Model.Metric
    let title: String
    let progressColor: Color
    @Environment(\.menuItemHighlighted) private var isHighlighted

    var body: some View {
        let presentation = self.metric.linePresentation(title: self.title)
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(self.metric.statusText == nil ? presentation.titleText : self.title)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(MenuHighlightStyle.primary(self.isHighlighted))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(1)
                Spacer(minLength: 8)
                if let trailingText = self.metric.statusText ?? presentation.resetText {
                    Text(trailingText)
                        .font(.footnote)
                        .foregroundStyle(MenuHighlightStyle.secondary(self.isHighlighted))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            if self.metric.statusText == nil {
                UsageProgressBar(
                    percent: self.metric.percent,
                    tint: self.progressColor,
                    accessibilityLabel: self.metric.percentStyle.accessibilityLabel,
                    pacePercent: self.metric.pacePercent,
                    paceOnTop: self.metric.paceOnTop,
                    warningMarkerPercents: self.metric.warningMarkerPercents,
                    workdayMarkerPercents: self.metric.workdayMarkerPercents)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OpenAIWebMenuItems {
    let hasUsageBreakdown: Bool
    let hasCreditsHistory: Bool
    let hasCostHistory: Bool
    let canShowBuyCredits: Bool
}

struct TokenAccountMenuDisplay: Equatable {
    let provider: UsageProvider
    let accounts: [ProviderTokenAccount]
    let snapshots: [TokenAccountUsageSnapshot]
    let activeIndex: Int
    let layout: MultiAccountMenuLayout

    var showAll: Bool {
        self.layout == .stacked
    }

    var showSwitcher: Bool {
        self.layout == .segmented
    }

    static func == (lhs: TokenAccountMenuDisplay, rhs: TokenAccountMenuDisplay) -> Bool {
        lhs.provider == rhs.provider &&
            lhs.accountIdentity == rhs.accountIdentity &&
            lhs.activeIndex == rhs.activeIndex &&
            lhs.layout == rhs.layout &&
            lhs.snapshotIdentity == rhs.snapshotIdentity
    }

    private var accountIdentity: [AccountIdentity] {
        self.accounts.map { account in
            AccountIdentity(
                id: account.id,
                label: account.label,
                externalIdentifier: account.externalIdentifier,
                usageScope: account.usageScope,
                organizationID: account.organizationID,
                workspaceID: account.workspaceID)
        }
    }

    private var snapshotIdentity: [SnapshotIdentity] {
        self.snapshots.map { snapshot in
            SnapshotIdentity(
                id: snapshot.id,
                hasSnapshot: snapshot.snapshot != nil,
                error: snapshot.error,
                sourceLabel: snapshot.sourceLabel)
        }
    }

    private struct AccountIdentity: Equatable {
        let id: UUID
        let label: String
        let externalIdentifier: String?
        let usageScope: String?
        let organizationID: String?
        let workspaceID: String?
    }

    private struct SnapshotIdentity: Equatable {
        let id: UUID
        let hasSnapshot: Bool
        let error: String?
        let sourceLabel: String?
    }
}

struct CodexAccountMenuDisplay: Equatable {
    let accounts: [CodexVisibleAccount]
    let snapshots: [CodexAccountUsageSnapshot]
    let activeVisibleAccountID: String?
    let layout: MultiAccountMenuLayout

    var showAll: Bool {
        self.layout == .stacked
    }

    var showSwitcher: Bool {
        self.layout == .segmented
    }

    var workspaceSections: [CodexAccountWorkspaceSection] {
        self.accounts.codexWorkspaceSections()
    }

    var showsWorkspaceGroups: Bool {
        Set(self.workspaceSections.map(\.title)).count > 1
    }

    static func == (lhs: CodexAccountMenuDisplay, rhs: CodexAccountMenuDisplay) -> Bool {
        lhs.accounts == rhs.accounts &&
            lhs.activeVisibleAccountID == rhs.activeVisibleAccountID &&
            lhs.layout == rhs.layout &&
            lhs.snapshotIdentity == rhs.snapshotIdentity
    }

    private var snapshotIdentity: [SnapshotIdentity] {
        self.snapshots.map { snapshot in
            SnapshotIdentity(
                id: snapshot.id,
                hasSnapshot: snapshot.snapshot != nil,
                error: snapshot.error,
                sourceLabel: snapshot.sourceLabel)
        }
    }

    private struct SnapshotIdentity: Equatable {
        let id: String
        let hasSnapshot: Bool
        let error: String?
        let sourceLabel: String?
    }
}
