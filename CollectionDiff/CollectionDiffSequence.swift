//
//  CollectionDiffSequence.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//


// MARK: CollectionDiffSequence
public struct CollectionDiffSequence<
    C1: Collection,
    C2: Collection
    >: Sequence where C1.Index == C2.Index
{
    public typealias FromItem = C1.Element
    
    public typealias ToItem = C2.Element
    
    public typealias Iterator = CollectionDiffIterator<C1, C2>
    
    public func makeIterator() -> Iterator {
        return .init(core: _core.makeIterator())
    }
    
    internal typealias _Core = _CollectionDiffSequenceCore<C1, C2>
    
    internal let _core: _Core
    
    public init(
        fromCollection: C1,
        toCollection: C2,
        isEqual: @escaping (FromItem, ToItem) -> Bool,
        isIdentical: ((FromItem, ToItem) -> Bool)?
        )
    {
        _core = _CollectionComparisonDiffSequenceCore(
            fromCollection: fromCollection,
            toCollection: toCollection,
            isEqual: isEqual,
            isIdentical: isIdentical
        )
    }
    
    public init<Identifier: Hashable>(
        fromCollection: C1,
        toCollection: C2,
        identifierForFromItem: @escaping (FromItem) -> Identifier,
        identifierForToItem: @escaping (ToItem) -> Identifier,
        isIdentical: @escaping ((FromItem, ToItem) -> Bool)
        )
    {
        _core = _CollectionCountingDiffSequenceCore(
            fromCollection: fromCollection,
            toCollection: toCollection,
            identifierForFromItem: identifierForFromItem,
            identifierForToItem: identifierForToItem,
            isIdentical: isIdentical
        )
    }
}
