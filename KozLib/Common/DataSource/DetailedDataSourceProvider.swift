//
//  DetailedDataSourceProvider.swift
//  KozLibrary
//
//  Created by Kelvin Kosbab on 8/28/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

#if os(watchOS)
import Foundation
#else
import UIKit
#endif

// MARK: - DetailedDataSourceProviderDelegate

protocol DetailedDataSourceProviderDelegate : class {
  func dataSourceDidUpdate()
  #if os(watchOS)
  func dataSourceDidUpdate(at rowIndex: Int)
  #else
  func dataSourceDidUpdate(section: Int, with animation: UITableView.RowAnimation)
  func dataSourceDidUpdate(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
  #endif
}

// MARK: - DetailedDataSourceProvider

protocol DetailedDataSourceProvider : class {
  associatedtype Content: DataSourceContent
  var currentContent: Content? { get set }
  var delegate: DetailedDataSourceProviderDelegate? { get set }
  func generateContent(completion: @escaping (_ content: Content) -> Void)
  #if os(watchOS)
  #else
  func updateContent(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
  #endif
}

extension DetailedDataSourceProvider {
  
  func updateContent() {
    self.generateContent { [weak self] content in
      
      guard let strongSelf = self else {
        return
      }
      
      strongSelf.currentContent = content
      strongSelf.delegate?.dataSourceDidUpdate()
    }
  }
  
  #if os(watchOS)
  
  // MARK: - watchOS
  
  func updateContent(at rowIndex: Int) {
    self.generateContent { [weak self] content in
      
      guard rowIndex < content.items.count, let strongSelf = self, let currentContent = strongSelf.currentContent else {
        return
      }
      
      // Update the current content
      var items = currentContent.items
      items[section] = content.items[rowIndex]
      let newContent = Content(items: items)
      strongSelf.currentContent = newContent
      
      // Notify delegate
      strongSelf.delegate?.dataSourceDidUpdate(at: rowIndex)
    }
  }
  
  func getItem(at rowIndex: Int) -> Self.Content.Item? {
    return self.currentContent?.getItem(at: rowIndex)
  }
  
  #else
  
  // MARK: - iOS / iOS Extension
  
  func updateContent(section: Int, with animation: UITableView.RowAnimation) {
    self.generateContent { [weak self] content in
      
      guard let strongSelf = self, let currentContent = strongSelf.currentContent, section < content.sectionTypes.count && section < currentContent.sectionTypes.count else {
        return
      }
      
      // Update the current content
      var sectionTypes = currentContent.sectionTypes
      sectionTypes[section] = content.sectionTypes[section]
      let newContent = Content(sectionTypes: sectionTypes)
      strongSelf.currentContent = newContent
      
      // Notify delegate
      strongSelf.delegate?.dataSourceDidUpdate(section: section, with: animation)
    }
  }
  
  func getSectionType(section: Int) -> Self.Content.SectionType? {
    return self.currentContent?.getSectionType(section: section)
  }
  
  func getRowType(at indexPath: IndexPath) -> Self.Content.SectionType.RowType? {
    return self.currentContent?.getSectionType(section: indexPath.section)?.getRowType(at: indexPath.row)
  }
  
  var numberOfSections: Int {
    return self.currentContent?.sectionTypes.count ?? 0
  }
  
  func getNumberOfItems(section: Int) -> Int {
    return self.getSectionType(section: section)?.rowTypes.count ?? 0
  }
  
  #endif
}