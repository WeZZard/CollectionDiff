//
//  _CollectionComparisonDiffIteratorCore.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//


internal class _CollectionComparisonDiffIteratorCore<
    C1: Collection,
    C2: Collection
    >: _CollectionDiffIteratorCore<C1, C2> where C1.Index == C2.Index
{
    
    internal typealias FromCollection = C1
    
    internal typealias ToCollection = C2
    
    internal typealias FromItem = C1.Element
    
    internal typealias ToItem = C2.Element
    
    internal typealias Index = C1.Index
    
    internal let isEqual: (FromItem, ToItem) -> Bool
    internal let isIdentical: (FromItem, ToItem) -> Bool
    
    internal let fromCollection: FromCollection
    internal var fromIterator: FromCollection.Iterator
    
    internal let toCollection: ToCollection
    
    internal var preparedToItems: [PreparedToItem]!
    
    internal lazy var preparedToItemsIterator: PreparedToItemsIterator = {
        return self.preparedToItems.makeIterator()
    }()
    
    internal var nextFromIndex: Index
    
    internal var isPrepared: Bool
    
    internal var insertions: [(Index, ToItem)]
    internal var deletions: [(Index, FromItem)]
    internal var moves: [(Index, FromItem, Index, ToItem)]
    internal var updates: [(Index, FromItem, Index, ToItem)]
    
    internal init(
        fromCollection: C1,
        toCollection: C2,
        isEqual: @escaping (FromItem, ToItem) -> Bool,
        isIdentical: ((FromItem, ToItem) -> Bool)?
        )
    {
        self.fromCollection = fromCollection
        self.fromIterator = fromCollection.makeIterator()
        self.toCollection = toCollection
        self.isEqual = isEqual
        self.isIdentical = isIdentical ?? isEqual
        nextFromIndex = fromCollection.startIndex
        insertions = []
        deletions = []
        moves = []
        updates = []
        isPrepared = false
    }
    
    internal override func next() -> Element? {
        prepareIfNeeded()
        
        var nextAction = dequeueAction()
        
        while nextAction.shouldSkip && !nextAction.shouldTerminate {
            nextAction = dequeueAction()
        }
        
        switch nextAction {
        case let .pop(element):     return element
        case .skip:                 preconditionFailure(
            "Cannot get a diff result from a skip action."
            )
        case .terminate:            return nil
        }
    }
    
    internal func prepareIfNeeded() {
        if !isPrepared {
            let underestimatedFromItemCount =
                fromCollection.underestimatedCount
            let underestimatedToItemCount =
                toCollection.underestimatedCount
            
            let underestimatedMaxInsertsionCount =
            underestimatedToItemCount
            let underestimatedMaxDeletionCount =
            underestimatedFromItemCount
            let underestimatedMaxUpdateCount = max(
                underestimatedFromItemCount,
                underestimatedToItemCount
            )
            
            insertions.reserveCapacity(underestimatedMaxInsertsionCount)
            deletions.reserveCapacity(underestimatedMaxDeletionCount)
            updates.reserveCapacity(underestimatedMaxUpdateCount)
            moves.reserveCapacity(underestimatedMaxUpdateCount)
            
            assert(preparedToItems == nil)
            preparedToItems = toCollection.indices.map {
                let toItem = toCollection[$0]
                return .init(index: $0, item: toItem)
            }
            isPrepared = true
        }
    }
    
    internal func dequeueAction() -> Action {
        if let fromItem = fromIterator.next() {
            
            let fromIndex = nextFromIndex
            
            nextFromIndex = fromCollection.index(after: nextFromIndex)
            
            for preparedToItem in preparedToItems {
                
                let toIndex = preparedToItem.index
                let toItem = preparedToItem.item
                
                guard !preparedToItem.hasRelativeFromItem else {
                    continue
                }
                
                // Alway sets prepared element's `hasRelativeFromItem`
                // property with the result of checking elements' equality.
                if isEqual(fromItem, toItem) {
                    
                    preparedToItem.hasRelativeFromItem = true
                    
                    if isIdentical(fromItem, toItem) {
                        if fromIndex == toIndex {
                            return .pop(.identical(fromIndex, fromItem, toIndex, toItem))
                        } else {
                            moves.append((fromIndex, fromItem, toIndex, toItem))
                        }
                    } else {
                        updates.append((fromIndex, fromItem, toIndex, toItem))
                        
                        if fromIndex != toIndex {
                            moves.append((fromIndex, fromItem, toIndex, toItem))
                        }
                    }
                    
                    return .skip
                }
            }
            
            deletions.append((fromIndex, fromItem))
            
            return .skip
            
        } else if let insertion = dequeueInsertion() {
            insertions.append(insertion)
            return .skip
        } else {
            if let (fromIndex, fromItem, toIndex, toItem) = updates.first {
                updates.removeFirst()
                return .pop(.update(fromIndex, fromItem, toIndex, toItem))
            }
            
            if let (fromIndex, fromItem, toIndex, toItem) = moves.first {
                moves.removeFirst()
                return .pop(.move(fromIndex, fromItem, toIndex, toItem))
            }
            
            if let (fromIndex, fromItem) = deletions.last {
                deletions.removeLast()
                return .pop(.deletion(fromIndex, fromItem))
            }
            
            if let (toIndex, toItem) = insertions.first {
                insertions.removeFirst()
                return .pop(.insertion(toIndex, toItem))
            }
            
            assert(updates.count == 0)
            assert(deletions.count == 0)
            assert(moves.count == 0)
            assert(insertions.count == 0)
            assert(preparedToItemsIterator.next() == nil)
            
            return .terminate
        }
    }
    
    internal func dequeueInsertion() -> (Index, ToItem)? {
        var anyPreparedToItem: PreparedToItem?
        
        repeat {
            anyPreparedToItem = preparedToItemsIterator.next()
        } while anyPreparedToItem?.hasRelativeFromItem == true
        
        if let preparedToItem = anyPreparedToItem {
            return (preparedToItem.index, preparedToItem.item)
        }
        
        return nil
    }
    
    internal typealias PreparedToItem = _CollectionComparisonDiffPreparedToItem<Index, ToItem>
    
    internal typealias PreparedToItemsIterator = Array<PreparedToItem>.Iterator
    
    internal typealias Action = _CollectionComparisonDiffIteratorAction<C1, C2>
}
