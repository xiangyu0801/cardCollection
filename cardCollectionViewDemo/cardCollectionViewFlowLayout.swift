//
//  cardCollectionViewFlowLayout.swift
//  cardCollectionViewDemo
//
//  Created by xiangyu on 2017/6/1.
//  Copyright © 2017年 xiangyu. All rights reserved.
//

import UIKit
let screemSizeRatio = UIScreen.main.bounds.size.width / 320
func divmod(_ a:CGFloat,b:CGFloat) -> (quotient:CGFloat, remainder:CGFloat){
  return (a / b, a.truncatingRemainder(dividingBy: b))
}
// 1615 * 1105
class cardCollectionViewFlowLayout: UICollectionViewFlowLayout {
  fileprivate let cardHeight: CGFloat = UIScreen.main.bounds.size.height - 44  - 64 - 80 * screemSizeRatio
  fileprivate var cardWidth : CGFloat {
    return cardHeight * 0.685
  }
  fileprivate var numberOfItems : Int = 0
  /// 每个 cell 在 y 之间的距离
  fileprivate let cellCenterOffset_y : CGFloat = 20.0
  var start_offset_y : CGFloat = 0.0
  
  
  private var layoutAttributesArray: [UICollectionViewLayoutAttributes] = []
  override init() {
    super.init()
    self.collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    self.collectionView?.isPagingEnabled = true
    self.scrollDirection = .vertical
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func prepare() {
    super.prepare()
    var array : [UICollectionViewLayoutAttributes] = []
    
    self.numberOfItems = self.collectionView!.numberOfItems(inSection: 0)
    
    let itemCount = collectionView?.numberOfItems(inSection: 0)
    for i in 0 ..< itemCount! {
      let indexPath = IndexPath(item: i, section: 0)
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      let ratio = i > 2 ? 0.8 : 1.0 - CGFloat(indexPath.row) * 0.1
      let scale : CGFloat = min(ratio,1.0)
      
      let center_x = self.collectionView!.bounds.width / 2.0
      var center_y : CGFloat = 0
      if i >= 3 {
        center_y = self.collectionView!.bounds.height / 2.0 + ( self.cardHeight / 2 * (1 - scale)) + 2 * cellCenterOffset_y - 20
      } else {
        center_y  = self.collectionView!.bounds.height / 2.0  + ( self.cardHeight / 2 * (1 - scale)) + CGFloat(i) * cellCenterOffset_y - 20
      }
      
      attributes.center = CGPoint(x: center_x, y: center_y)
      attributes.bounds.size = CGSize(width: self.cardWidth, height: self.cardHeight)
      
      attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
      attributes.zIndex = 10000 - indexPath.row
      array.append(attributes)
    }
    self.layoutAttributesArray = array
    
  }
  //  override func prepareForTransition(from oldLayout: UICollectionViewLayout) {
  //
  //  }
  override var collectionViewContentSize: CGSize {
    return CGSize(width: self.collectionView!.bounds.width  , height: self.collectionView!.bounds.height)
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return self.layoutAttributesArray[indexPath.row]
  }
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return self.layoutAttributesArray
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  /// 吸附到固定的位置
  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    //        print("offset:\(proposedContentOffset)")
    var targetContentOffset = proposedContentOffset
    let (total,more) = divmod(targetContentOffset.y, b: cellCenterOffset_y)
    if more > 0.0 {
      if more >= cellCenterOffset_y / 2.0 {
        targetContentOffset.y = ceil(total) * cellCenterOffset_y
      }
      else {
        targetContentOffset.y = floor(total) * cellCenterOffset_y
      }
    }
    return targetContentOffset
  }
}
