open class CollectionScanner<CollectionType>
where CollectionType: Collection, CollectionType.Element: Equatable {
    public typealias Element = CollectionType.Element
    public typealias Index = CollectionType.Index
    public typealias SubSequence = CollectionType.SubSequence

    public let collection: CollectionType

    /// The element at the current index, or `nil` if reached end of collection.
    public var currentElement: Element? {
        isAtEnd ? nil : collection[currentIndex]
    }

    /// The current index in the collection. It will be in the range startIndex...endIndex.
    public private(set) var currentIndex: Index

    /// Returns `true` if reached end of collection, else `false`.
    public var isAtEnd: Bool {
        return currentIndex == collection.endIndex
    }

    public init(_ collection: CollectionType) {
        self.collection = collection
        self.currentIndex = collection.startIndex
    }

    /// Move current index to specific index. The index will not go beyond the
    /// range `collection.startIndex...collection.endIndex`.
    public func setIndex(_ index: Index) {
        let clampedIndex = min(max(index, collection.startIndex), collection.endIndex)
        currentIndex = clampedIndex
    }

    /// Skip `count` elements, limited by the end of the collection.
    public func skip(_ count: Int = 1) {
        currentIndex = collection.index(
            currentIndex,
            offsetBy: count,
            limitedBy: collection.endIndex
        ) ?? collection.endIndex
    }

    /// Skip elements while the predicate is true.
    public func skip(while predicate: (Element) -> Bool) {
        while let element = currentElement, predicate(element) {
            currentIndex = collection.index(after: currentIndex)
        }
    }

    /// Skip elements equal to elements in a collection, and in the same order as
    /// the collection.
    public func skip<OtherCollection>(collection otherCollection: OtherCollection)
    where OtherCollection: Collection, OtherCollection.Element == Element {
        if isAtEnd || otherCollection.isEmpty { return }
        let startIndex = currentIndex
        guard let endIndex = collection.index(
            startIndex,
            offsetBy: otherCollection.count,
            limitedBy: collection.endIndex
        ) else { return }
        for (element, otherElement) in zip(collection[startIndex..<endIndex], otherCollection) {
            guard element == otherElement else { return }
        }
        currentIndex = endIndex
        return
    }

    /// Skip elements through an element.
    public func skip(through element: Element) {
        skip(upTo: element)
        skip()
    }

    /// Skip elements up to an element.
    public func skip(upTo element: Element) {
        skip { $0 != element }
    }

    /// Peek at the current element without advancing the index.
    public func peek() -> Element? {
        return currentElement
    }

    /// Peek at the next `maxLength` elements.
    public func peek(next maxLength: Int) -> SubSequence {
        let startIndex = currentIndex
        let endIndex = collection.index(
            startIndex,
            offsetBy: maxLength,
            limitedBy: collection.endIndex
        ) ?? collection.endIndex
        return collection[startIndex..<endIndex]
    }

    /// Peek at the element `offset` positions ahead.
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

    /// Remove and return the current element.
    public func removeFirst() -> Element? {
        defer { skip() }
        return currentElement
    }

    /// Remove and return `maxLength` number of elements.
    public func prefix(_ maxLength: Int) -> SubSequence {
        let startIndex = currentIndex
        skip(maxLength)
        return collection[startIndex..<currentIndex]
    }

    /// Remove and return a sequence of elements up until the predicate is false.
    public func prefix(while predicate: (Element) -> Bool) -> SubSequence {
        let startIndex = currentIndex
        skip(while: predicate)
        return collection[startIndex..<currentIndex]
    }

    /// Remove and return a sequence from the current element through `element`.
    public func prefix(through element: Element) -> SubSequence {
        let startIndex = currentIndex
        skip(through: element)
        return collection[startIndex..<currentIndex]
    }

    /// Remove and return a sequence from the current element up to `element`.
    public func prefix(upTo element: Element) -> SubSequence {
        let startIndex = currentIndex
        skip(upTo: element)
        return collection[startIndex..<currentIndex]
    }

    /// Remove and return a sequence from the current element up to the start of the
    /// provided collection.
    public func prefix<OtherCollection>(upToCollection otherCollection: OtherCollection) -> SubSequence
    where OtherCollection: Collection, OtherCollection.Element == Element {
        let startIndex = currentIndex
        guard let firstElement = otherCollection.first
        else { return collection[startIndex..<startIndex] }
        while !isAtEnd {
            skip { $0 != firstElement }
            // Possible match
            let matchCollection = peek(next: otherCollection.count)
            guard matchCollection.count == otherCollection.count else {
                // No match before end
                currentIndex = collection.endIndex
                break
            }
            let matchZip = zip(matchCollection, otherCollection)
            if matchZip.allSatisfy({ $0 == $1 }) {
                break
            }
            skip()
        }
        return collection[startIndex..<currentIndex]
    }
}
