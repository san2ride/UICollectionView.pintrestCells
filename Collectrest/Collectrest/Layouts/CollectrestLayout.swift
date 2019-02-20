//
//  CollectrestLayout.swift
//  Collectrest
//
//  Created by Jason Sanchez on 2/19/19.
//  Copyright © 2019 Jason Sanchez. All rights reserved.
//

import UIKit

protocol CollectrestLayoutDelegate: class {
    
    func collectionView(collectionView: UICollectionView, heightForPhotoAtIndexPath
        indexPath: IndexPath) -> CGFloat
}

class CollectrestLayout: UICollectionViewLayout {
    
    weak var delegate: CollectrestLayoutDelegate!
    
    // Configuring Layout
    private var numberOfColumns = 2
    private var cellPadding: CGFloat = 6
    
    // Array to cache the calculated attributes
    private var cache = [UICollectionViewLayoutAttributes]()
    
    // Store the content size
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    // Overrides method to return size of cllections view contents
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    // Calculating layout attributes
    override func prepare() {
        guard  cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        // declares xOffset/yOffset
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            // Frame Calculation
            let photoHeight = delegate.collectionView(collectionView: collectionView, heightForPhotoAtIndexPath: indexPath)
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // Creates an instance of UICollectionViewLayoutAttribute
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // Expands contentHeight to account for the fram of the newly calculated item
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibkeLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
    // Iterate through the attributes in cache and check their frames intersect with rect, which is provided by the collection view
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibkeLayoutAttributes.append(attributes)
            }
        }
        return visibkeLayoutAttributes
    }
    
    // Retrieve and return from cache the layout attributes which corresponds to the requested indexPath
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}


