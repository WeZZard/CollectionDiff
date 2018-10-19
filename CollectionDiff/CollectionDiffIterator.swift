//
//  CollectionDiffIterator.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//


public struct CollectionDiffIterator<
    C1: Collection,
    C2: Collection
    >: IteratorProtocol where C1.Index == C2.Index
{
    public typealias Element = Differential<C1, C2>
    
    internal typealias _Core = _CollectionDiffIteratorCore<C1, C2>
    
    internal var _core: _Core
    
    internal init(core: _Core) { _core = core }
    
    public mutating func next() -> Element? { return _core.next() }
}
