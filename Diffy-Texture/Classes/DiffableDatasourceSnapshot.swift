//
//  DiffableDatasourceSnapshot.swift
//  Diffy-Texture
//
//  Created by Daniel Hariri on 31.08.20.
//

import Foundation

public struct DiffableDataSourceSnapshot <SectionIdentifierType, ItemIdentifierType>
where SectionIdentifierType : Hashable, ItemIdentifierType : Hashable {
    
    struct Section: Hashable {
        
        var identifier: SectionIdentifierType
        var items: [ItemIdentifierType]
        
        init(identifier: SectionIdentifierType) {
            self.identifier = identifier
            self.items = []
        }
     
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    private(set) var sections: [Section] = []
    
    public var numberOfSections: Int {
        return sections.count
    }

    public func numberOfItems(inSection identifier: SectionIdentifierType) -> Int {
        guard let index = indexOfSection(identifier) else { return 0 }
        return sections[index].items.count
    }

    public func itemIdentifiers(inSection identifier: SectionIdentifierType) -> [ItemIdentifierType] {
        guard let index = indexOfSection(identifier) else { return [] }
        return sections[index].items
    }

    public func sectionIdentifier(containingItem identifier: ItemIdentifierType) -> SectionIdentifierType? {
        for section in sections {
            if section.items.contains(identifier) {
                return section.identifier
            }
        }
        return nil
    }

    public func indexOfItem(_ identifier: ItemIdentifierType) -> Int? {
        for section in sections {
            if let index = section.items.firstIndex(of: identifier) {
                return index
            }
        }
        return nil
    }

    public func indexOfSection(_ identifier: SectionIdentifierType) -> Int? {
        let sectionIdentifiers = sections.map { $0.identifier }
        return sectionIdentifiers.firstIndex(of: identifier)
    }

    public mutating func appendItems(
        _ identifiers: [ItemIdentifierType],
        toSection sectionIdentifier: SectionIdentifierType? = nil) {
        
        if let sectionIdentifier = sectionIdentifier {
            guard let index = indexOfSection(sectionIdentifier) else { return }
            sections[index].items += identifiers
        } else {
            guard sections.count > 0 else { return }
            sections[sections.count - 1].items += identifiers
        }
    }

    public mutating func insertItems(
        _ identifiers: [ItemIdentifierType],
        beforeItem beforeIdentifier: ItemIdentifierType
    ) {
        guard let sectionIdentifier = sectionIdentifier(containingItem: beforeIdentifier),
        let sectionIndex = indexOfSection(sectionIdentifier),
        let beforeItemIndex = indexOfItem(beforeIdentifier) else { return }
        let items = itemIdentifiers(inSection: sectionIdentifier)
        let leftItems = Array(items[0 ..< beforeItemIndex])
        let rightItems = Array(items[beforeItemIndex ..< items.count])
        sections[sectionIndex].items = leftItems + identifiers + rightItems
    }

    public mutating func insertItems(
        _ identifiers: [ItemIdentifierType],
        afterItem afterIdentifier: ItemIdentifierType
    ) {
        guard let sectionIdentifier = sectionIdentifier(containingItem: afterIdentifier),
        let sectionIndex = indexOfSection(sectionIdentifier),
        let afterItemIndex = indexOfItem(afterIdentifier) else { return }
        let items = itemIdentifiers(inSection: sectionIdentifier)
        let leftItems = Array(items[0 ... afterItemIndex])
        let rightItems = Array(items[afterItemIndex + 1 ..< items.count])
        sections[sectionIndex].items = leftItems + identifiers + rightItems
    }

    public mutating func deleteItems(_ identifiers: [ItemIdentifierType]) {
        for identifier in identifiers {
            guard let sectionIdentifier = sectionIdentifier(containingItem: identifier),
            let sectionIndex = indexOfSection(sectionIdentifier),
            let itemIndex = indexOfItem(identifier) else { continue }
            sections[sectionIndex].items.remove(at: itemIndex)
        }
    }

    public mutating func deleteAllItems() {
        for section in sections {
            guard let sectionIndex = indexOfSection(section.identifier) else { continue }
            sections[sectionIndex].items.removeAll()
        }
    }

    public mutating func reloadItems(_ identifiers: [ItemIdentifierType]) {
        for identifier in identifiers {
            guard let sectionIdentifier = sectionIdentifier(containingItem: identifier),
            let sectionIndex = indexOfSection(sectionIdentifier),
            let itemIndex = indexOfItem(identifier) else { continue }
            sections[sectionIndex].items[itemIndex] = identifier
        }
    }

    public mutating func appendSections(_ identifiers: [SectionIdentifierType]) {
        let newSections = identifiers.map { Section(identifier: $0) }
        self.sections += newSections
    }

    public mutating func deleteSections(_ identifiers: [SectionIdentifierType]) {
        for identifier in identifiers {
            guard let sectionIndex = indexOfSection(identifier) else { continue }
            sections.remove(at: sectionIndex)
        }
    }

    public mutating func reloadSections(_ identifiers: [SectionIdentifierType]) {
        for identifier in identifiers {
            guard let sectionIndex = indexOfSection(identifier) else { continue }
            let items = itemIdentifiers(inSection: identifier)
            var section = Section(identifier: identifier)
            section.items = items
            sections[sectionIndex] = section
        }
    }
}

