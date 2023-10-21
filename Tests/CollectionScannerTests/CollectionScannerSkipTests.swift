import XCTest
@testable import CollectionScanner

final class CollectionScannerSkipTests: XCTestCase {
    func testSkip() throws {
        let scanner = CollectionScanner("ab")
        scanner.skip()
        XCTAssertEqual(scanner.currentElement, "b")
        scanner.skip()
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
    }

    func testSkipCount() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip(2)
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testSkipWhile() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip { $0 == "a" || $0 == "b" }
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testSkipCollection() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip(collection: "ab")
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testSkipThrough() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip(through: "b")
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testSkipUpTo() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip(upTo: "c")
        XCTAssertEqual(scanner.currentElement, "c")
    }
}
