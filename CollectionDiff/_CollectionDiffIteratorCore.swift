//
//  _CollectionDiffIteratorCore.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//


internal class _CollectionDiffIteratorCore<
    C1: Collection,
    C2: Collection
    >: IteratorProtocol where C1.Index == C2.Index
{
    internal typealias Element = Differential<C1, C2>
    
    internal func next() -> Element? {
        fatalError("Abstract")
    }
}
