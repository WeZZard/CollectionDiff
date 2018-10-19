//
//  Differential.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//


public enum Differential<C1: Collection, C2: Collection>:
    CustomStringConvertible,
    CustomDebugStringConvertible where C1.Index == C2.Index
{
    public typealias FromCollection = C1
    
    public typealias ToCollection = C2
    
    public typealias Index = C1.Index
    
    public typealias FromItem = FromCollection.Element
    
    public typealias ToItem = ToCollection.Element
    
    case identical(Index, FromItem, Index, ToItem)
    case update(Index, FromItem, Index, ToItem)
    case move(Index, FromItem, Index, ToItem)
    case deletion(Index, FromItem)
    case insertion(Index, ToItem)
    
    public var description: String {
        switch self {
        case let .identical(fromIndex, fromItem, toIndex, toItem):
            return "Identical; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .update(fromIndex, fromItem, toIndex, toItem):
            return "Update; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .move(fromIndex, fromItem, toIndex, toItem):
            return "Move; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .insertion(toIndex, toItem):
            return "Insertion; To-Index: \(toIndex); To-Item: \(toItem)"
        case let .deletion(fromIndex, fromItem):
            return "Deletion; From-Index: \(fromIndex); From-Item: \(fromItem)"
        }
    }
    
    public var debugDescription: String {
        return "<\(type(of: self)); \(description)>"
    }
}
