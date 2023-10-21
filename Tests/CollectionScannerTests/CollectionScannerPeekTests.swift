import XCTest
@testable import CollectionScanner

final class CollectionScannerPeekTests: XCTestCase {
    func testPeek() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.peek(), "a")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
    }

    func testPeekNext() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.peek(next: 2), "ab")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
    }

    func testPeekOffset() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.peek(offset: 1), "b")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
    }
}
