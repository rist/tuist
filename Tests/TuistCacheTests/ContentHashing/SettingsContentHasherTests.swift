import Foundation
import TSCBasic
import TuistCacheTesting
import TuistCore
import TuistCoreTesting
import TuistSupport
import XCTest
@testable import TuistCache
@testable import TuistSupportTesting

final class SettingsContentHasherTests: TuistUnitTestCase {
    private var subject: SettingsContentHasher!
    private var mockContentHasher: MockContentHashing!
    private let filePath1 = AbsolutePath("/file1")

    override func setUp() {
        super.setUp()
        mockContentHasher = MockContentHashing()
        subject = SettingsContentHasher(contentHasher: mockContentHasher)
    }

    override func tearDown() {
        subject = nil
        mockContentHasher = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_hash_whenRecommended_withXCConfig_callsContentHasherWithExpectedStrings() throws {
        mockContentHasher.stubHashForPath[filePath1] = "xconfigHash"

        // Given
        let settings = Settings(
            base: ["CURRENT_PROJECT_VERSION": SettingValue.string("1")],
            configurations: [
                BuildConfiguration.debug("dev"): Configuration(settings: ["SWIFT_VERSION": SettingValue.string("5")], xcconfig: filePath1),
            ],
            defaultSettings: .recommended
        )

        // When
        let hash = try subject.hash(settings: settings)

        // Then
        XCTAssertEqual(hash, "CURRENT_PROJECT_VERSION:string(\"1\");devdebugSWIFT_VERSION:string(\"5\")xconfigHash;recommended")
    }

    func test_hash_whenEssential_withoutXCConfig_callsContentHasherWithExpectedStrings() throws {
        mockContentHasher.stubHashForPath[filePath1] = "xconfigHash"

        // Given
        let settings = Settings(
            base: ["CURRENT_PROJECT_VERSION": SettingValue.string("2")],
            configurations: [
                BuildConfiguration.release("prod"): Configuration(settings: ["SWIFT_VERSION": SettingValue.string("5")], xcconfig: nil),
            ],
            defaultSettings: .essential
        )

        // When
        let hash = try subject.hash(settings: settings)

        // Then
        XCTAssertEqual(hash, "CURRENT_PROJECT_VERSION:string(\"2\");prodreleaseSWIFT_VERSION:string(\"5\");essential")
    }
}
