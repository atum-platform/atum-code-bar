import AppKit
import CodexBarCore
import Foundation

enum ProviderDetectionPolicy {
    struct Signals {
        let codexCLIInstalled: Bool
        let claudeCLIInstalled: Bool
        let claudeDesktopInstalled: Bool
        let kimiCLIInstalled: Bool
        let kimiConfigured: Bool
        let geminiCLIInstalled: Bool
        let geminiConfigured: Bool
        let antigravityAvailable: Bool
        let configuredProviders: Set<UsageProvider>
    }

    static func enabledProviders(signals: Signals) -> Set<UsageProvider> {
        // Provider-specific by design: first-run detection probes these four concrete CLI/app credential sources.
        var enabled: Set<UsageProvider> = []
        if signals.codexCLIInstalled {
            enabled.insert(.codex)
        }
        if signals.claudeCLIInstalled || signals.claudeDesktopInstalled {
            enabled.insert(.claude)
        }
        if signals.kimiCLIInstalled || signals.kimiConfigured {
            enabled.insert(.kimi)
        }
        if signals.geminiCLIInstalled, signals.geminiConfigured {
            enabled.insert(.gemini)
        }
        if signals.antigravityAvailable {
            enabled.insert(.antigravity)
        }
        enabled.formUnion(signals.configuredProviders)

        // Keep the historical Codex default when no usable provider source is found.
        if enabled.isEmpty {
            enabled.insert(.codex)
        }
        return enabled
    }
}

extension SettingsStore {
    func runInitialProviderDetectionIfNeeded(force: Bool = false) {
        guard force || !self.providerDetectionCompleted else { return }
        LoginShellPathCache.shared.captureOnce { [weak self] _ in
            Task { @MainActor in
                await self?.applyProviderDetection()
            }
        }
    }

    func applyProviderDetection() async {
        guard !self.providerDetectionCompleted else { return }
        // Provider-specific by design: detection reads each provider's installed app, CLI, or credential artifact.
        let codexCLIInstalled = BinaryLocator.resolveCodexBinary() != nil
        let claudeCLIInstalled = BinaryLocator.resolveClaudeBinary() != nil
        let claudeDesktopInstalled = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "com.anthropic.claudefordesktop") != nil
        let kimiCLIInstalled = TTYCommandRunner.which("kimi") != nil
        let kimiConfigured = KimiSettingsReader.hasKimiCodeCredential()
        let geminiCLIInstalled = BinaryLocator.resolveGeminiBinary() != nil
        let geminiConfigured = FileManager.default.fileExists(
            atPath: FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".gemini/oauth_creds.json").path)
        let antigravityRunning = await AntigravityStatusProbe.isRunning()
        let antigravityLoggedIn = FileManager.default.fileExists(
            atPath: AntigravityOAuthCredentialsStore().fileURL.path)
        let configuredProviders = Set(UsageProvider.allCases.filter { provider in
            guard let config = self.config.providerConfig(for: provider.instanceID) else { return false }
            return config.apiKey?.isEmpty == false ||
                config.secretKey?.isEmpty == false ||
                config.cookieHeader?.isEmpty == false ||
                config.workspaceID?.isEmpty == false ||
                config.enterpriseHost?.isEmpty == false ||
                config.tokenAccounts?.accounts.isEmpty == false
        })
        let logger = CodexBarLog.logger(LogCategories.providerDetection)

        let enabledProviders = ProviderDetectionPolicy.enabledProviders(signals: .init(
            codexCLIInstalled: codexCLIInstalled,
            claudeCLIInstalled: claudeCLIInstalled,
            claudeDesktopInstalled: claudeDesktopInstalled,
            kimiCLIInstalled: kimiCLIInstalled,
            kimiConfigured: kimiConfigured,
            geminiCLIInstalled: geminiCLIInstalled,
            geminiConfigured: geminiConfigured,
            antigravityAvailable: antigravityRunning || antigravityLoggedIn,
            configuredProviders: configuredProviders))

        logger.info(
            "Provider detection results",
            metadata: [
                "codexCLIInstalled": codexCLIInstalled ? "1" : "0",
                "claudeCLIInstalled": claudeCLIInstalled ? "1" : "0",
                "claudeDesktopInstalled": claudeDesktopInstalled ? "1" : "0",
                "kimiCLIInstalled": kimiCLIInstalled ? "1" : "0",
                "kimiConfigured": kimiConfigured ? "1" : "0",
                "geminiCLIInstalled": geminiCLIInstalled ? "1" : "0",
                "geminiConfigured": geminiConfigured ? "1" : "0",
                "antigravityRunning": antigravityRunning ? "1" : "0",
                "antigravityLoggedIn": antigravityLoggedIn ? "1" : "0",
                "configuredProviders": configuredProviders.map(\.rawValue).sorted().joined(separator: ","),
            ])
        logger.info(
            "Provider detection enablement",
            metadata: [
                "codex": enabledProviders.contains(.codex) ? "1" : "0",
                "claude": enabledProviders.contains(.claude) ? "1" : "0",
                "kimi": enabledProviders.contains(.kimi) ? "1" : "0",
                "gemini": enabledProviders.contains(.gemini) ? "1" : "0",
                "antigravity": enabledProviders.contains(.antigravity) ? "1" : "0",
            ])

        // Discovery is additive. A later manual re-run must not turn off a provider the user
        // configured explicitly, and a fresh install can safely pick up newly installed tools.
        for provider in enabledProviders {
            self.updateProviderConfig(provider: provider) { entry in
                entry.enabled = true
            }
        }
        self.providerDetectionCompleted = true
        logger.info("Provider detection completed")
    }
}
