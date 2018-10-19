//
//  _CollectionComparisonDiffSequenceCore.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//


internal class _CollectionComparisonDiffSequenceCore<
    C1: Collection,
    C2: Collection
    >: _CollectionDiffSequenceCore<C1, C2> where C1.Index == C2.Index
{
    internal override func makeIterator() -> Iterator {
        return _CollectionComparisonDiffIteratorCore(
            fromCollection: fromCollection,
            toCollection: toCollection,
            isEqual: isEqual,
            isIdentical: isIdentical
        )
    }
    
    internal typealias Item1 = C1.Element
    
    internal typealias Item2 = C2.Element
    
    internal let isEqual: (Item1, Item2) -> Bool
    
    internal let isIdentical: (Item1, Item2) -> Bool
    
    internal let fromCollection: C1
    
    internal let toCollection: C2
    
    internal init(
        fromCollection: C1,
        toCollection: C2,
        isEqual: @escaping (Item1, Item2) -> Bool,
        isIdentical: ((Item1, Item2) -> Bool)?
        )
    {
        self.fromCollection = fromCollection
        self.toCollection = toCollection
        self.isEqual = isEqual
        self.isIdentical = isIdentical ?? isEqual
    }
}
