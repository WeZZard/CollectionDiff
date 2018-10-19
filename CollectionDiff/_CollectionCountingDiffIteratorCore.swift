//
//  _CollectionCountingDiffIteratorCore.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//


internal class _CollectionCountingDiffIteratorCore<
    C1: Collection,
    C2: Collection,
    I: Hashable
    >: _CollectionDiffIteratorCore<C1, C2> where C1.Index == C2.Index
{
    internal typealias Identifier = I
    
    internal typealias FromItem = C1.Element
    
    internal typealias ToItem = C2.Element
    
    internal typealias Index = C1.Index
    
    internal let isIdentical: ((FromItem, ToItem) -> Bool)
    
    internal let identifierForFromItem: (FromItem) -> Identifier
    
    internal let identifierForToItem: (ToItem) -> Identifier
    
    internal let fromCollection: C1
    
    internal let toCollection: C2
    
    internal var fromPairsForID: [Identifier : [(Index, FromItem)]]
    
    internal var isPrepared: Bool
    
    internal var identicals: [(Index, FromItem, Index, ToItem)]
    internal var insertions: [(Index, ToItem)]
    internal var deletions: [(Index, FromItem)]
    internal var moves: [(Index, FromItem, Index, ToItem)]
    internal var updates: [(Index, FromItem, Index, ToItem)]
    
    internal init(
        fromCollection: C1,
        toCollection: C2,
        identifierForFromItem: @escaping (FromItem) -> Identifier,
        identifierForToItem: @escaping (ToItem) -> Identifier,
        isIdentical: @escaping ((FromItem, ToItem) -> Bool)
        )
    {
        self.fromCollection = fromCollection
        self.toCollection = toCollection
        self.identifierForFromItem = identifierForFromItem
        self.identifierForToItem = identifierForToItem
        self.isIdentical = isIdentical
        fromPairsForID = [:]
        identicals = []
        insertions = []
        deletions = []
        moves = []
        updates = []
        isPrepared = false
    }
    
    internal func prepareIfNeeded() {
        guard !isPrepared else { return }
        
        for index in fromCollection.indices {
            let fromItem = fromCollection[index]
            let identifier = identifierForFromItem(fromItem)
            if var container = fromPairsForID[identifier] {
                container.append((index, fromItem))
                fromPairsForID[identifier] = container
            } else {
                fromPairsForID[identifier] = [(index, fromItem)]
            }
        }
        
        for toIndex in toCollection.indices {
            let toItem = toCollection[toIndex]
            let identifier = identifierForToItem(toItem)
            if var fromPairs = fromPairsForID[identifier] {
                if let (fromIndex, fromItem) = fromPairs.first {
                    fromPairs.removeFirst()
                    
                    if fromIndex == toIndex {
                        if isIdentical(fromItem, toItem) {
                            identicals.append((fromIndex, fromItem, toIndex, toItem))
                        } else {
                            updates.append((fromIndex, fromItem, toIndex, toItem))
                        }
                    } else {
                        moves.append((fromIndex, fromItem, toIndex, toItem))
                    }
                    
                    fromPairsForID[identifier] = fromPairs.count > 0
                        ? fromPairs
                        : nil
                }
            } else {
                insertions.append((toIndex, toItem))
            }
        }
        
        for (_, fromPairs) in fromPairsForID {
            for (fromIndex, fromItem) in fromPairs {
                deletions.append((fromIndex, fromItem))
            }
        }
        
        if deletions.count > 0 {
            deletions.sort(by: {$0.0 < $1.0})
        }
        
        if insertions.count > 0 {
            insertions.sort(by: {$0.0 > $1.0})
        }
        
        isPrepared = true
    }
    
    internal override func next() -> Element? {
        prepareIfNeeded()
        
        if let (fromIndex, fromItem, toIndex, toItem) = identicals.popLast() {
            return .identical(fromIndex, fromItem, toIndex, toItem)
        }
        
        if let (fromIndex, fromItem, toIndex, toItem) = updates.popLast() {
            return .update(fromIndex, fromItem, toIndex, toItem)
        }
        
        if let (fromIndex, fromItem, toIndex, toItem) = moves.popLast() {
            return .move(fromIndex, fromItem, toIndex, toItem)
        }
        
        if let (fromIndex, fromItem) = deletions.popLast() {
            return .deletion(fromIndex, fromItem)
        }
        
        if let (toIndex, toItem) = insertions.popLast() {
            return .insertion(toIndex, toItem)
        }
        
        return nil
    }
}


internal class _CollectionComparisonDiffPreparedToItem<
    Index,
    Item
    >: CustomStringConvertible
{
    internal var hasRelativeFromItem: Bool
    
    internal let index: Index
    internal let item: Item
    
    internal init(index: Index, item: Item) {
        self.index = index
        self.item = item
        self.hasRelativeFromItem = false
    }
    
    internal var description: String {
        return "<\(type(of: self)); Index = \(index); Element = \(item); Has Relative From Element = \(hasRelativeFromItem)>>"
    }
}


internal enum _CollectionComparisonDiffIteratorAction<
    C1: Collection,
    C2: Collection
    > where C1.Index == C2.Index
{
    case skip
    case pop(Differential<C1, C2>)
    case terminate
    
    internal var shouldSkip: Bool {
        switch self {
        case .skip:         return true
        case .terminate:    return false
        case .pop:          return false
        }
    }
    
    internal var shouldTerminate: Bool {
        switch self {
        case .skip:         return false
        case .terminate:    return true
        case .pop:          return false
        }
    }
}
