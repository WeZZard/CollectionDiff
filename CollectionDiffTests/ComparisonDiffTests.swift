//
//  ComparisonDiffTests.swift
//  CollectionDiff
//
//  Created by WeZZard on 19/10/2018.
//

import XCTest

@testable
import CollectionDiff


class ComparisonDiffTests: XCTestCase {
    // MARK: Random Strings Diffing
    func testRandomCollectionDiffing() {
        
        var stringAccessCount = 0
        
        for _ in 0..<strings.count {
            let fromString = strings[stringAccessCount % strings.count]
            stringAccessCount = (stringAccessCount + 1)
            let toString = strings[stringAccessCount % strings.count]
            stringAccessCount = (stringAccessCount + 1)
            
            var fromCollectionRecovered = toString.map({JustEquatable($0)})
            
            let fromCollection = fromString.map({JustEquatable($0)})
            let toCollection = toString.map({JustEquatable($0)})
            
            typealias C = [JustEquatable<Character>]
            
            var deletions: [Differential<C, C>] = []
            var moves: [Differential<C, C>] = []
            var noChanges: [Differential<C, C>] = []
            var insertions: [Differential<C, C>] = []
            
            for each in fromCollection.diff(to: toCollection) {
                switch each {
                case .identical:
                    noChanges.append(each)
                case .deletion:
                    deletions.append(each)
                case .move:
                    moves.append(each)
                case .insertion:
                    insertions.append(each)
                default: break
                }
            }
            
            var removedIndices: [Int] = []
            
            for each in insertions {
                switch each {
                case let .insertion(index, _):
                    removedIndices.append(index)
                default:break
                }
            }
            
            removedIndices.sort(by: { (i1, i2) -> Bool in
                return i1 > i2
            })
            
            assert(toCollection.count == fromCollectionRecovered.count)
            
            var removed = 0
            for each in removedIndices {
                fromCollectionRecovered.remove(at: each)
                removed += 1
            }
            
            for each in deletions.reversed() {
                switch each {
                case let .deletion(index, character):
                    fromCollectionRecovered.insert(character, at: index)
                default:break
                }
            }
            
            for each in moves {
                switch each {
                case let .move(fromIndex, _, _, toCharacter):
                    fromCollectionRecovered.replaceSubrange(fromIndex...fromIndex, with: [toCharacter])
                default:break
                }
            }
            
            for each in noChanges {
                switch each {
                case let .identical(index, _, _, character):
                    fromCollectionRecovered.replaceSubrange(
                        index...index,
                        with: [character]
                    )
                default:break
                }
            }
            
            
            XCTAssert(fromCollectionRecovered == fromCollection,
                      "String diffing failed:\n\tFrom: \"\(fromString)\"\n\tTo: \"\(toString)\"\n\tRecovered: \"\(fromCollectionRecovered)\"")
        }
    }
    
    func testEmptyingANonEmptyCollection() {
        let toDelete = [11,22,33,44,55,66,77,88,99].map({JustEquatable($0)})
        
        let from = [11,22,33,44,55,66,77,88,99].map({JustEquatable($0)})
        
        let to: [JustEquatable<Int>] = []
        
        var deleted = [JustEquatable<Int>]()
        
        for eachDiff in from.diff(to: to) {
            switch eachDiff {
            case let .deletion(_, element):
                deleted.append(element)
            default:
                XCTAssert(false,
                          "\(eachDiff) occurred among dedicated deletions.")
            }
        }
        
        deleted.sort(by: {$0.element < $1.element})
        
        XCTAssert(deleted == toDelete, "Insert to empty collection failed")
    }
    
    func testFillingAnEmptyCollection() {
        let toAdd = [11,22,33,44,55,66,77,88,99].map({JustEquatable($0)})
        
        let from: [JustEquatable<Int>] = []
        
        let to = toAdd
        
        var added = [JustEquatable<Int>]()
        
        for eachDiff in from.diff(to: to) {
            switch eachDiff {
            case let .insertion(_, element):
                added.append(element)
            default:
                XCTAssert(false,
                          "\(eachDiff) occurred among dedicated insertions.")
            }
        }
        
        added.sort(by: {$0.element < $1.element})
        
        XCTAssert(added == toAdd, "Insert to empty collection failed.\n\tAdded: \(added)\n\tTo Add: \(toAdd).\n")
    }
    
    func testDiff() {
        var from: [JustEquatable<Int>] = []
        
        var to: [JustEquatable<Int>] = []
        
        let toAdd = [11,22,33,44,55,66,77,88,99].map({JustEquatable($0)})
        let toRemove = [0,2,4,6,8,10].map({JustEquatable($0)})
        let toMove = [1,3,5,7,9].map({JustEquatable($0)})
        let toBeNoChange = [23,33,55,67].map({JustEquatable($0)})
        
        var added: [JustEquatable<Int>] = []
        var removed: [JustEquatable<Int>] = []
        var moved: [JustEquatable<Int>] = []
        var noChange: [JustEquatable<Int>] = []
        var changed: [(JustEquatable<Int>, JustEquatable<Int>)] = []
        
        from = [0,1,2,3,4,5,6,7,8,9,10].map({JustEquatable($0)})
        to = {
            var to = from
            for eachToAdd in toAdd {
                let previous = JustEquatable(eachToAdd.element % 10)
                if let previousIndex = to.index(of: previous) {
                    to.insert(eachToAdd, at: previousIndex + 1)
                }
            }
            
            for eachToRemove in toRemove {
                if let index = to.index(of: eachToRemove) {
                    to.remove(at: index)
                }
            }
            
            for index in 0..<toMove.count/2 {
                let leftElement = toMove[index]
                let rightElement = toMove[(toMove.endIndex - 1) - index]
                if let leftIndex = to.index(of: leftElement),
                    let rightIndex = to.index(of: rightElement)
                {
                    to.remove(at: leftIndex)
                    to.insert(rightElement, at: leftIndex)
                    
                    to.remove(at: rightIndex)
                    to.insert(leftElement, at: rightIndex)
                }
            }
            
            for eachToBeStationary in toBeNoChange {
                from.insert(eachToBeStationary, at: 0)
                to.insert(eachToBeStationary, at: 0)
            }
            
            return to
        }()
        
        for eachDiff in from.diff(to: to) {
            switch eachDiff {
            case let .insertion(_, element):
                added.append(element)
            case let .deletion(_, element):
                removed.append(element)
            case let .update(_, fromElement, _, toElement):
                let change = (fromElement, toElement)
                changed.append(change)
            case let .move(_, fromElement, _, _):
                moved.append(fromElement)
            case let .identical(_, _, _, element):
                noChange.append(element)
            }
        }
        
        added.sort(by: {$0.element < $1.element})
        removed.sort(by: {$0.element < $1.element})
        moved.sort(by: {$0.element < $1.element})
        noChange.sort(by: {$0.element < $1.element})
        
        XCTAssert(toAdd == added,
                  "Diffing added items doesn't pass:\n\tTo add:\(toAdd)\n\tAdded:\(added)\n\n\tFrom:\(from)\n\tTo:\(to)\n")
        XCTAssert(toRemove == removed,
                  "Diffing removed items doesn't pass:\n\tTo Remove:\(toRemove)\n\tRemoved:\(removed)\n\n\tFrom:\(from)\n\tTo:\(to)\n")
        XCTAssert(toMove == moved,
                  "Diffing moved items doesn't pass:\n\tTo move:\(toMove)\n\tMoved:\(moved)\n\n\tFrom:\(from)\n\tTo:\(to)\n")
        XCTAssert(toBeNoChange == noChange,
                  "Equatable-diff-from no-change items inspecting doesn't pass:\n\tTo be no-change:\(toBeNoChange)\n\tNo-Change: \(noChange)\n\n\tFrom:\(from)\n\tTo:\(to)\n")
        XCTAssert(changed.isEmpty,
                  "Diffing changed items doesn't pass:\n\tChanged:\(changed)\n\n\tFrom:\(from)\n\tTo:\(to)\n")
    }
}
