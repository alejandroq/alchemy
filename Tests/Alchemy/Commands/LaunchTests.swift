@testable
import Alchemy
import AlchemyTest

final class LaunchTests: TestCase<TestApp> {
    func testLaunch() async throws {
        let fileName = UUID().uuidString
        Launch.main(["make:job", fileName])
        try app.lifecycle.startAndWait()
        XCTAssertTrue(FileCreator.shared.fileExists(at: "Jobs/\(fileName).swift"))
    }
}
