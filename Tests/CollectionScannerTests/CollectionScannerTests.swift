import XCTest
@testable import CollectionScanner

final class CollectionScannerTests: XCTestCase {
    func testAdvanceCurrentIndex() throws {
        let scanner = CollectionScanner("a")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
        scanner.advanceCurrentIndex()
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
        scanner.advanceCurrentIndex()
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
    }

    func testAdvanceCurrentIndexBy() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
        scanner.advanceCurrentIndex(by: 2)
        XCTAssertEqual(scanner.currentElement, "c")
        scanner.currentIndex = scanner.collection.startIndex
        scanner.advanceCurrentIndex(by: 3)
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
    }

    func testPeek() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.peek(), "a")
        XCTAssertEqual(scanner.peek(offset: 1), "b")
        XCTAssertEqual(scanner.peek(offset: 2), "c")
        XCTAssertNil(scanner.peek(offset: 3))
        XCTAssertNil(scanner.peek(offset: 4))
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
    }

    func testScan() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.scan(), "a")
        XCTAssertEqual(scanner.scan(), "b")
        XCTAssertEqual(scanner.scan(), "c")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
        XCTAssertNil(scanner.scan())
    }
}
