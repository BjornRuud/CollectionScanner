# CollectionScanner

A reader to scan for elements and collections of elements in any type conforming to the `Collection` protocol. It comes with functions suitable for building parsers by hand.


## Installation

### Swift Package Manager

Add the CollectionScanner repo as a dependency to your `Package.swift` file and import `CollectionScanner` in your source files.


## Usage

Scan for a character in a `String`:

```swift
let scanner = CollectionScanner("abc")

// Current index is at 'a'
if scanner.scan("b") {
    // Character was not found, current index is still at 'a'
}

if scanner.scan("a") {
    // Character was found, current index is at 'b'
}

let someChar = scanner.peek()
// someChar is now 'b' but current index was not advanced
scanner.advanceIndex()
// Current index is at 'c'
```

You can also scan for a collection of elements or a set of elements at the current index, and scan up to the start of a matching element, collection or set. Look at the header docs for a description of the available functions.

Here is a simple example that demonstrates finding the start of a tag and then reads the tag name up to the end tag marker:

```swift
// Parse a string to find a simple XML tag
let xmlString = "this is <demo> a tag"
let scanner = CollectionScanner(xmlString)
let beforeTag = scanner.scanUpTo("<")
// beforeTag is now "this is " and index is at "<"
scanner.advanceIndex()
let tagName = scanner.scanUpTo(">")
// tagName is "demo"
```
