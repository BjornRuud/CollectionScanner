import XCTest
@testable import CollectionScanner

final class CollectionScannerDataTests: XCTestCase {
    let data = Data([1, 2, 3])

    func testDataCollection() throws {
        let scanner = CollectionScanner(data)
        scanner.skip { $0 == 2 }
        XCTAssertEqual(scanner.currentElement, 1)
        scanner.skip(2)
        XCTAssertEqual(scanner.currentElement, 3)
    }
}
