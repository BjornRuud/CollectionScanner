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

    func testScanElement() throws {
        let scanner = CollectionScanner("abc")
        var index = scanner.currentIndex
        XCTAssertTrue(scanner.scan("a"))
        index = scanner.collection.index(after: index)
        XCTAssertEqual(index, scanner.currentIndex)
        XCTAssertFalse(scanner.scan("d"))
        XCTAssertEqual(index, scanner.currentIndex)
        XCTAssertTrue(scanner.scan("b"))
        index = scanner.collection.index(after: index)
        XCTAssertEqual(index, scanner.currentIndex)
        XCTAssertTrue(scanner.scan("c"))
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
        XCTAssertFalse(scanner.scan("c"))
    }

    func testScanCollection() throws {
        let scanner = CollectionScanner("abc")
        let other = "bc"
        XCTAssertFalse(scanner.scan(other))
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
        XCTAssertTrue(scanner.scan("a"))
        XCTAssertTrue(scanner.scan(other))
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
    }

    func testScanCollectionOutOfBounds() throws {
        let scanner = CollectionScanner("abc")
        let other = "bcd"
        XCTAssertFalse(scanner.scan(other))
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
        XCTAssertTrue(scanner.scan("a"))
        XCTAssertFalse(scanner.scan(other))
        XCTAssertEqual(scanner.currentIndex, scanner.collection.index(after: scanner.collection.startIndex))
    }

    func testScanUpToElement() throws {
        let scanner = CollectionScanner("abc")
        var prefix = scanner.scanUpTo("a")
        XCTAssertEqual(prefix, "")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
        prefix = scanner.scanUpTo("c")
        XCTAssertEqual(prefix, "ab")
        let afterPrefixIndex = scanner.collection.index(scanner.collection.startIndex, offsetBy: 2)
        XCTAssertEqual(afterPrefixIndex, scanner.currentIndex)
        scanner.currentIndex = scanner.collection.startIndex
        prefix = scanner.scanUpTo("d")
        XCTAssertEqual(prefix, "abc")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
    }

    func testScanUpToCollection() throws {
        let scanner = CollectionScanner("abcd")
        var prefix = scanner.scanUpTo("abc")
        XCTAssertEqual(prefix, "")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.startIndex)
        prefix = scanner.scanUpTo("bc")
        XCTAssertEqual(prefix, "a")
        let afterPrefixIndex = scanner.collection.index(after: scanner.collection.startIndex)
        XCTAssertEqual(afterPrefixIndex, scanner.currentIndex)
        scanner.currentIndex = scanner.collection.startIndex
        prefix = scanner.scanUpTo("cde")
        XCTAssertEqual(prefix, "abcd")
        XCTAssertEqual(scanner.currentIndex, scanner.collection.endIndex)
    }
}
