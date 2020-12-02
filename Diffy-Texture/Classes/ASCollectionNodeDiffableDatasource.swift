//
//  ASCollectionNodeDiffableDatasource.swift
//  Diffy-Texture
//
//  Created by Daniel Hariri on 31.08.20.
//

import AsyncDisplayKit

public class ASCollectionNodeDiffableDataSource<SectionIdentifierType, ItemIdentifierType>:
    NSObject,
    ASCollectionDataSource,
    ASCollectionDelegateFlowLayout where SectionIdentifierType : Hashable, ItemIdentifierType : Hashable {
    
    public typealias CellProvider = (ASCollectionNode, IndexPath, ItemIdentifierType) -> ASCellNode?
    public typealias SupplementaryNodeProvider = (ASCollectionNode, String, IndexPath) -> ASCellNode?
    
    private var cellProvider: CellProvider?
    public var supplementaryNodeProvider: SupplementaryNodeProvider?
    
    private var currentSnapshot = DiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
    private let collectionNode: ASCollectionNode
    
    public init(collectionNode: ASCollectionNode,
         cellProvider: @escaping CellProvider) {
        self.collectionNode = collectionNode
        super.init()
        self.cellProvider = cellProvider
        self.collectionNode.dataSource = self
    }
    
    deinit {
        cellProvider = nil
        supplementaryNodeProvider = nil
    }
    
    public func apply(
        _ snapshot: DiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil) {
        
        let oldSnapshot = currentSnapshot
        let newSnapshot = snapshot
        
        let sectionsDiff = newSnapshot.sections.difference(from: oldSnapshot.sections)
        
        let sectionDeletions = sectionsDiff.compactMap { element -> Int? in
            switch element {
            case .remove(let offset, _, _):
                return offset
            default:
                return nil
            }
        }
        
        let sectionInsertions = sectionsDiff.compactMap { element -> Int? in
            switch element {
            case .insert(let offset, _, _):
                return offset
            default:
                return nil
            }
        }
        
        let (itemDeletions, itemInsertions) =
            newSnapshot.sections.map { section -> ([IndexPath], [IndexPath]) in
            let newItems = newSnapshot.itemIdentifiers(inSection: section.identifier)
            let oldItems = oldSnapshot.itemIdentifiers(inSection: section.identifier)
            let itemsDiff = newItems.difference(from: oldItems)
            let sectionOldIndex = oldSnapshot.indexOfSection(section.identifier) ?? 0
            let sectionNewIndex = newSnapshot.indexOfSection(section.identifier) ?? 0
            
            let itemsDeletions = itemsDiff.compactMap { element -> IndexPath? in
                switch element {
                case .remove(let offset, _, _):
                    return IndexPath(item: offset, section: sectionOldIndex)
                default:
                    return nil
                }
            }
            
            let itemsInsertions = itemsDiff.compactMap { element -> IndexPath? in
                switch element {
                case .insert(let offset, _, _):
                    return IndexPath(item: offset, section: sectionNewIndex)
                default:
                    return nil
                }
            }
            return (itemsDeletions, itemsInsertions)
        }.reduce(([IndexPath](), [IndexPath]()), { result, partial in
            return (result.0 + partial.0, result.1 + partial.1)
        })
        
        if !animatingDifferences { UIView.setAnimationsEnabled(false) }
        collectionNode.performBatchUpdates({
            self.currentSnapshot = newSnapshot
            collectionNode.deleteSections(IndexSet(sectionDeletions))
            collectionNode.insertSections(IndexSet(sectionInsertions))
            collectionNode.deleteItems(at: itemDeletions)
            collectionNode.insertItems(at: itemInsertions)
        }, completion: { _ in
            completion?()
        })
        if !animatingDifferences { UIView.setAnimationsEnabled(true) }
    }

    public func snapshot() -> DiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        return currentSnapshot
    }
    
    // ASCollectionDataSource
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return currentSnapshot.numberOfSections
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        let section = currentSnapshot.sections[section]
        return currentSnapshot.numberOfItems(inSection: section.identifier)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let section = currentSnapshot.sections[indexPath.section]
        let items = currentSnapshot.itemIdentifiers(inSection: section.identifier)
        let item = items[indexPath.item]
        return cellProvider?(collectionNode, indexPath, item) ?? ASCellNode()
    }
    
    public func collectionNode(
        _ collectionNode: ASCollectionNode,
        nodeForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> ASCellNode {
        
        let flowLayout = collectionNode.collectionViewLayout as? UICollectionViewFlowLayout
        let isHorizontal = flowLayout?.scrollDirection == .horizontal
        
        let backupCell = ASCellNode()
        backupCell.style.width = ASDimension(unit: isHorizontal ? .points : .fraction, value: 1.0)
        backupCell.style.height = ASDimension(unit: isHorizontal ? .fraction : .points, value: 1.0)
        return supplementaryNodeProvider?(collectionNode, kind, indexPath) ?? backupCell
    }
}
