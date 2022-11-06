import XCTest
@testable import CollectionScanner

final class CollectionScannerDataTests: XCTestCase {
    let data = Data([1, 2, 3])

    func testDataCollection() throws {
        let scanner = CollectionScanner(data)
        XCTAssertEqual(scanner.scan(), 1)
        XCTAssertTrue(scanner.scan(2))
        XCTAssertTrue(scanner.scan(3))
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
    }
}
