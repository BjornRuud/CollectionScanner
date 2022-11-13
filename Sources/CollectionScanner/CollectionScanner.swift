open class CollectionScanner<CollectionType>
where CollectionType: Collection, CollectionType.Element: Equatable {
    public typealias Element = CollectionType.Element
    public typealias Index = CollectionType.Index

    public let collection: CollectionType

    public var currentElement: Element? {
        if isAtEnd { return nil }
        return collection[currentIndex]
    }

    public var currentIndex: Index {
        didSet {
            if currentIndex > collection.endIndex {
                currentIndex = collection.endIndex
            }
        }
    }

    public var isAtEnd: Bool {
        return currentIndex == collection.endIndex
    }

    public init(_ collection: CollectionType) {
        self.collection = collection
        self.currentIndex = collection.startIndex
    }

    public func advanceCurrentIndex() {
        if isAtEnd { return }
        currentIndex = collection.index(after: currentIndex)
    }

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

    public func peek() -> Element? {
        return currentElement
    }

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

    public func scan() -> Element? {
        let element = currentElement
        advanceCurrentIndex()
        return element
    }

    public func scan(_ element: Element) -> Bool {
        guard
            let nextElement = peek(),
            nextElement == element
        else { return false }
        advanceCurrentIndex()
        return true
    }

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

    public func scanUpTo(_ element: Element) -> CollectionType.SubSequence? {
        if isAtEnd { return nil }
        let startIndex = currentIndex
        while let nextElement = peek(), nextElement != element {
            advanceCurrentIndex()
        }
        return collection[startIndex..<currentIndex]
    }

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

    public func scan<ElementSet>(set elementSet: ElementSet) -> Element?
    where ElementSet: SetAlgebra, ElementSet.Element == Element {
        guard
            let element = peek(),
            elementSet.contains(element)
        else { return nil }
        advanceCurrentIndex()
        return element
    }

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
