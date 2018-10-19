//
//  _CollectionCountingDiffSequenceCore.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//


internal class _CollectionCountingDiffSequenceCore<
    C1: Collection,
    C2: Collection,
    I: Hashable
    >: _CollectionDiffSequenceCore<C1, C2> where C1.Index == C2.Index
{
    internal override func makeIterator() -> Iterator {
        return _CollectionCountingDiffIteratorCore(
            fromCollection: fromCollection,
            toCollection: toCollection,
            identifierForFromItem: identifierForFromItem,
            identifierForToItem: identifierForToItem,
            isIdentical: isIdentical
        )
    }
    
    internal typealias Identifier = I
    
    internal typealias FromItem = C1.Element
    
    internal typealias ToItem = C2.Element
    
    internal let isIdentical: ((FromItem, ToItem) -> Bool)
    
    internal let identifierForFromItem: (FromItem) -> Identifier
    
    internal let identifierForToItem: (ToItem) -> Identifier
    
    internal let fromCollection: C1
    
    internal let toCollection: C2
    
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
    }
}
