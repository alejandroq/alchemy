@testable
import Alchemy
import AlchemyTest

final class QueryOrderTests: TestCase<TestApp> {
    override func setUp() {
        super.setUp()
        Database.stub()
    }
    
    func testOrderBy() {
        let query = DB.table("foo")
            .orderBy("bar")
            .orderBy("baz", direction: .desc)
        XCTAssertEqual(query.orders, [
            Query.Order(column: "bar", direction: .asc),
            Query.Order(column: "baz", direction: .desc),
        ])
    }
}
