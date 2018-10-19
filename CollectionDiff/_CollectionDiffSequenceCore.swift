//
//  _CollectionDiffSequenceCore.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//

internal class _CollectionDiffSequenceCore<
    C1: Collection,
    C2: Collection
    >: Sequence where C1.Index == C2.Index
{
    internal typealias Iterator = _CollectionDiffIteratorCore<C1, C2>
    
    internal func makeIterator() -> Iterator {
        fatalError("Abstract")
    }
}
