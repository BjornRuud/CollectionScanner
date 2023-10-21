import XCTest
@testable import CollectionScanner

final class CollectionScannerPrefixTests: XCTestCase {
    func testRemoveFirst() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.removeFirst(), "a")
        XCTAssertEqual(scanner.currentElement, "b")
    }

    func testPrefix() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.prefix(2), "ab")
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testPrefixWhile() throws {
        let scanner = CollectionScanner("abc")
        let prefix = scanner.prefix { $0 != "c" }
        XCTAssertEqual(prefix, "ab")
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testPrefixThrough() throws {
        let scanner = CollectionScanner("abc")
        let prefix = scanner.prefix(through: "b")
        XCTAssertEqual(prefix, "ab")
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testPrefixUpTo() throws {
        let scanner = CollectionScanner("abc")
        let prefix = scanner.prefix(upTo: "c")
        XCTAssertEqual(prefix, "ab")
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testPrefixUpToCollection() throws {
        let scanner = CollectionScanner("a12bcd")
        let prefix = scanner.prefix(upToCollection: "bc")
        XCTAssertEqual(prefix, "a12")
        XCTAssertEqual(scanner.currentElement, "b")
    }
}
