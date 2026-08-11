import CodexBarCore
import Foundation
import Testing
@testable import CodexBar

struct OverviewMenuCardRowViewTests {
    @Test
    @MainActor
    func `compact overview shows weekly before session`() throws {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let model = try Self.makeClaudeModel(
            primaryUsedPercent: 25,
            secondaryUsedPercent: 60,
            updatedAt: now)

        #expect(model.metrics.map(\.id) == ["primary", "secondary"])
        let row = OverviewMenuCardRowView(model: model, storageText: nil, width: 310)
        let liveModel = row.resolvedLiveModel(refreshMonitor: nil)
        #expect(row.visibleMetrics(for: liveModel).map(\.id) == ["secondary", "primary"])
        #expect(OverviewMenuCardRowView.maximumVisibleMetrics == 3)
    }

    @Test
    @MainActor
    func `compact overview respects providers whose primary metric is weekly`() throws {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let model = try Self.makeModel(
            provider: .kimi,
            primaryUsedPercent: 25,
            secondaryUsedPercent: 60,
            updatedAt: now)

        #expect(model.metrics.map(\.id) == ["secondary", "primary"])
        let row = OverviewMenuCardRowView(model: model, storageText: nil, width: 310)
        #expect(row.visibleMetrics(for: model).map(\.id) == ["primary", "secondary"])
    }

    @Test
    @MainActor
    func `compact overview resolves refreshed quota meters from the live monitor`() throws {
        let stale = try Self.makeClaudeModel(
            primaryUsedPercent: 25,
            secondaryUsedPercent: 60,
            updatedAt: Date(timeIntervalSince1970: 1))
        let refreshed = try Self.makeClaudeModel(
            primaryUsedPercent: 70,
            secondaryUsedPercent: 80,
            updatedAt: Date(timeIntervalSince1970: 2))
        let monitor = MenuCardRefreshMonitor(
            resolveModel: { provider in
                provider == .claude ? refreshed : nil
            },
            isProviderRefreshActive: { _ in false })
        let row = OverviewMenuCardRowView(model: stale, storageText: nil, width: 310)

        #expect(row.resolvedLiveModel(refreshMonitor: monitor).metrics.map(\.percent) == [30, 20])
    }

    @Test
    @MainActor
    func `compact overview replaces verbose errors with a short status`() throws {
        let metadata = try #require(ProviderDefaults.metadata[.claude])
        let model = UsageMenuCardView.Model.make(.init(
            provider: .claude,
            metadata: metadata,
            snapshot: nil,
            credits: nil,
            creditsError: nil,
            dashboard: nil,
            dashboardError: nil,
            tokenSnapshot: nil,
            tokenError: nil,
            account: AccountInfo(email: nil, plan: nil),
            isRefreshing: false,
            lastError: "A deliberately long OAuth failure that belongs in provider details, not Overview.",
            usageBarsShowUsed: false,
            resetTimeDisplayStyle: .countdown,
            tokenCostUsageEnabled: false,
            showOptionalCreditsAndExtraUsage: true,
            hidePersonalInfo: false,
            now: Date(timeIntervalSince1970: 1_700_000_000)))
        let row = OverviewMenuCardRowView(model: model, storageText: nil, width: 310)

        #expect(model.metrics.isEmpty)
        #expect(row.compactStatusText(for: model) == "Unavailable")
    }

    private static func makeClaudeModel(
        primaryUsedPercent: Double,
        secondaryUsedPercent: Double,
        updatedAt: Date) throws -> UsageMenuCardView.Model
    {
        try self.makeModel(
            provider: .claude,
            primaryUsedPercent: primaryUsedPercent,
            secondaryUsedPercent: secondaryUsedPercent,
            updatedAt: updatedAt)
    }

    private static func makeModel(
        provider: UsageProvider,
        primaryUsedPercent: Double,
        secondaryUsedPercent: Double,
        updatedAt: Date) throws -> UsageMenuCardView.Model
    {
        let metadata = try #require(ProviderDefaults.metadata[provider])
        let primaryWindowMinutes = provider == .kimi ? 10080 : 300
        let secondaryWindowMinutes = provider == .kimi ? 300 : 10080
        let snapshot = UsageSnapshot(
            primary: RateWindow(
                usedPercent: primaryUsedPercent,
                windowMinutes: primaryWindowMinutes,
                resetsAt: updatedAt.addingTimeInterval(3600),
                resetDescription: nil),
            secondary: RateWindow(
                usedPercent: secondaryUsedPercent,
                windowMinutes: secondaryWindowMinutes,
                resetsAt: updatedAt.addingTimeInterval(86400),
                resetDescription: nil),
            updatedAt: updatedAt,
            identity: nil)
        return UsageMenuCardView.Model.make(.init(
            provider: provider,
            metadata: metadata,
            snapshot: snapshot,
            credits: nil,
            creditsError: nil,
            dashboard: nil,
            dashboardError: nil,
            tokenSnapshot: nil,
            tokenError: nil,
            account: AccountInfo(email: nil, plan: nil),
            isRefreshing: false,
            lastError: nil,
            usageBarsShowUsed: false,
            resetTimeDisplayStyle: .countdown,
            tokenCostUsageEnabled: false,
            showOptionalCreditsAndExtraUsage: true,
            hidePersonalInfo: false,
            usesLiveSubtitle: true,
            now: updatedAt))
    }
}
