import Testing
@testable import CodexBar
@testable import CodexBarCore

struct ProviderDetectionPolicyTests {
    @Test
    func `fresh install detects Codex and Claude Desktop without unconfigured Gemini`() {
        let enabled = ProviderDetectionPolicy.enabledProviders(signals: .init(
            codexCLIInstalled: true,
            claudeCLIInstalled: false,
            claudeDesktopInstalled: true,
            kimiCLIInstalled: false,
            kimiConfigured: false,
            geminiCLIInstalled: true,
            geminiConfigured: false,
            antigravityAvailable: false))

        #expect(enabled == [.codex, .claude])
    }

    @Test
    func `configured Gemini CLI is detected`() {
        let enabled = ProviderDetectionPolicy.enabledProviders(signals: .init(
            codexCLIInstalled: false,
            claudeCLIInstalled: false,
            claudeDesktopInstalled: false,
            kimiCLIInstalled: false,
            kimiConfigured: false,
            geminiCLIInstalled: true,
            geminiConfigured: true,
            antigravityAvailable: false))

        #expect(enabled == [.gemini])
    }

    @Test
    func `authenticated Kimi Code CLI is detected`() {
        let enabled = ProviderDetectionPolicy.enabledProviders(signals: .init(
            codexCLIInstalled: false,
            claudeCLIInstalled: false,
            claudeDesktopInstalled: false,
            kimiCLIInstalled: true,
            kimiConfigured: true,
            geminiCLIInstalled: false,
            geminiConfigured: false,
            antigravityAvailable: false))

        #expect(enabled == [.kimi])
    }

    @Test
    func `Kimi CLI without durable credentials is not enabled`() {
        let enabled = ProviderDetectionPolicy.enabledProviders(signals: .init(
            codexCLIInstalled: true,
            claudeCLIInstalled: false,
            claudeDesktopInstalled: false,
            kimiCLIInstalled: true,
            kimiConfigured: false,
            geminiCLIInstalled: false,
            geminiConfigured: false,
            antigravityAvailable: false))

        #expect(enabled == [.codex])
    }

    @Test
    func `Codex remains the fallback when no provider source is available`() {
        let enabled = ProviderDetectionPolicy.enabledProviders(signals: .init(
            codexCLIInstalled: false,
            claudeCLIInstalled: false,
            claudeDesktopInstalled: false,
            kimiCLIInstalled: false,
            kimiConfigured: false,
            geminiCLIInstalled: false,
            geminiConfigured: false,
            antigravityAvailable: false))

        #expect(enabled == [.codex])
    }
}
