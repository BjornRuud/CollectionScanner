open class CollectionScanner<CollectionType>
where CollectionType: Collection, CollectionType.Element: Equatable {
    public typealias Element = CollectionType.Element
    public typealias Index = CollectionType.Index

    public let collection: CollectionType

    /// The element at the current index, or `nil` if reached end of collection.
    public var currentElement: Element? {
        if isAtEnd { return nil }
        return collection[currentIndex]
    }

    /// The current index to be scanned in the collection. If reached end
    /// of the collection, or an index higher than the end index is set
    /// manually, the index will be `collection.endIndex`.
    public var currentIndex: Index {
        didSet {
            if currentIndex > collection.endIndex {
                currentIndex = collection.endIndex
            }
        }
    }

    /// Returns `true` if reached end of collection, else `false`.
    public var isAtEnd: Bool {
        return currentIndex == collection.endIndex
    }

    /**
     Initialize the scanner with any collection type.

     - Parameter collection: A type that conforms to the `Collection` protocol.
    */
    public init(_ collection: CollectionType) {
        self.collection = collection
        self.currentIndex = collection.startIndex
    }

    /// Advance current index to the index after it.
    public func advanceCurrentIndex() {
        if isAtEnd { return }
        currentIndex = collection.index(after: currentIndex)
    }

    /**
     Advance current index N positions. The index will not go beyond `collection.endIndex`.

     - Parameter count: The number of positions to advance the current index.
    */
    public func advanceCurrentIndex(by count: Int) {
        guard let updatedIndex = collection.index(
            currentIndex,
            offsetBy: count,
            limitedBy: collection.endIndex
        ) else {
            currentIndex = collection.endIndex
            return
        }
        currentIndex = updatedIndex
    }

    /**
     Peek at the current element without advancing the index.

     - Returns: The element at the current index, or `nil` if reached end of collection.
     */
    public func peek() -> Element? {
        return currentElement
    }

    /**
     Peek at the element at `currentIndex + offset` without advancing the index.

     - Parameter offset: The nummer of positions to look ahead.

     - Returns: The element at the offset index, or nil if offset index
                is at or beyond end of collection.
     */
    public func peek(offset: Int) -> Element? {
        guard let peekIndex = collection.index(
            currentIndex,
            offsetBy: offset,
            limitedBy: collection.endIndex
        ) else { return nil }
        if peekIndex < collection.endIndex {
            return collection[peekIndex]
        }
        return nil
    }

    /**
     Scan the element at the current index and advance the index.

     - Returns: The scanned element or nil if reached end of collection.
     */
    public func scan() -> Element? {
        let element = currentElement
        advanceCurrentIndex()
        return element
    }

    /**
     Scan for a specific element and advance the index if found.

     - Parameter element: The element to scan for.

     - Returns: True if element was found, otherwise false.
     */
    public func scan(_ element: Element) -> Bool {
        guard
            let nextElement = peek(),
            nextElement == element
        else { return false }
        advanceCurrentIndex()
        return true
    }

    /**
     Scan for a sequence of elements matching some collection with the same element type.
     If a match is found the current index is advanced to the end of the match.

     - Parameter collection: The sequnce of elements to look for.

     - Returns: True if sequence was found, false otherwise
     */
    public func scan<OtherCollection>(collection otherCollection: OtherCollection) -> Bool
    where OtherCollection: Collection, OtherCollection.Element == Element {
        if isAtEnd || otherCollection.isEmpty { return false }
        let startIndex = currentIndex
        guard let endIndex = collection.index(
            startIndex,
            offsetBy: otherCollection.count,
            limitedBy: collection.endIndex
        ) else { return false }
        for (element, otherElement) in zip(collection[startIndex..<endIndex], otherCollection) {
            guard element == otherElement else { return false }
        }
        currentIndex = endIndex
        return true
    }

    /**
     Scan up to a specific element.

     - Parameter element: The element to scan up to.

     - Returns: If element was found returns a subsequence from the index where scan
                started up to the index of the element. Since the scan starts at the
                current index this means an empty subsequence is returned if the element
                to scan for is the current element. If end of collection is reached
                returns nil.
     */
    public func scanUpTo(_ element: Element) -> CollectionType.SubSequence? {
        if isAtEnd { return nil }
        let startIndex = currentIndex
        while let nextElement = peek(), nextElement != element {
            advanceCurrentIndex()
        }
        return collection[startIndex..<currentIndex]
    }

    /**
     Scan up to a sequence of elements.

     - Parameter collection: The element sequence to scan up to.

     - Returns: If the sequence was found returns a subsequence from the index where scan
                started up to the index of the start of the sequence. Since the scan starts
                at the current index this means an empty subsequence is returned if the
                first element of the sequence to scan for is the current element. If end
                of collection is reached returns nil.
     */
    public func scanUpTo<OtherCollection>(collection otherCollection: OtherCollection) -> CollectionType.SubSequence?
    where OtherCollection: Collection, OtherCollection.Element == Element {
        guard
            !isAtEnd,
            let firstElement = otherCollection.first
        else { return nil }
        let startIndex = currentIndex
        while !isAtEnd {
            guard scanUpTo(firstElement) != nil else { continue }
            // Possible match
            let matchIndex = currentIndex
            if scan(collection: otherCollection) {
                currentIndex = matchIndex
                break
            }
            advanceCurrentIndex()
        }
        return collection[startIndex..<currentIndex]
    }

    /**
     Scan any element from a set, and advance the index if an element was found.

     - Parameter elementSet: The set of elements to scan for.

     - Returns: The element that was matched in the set, or nil if not found.
     */
    public func scan<ElementSet>(set elementSet: ElementSet) -> Element?
    where ElementSet: SetAlgebra, ElementSet.Element == Element {
        guard
            let element = peek(),
            elementSet.contains(element)
        else { return nil }
        advanceCurrentIndex()
        return element
    }

    /**
     Scan up to any element from a set. The index will be advanced to the match index.

     - Parameter elementSet: The set of elements to scan up to.

     - Returns: A subsequence from the start index of the scan to the current index.
                If no match is found the subsequence is from the start index of the
                scan to the end of the collection. Returns nil if the scan is started
                at the end of the collection.
     */
    public func scanUpTo<ElementSet>(set elementSet: ElementSet) -> CollectionType.SubSequence?
    where ElementSet: SetAlgebra, ElementSet.Element == Element {
        if isAtEnd { return nil }
        let startIndex = currentIndex
        while let element = peek() {
            if elementSet.contains(element) { break }
            advanceCurrentIndex()
        }
        return collection[startIndex..<currentIndex]
    }
}
