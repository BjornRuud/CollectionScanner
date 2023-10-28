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
}

// MARK: - Peek

extension CollectionScanner {
    /// Peek at the current element without advancing the index.
    public func peek() -> Element? {
        return currentElement
    }

    /// Peek at the next `maxLength` elements without advancing the index.
    public func peek(next maxLength: Int) -> SubSequence {
        let startIndex = currentIndex
        let endIndex = collection.index(
            startIndex,
            offsetBy: maxLength,
            limitedBy: collection.endIndex
        ) ?? collection.endIndex
        return collection[startIndex..<endIndex]
    }

    /// Peek at the element `offset` positions ahead without advancing the index.
    public func peek(offset: Int) -> Element? {
        guard
            let peekIndex = collection.index(
                currentIndex,
                offsetBy: offset,
                limitedBy: collection.endIndex
            ),
            peekIndex < collection.endIndex
        else { return nil }
        return collection[peekIndex]
    }
}

// MARK: - Scan

extension CollectionScanner {
    /// Scan `maxLength` number of elements.
    public func scan(_ maxLength: Int) -> SubSequence {
        let startIndex = currentIndex
        skip(maxLength)
        return collection[startIndex..<currentIndex]
    }

    /// Scan elements equal to a collection.
    public func scan<C>(collection otherCollection: C) -> SubSequence
    where C: Collection, C.Element == Element {
        let startIndex = currentIndex
        for otherElement in otherCollection {
            guard currentElement == otherElement else {
                currentIndex = startIndex
                break
            }
            skip(1)
        }
        return collection[startIndex..<currentIndex]
    }

    /// Scan a single element.
    public func scan(element: Element) -> SubSequence {
        let startIndex = currentIndex
        if currentElement == element {
            skip(1)
        }
        return collection[startIndex..<currentIndex]
    }

    /// Scan elements as long as they are contained in `set`.
    public func scan<S>(set: S) -> SubSequence
    where S: SetAlgebra, S.Element == Element {
        return scan(while: { set.contains($0) })
    }

    /// Scan all elements up to `element`.
    public func scan(upTo element: Element) -> SubSequence {
        let startIndex = currentIndex
        skip(upTo: element)
        return collection[startIndex..<currentIndex]
    }

    /// Scan all elements up to a matching collection of elements.
    public func scan<C>(upToCollection otherCollection: C) -> SubSequence
    where C: Collection, C.Element == Element {
        let startIndex = currentIndex
        guard let firstElement = otherCollection.first
        else { return collection[startIndex..<startIndex] }
        repeat {
            skip(upTo: firstElement)
            // Possible match
            let matchStartIndex = currentIndex
            if !scan(collection: otherCollection).isEmpty {
                currentIndex = matchStartIndex
                break
            }
            skip(1)
        } while !isAtEnd
        return collection[startIndex..<currentIndex]
    }

    /// Scan all elements up to any element contained in `set`.
    public func scan<S>(upToSet set: S) -> SubSequence
    where S: SetAlgebra, S.Element == Element {
        let startIndex = currentIndex
        skip { !set.contains($0) }
        return collection[startIndex..<currentIndex]
    }

    /// Scan elements while `predicate` is true.
    public func scan(while predicate: (Element) -> Bool) -> SubSequence {
        let startIndex = currentIndex
        skip(while: predicate)
        return collection[startIndex..<currentIndex]
    }
}

// MARK: - Skip

extension CollectionScanner {
    /// Skip `count` elements, limited by the end of the collection.
    public func skip(_ count: Int) {
        currentIndex = collection.index(
            currentIndex,
            offsetBy: count,
            limitedBy: collection.endIndex
        ) ?? collection.endIndex
    }

    /// Skip an element if `element` matches current element.
    public func skip(element: Element) {
        if currentElement == element {
            skip(1)
        }
    }

    /// Skip elements in order and equal to elements in a collection.
    public func skip<C>(collection otherCollection: C)
    where C: Collection, C.Element == Element {
        let startIndex = currentIndex
        for otherElement in otherCollection {
            guard let currentElement, currentElement == otherElement else {
                currentIndex = startIndex
                return
            }
            currentIndex = collection.index(after: currentIndex)
        }
    }

    /// Skip elements as long as current element is contained in `set`.
    public func skip<S>(set: S)
    where S: SetAlgebra, S.Element == Element {
        skip { set.contains($0) }
    }

    /// Skip all elements up to `element`.
    public func skip(upTo element: Element) {
        skip { $0 != element }
    }

    /// Skip elements while `predicate` is true.
    public func skip(while predicate: (Element) -> Bool) {
        while let currentElement, predicate(currentElement) {
            currentIndex = collection.index(after: currentIndex)
        }
    }
}
