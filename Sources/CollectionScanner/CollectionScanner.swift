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

    public func advanceCurrentIndex(by count: Int = 1) {
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

    public func peek(offset: Int = 0) -> Element? {
        if isAtEnd { return nil }
        var index = currentIndex
        for _ in 0..<offset {
            index = collection.index(after: index)
            if index == collection.endIndex { return nil }
        }
        return collection[index]
    }

    public func scan() -> Element? {
        if isAtEnd { return nil }
        let element = collection[currentIndex]
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

    public func scan<OtherCollection>(_ otherCollection: OtherCollection) -> Bool
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

    public func scanUpTo<OtherCollection>(_ otherCollection: OtherCollection) -> CollectionType.SubSequence?
    where OtherCollection: Collection, OtherCollection.Element == Element {
        guard
            !isAtEnd,
            let firstElement = otherCollection.first
        else { return nil }
        let startIndex = currentIndex
        while !isAtEnd {
            guard let _ = scanUpTo(firstElement) else { continue }
            // Possible match
            let matchIndex = currentIndex
            if scan(otherCollection) {
                currentIndex = matchIndex
                break
            } else {
                advanceCurrentIndex()
            }
        }
        return collection[startIndex..<currentIndex]
    }
}
