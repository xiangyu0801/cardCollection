//
//  cardCollectionViewCell.swift
//  cardCollectionViewDemo
//
//  Created by xiangyu on 2017/6/1.
//  Copyright © 2017年 xiangyu. All rights reserved.
//

import UIKit

class cardCollectionViewCell: UICollectionViewCell {
  var originalCenter: CGPoint?
  var currentAngle: CGFloat?
  var indexPathItem = 0

  @IBOutlet weak var imageView: UIImageView!
  override func awakeFromNib() {
    super.awakeFromNib()
    let center_x = UIScreen.main.bounds.size.width / 2.0
    let center_y = (UIScreen.main.bounds.size.height - 44 - 64) / 2.0 - 20
    originalCenter = CGPoint(x: center_x, y: center_y)
    // Initialization code
  }
  
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    self.layer.zPosition = CGFloat(layoutAttributes.zIndex)
  }
  
  func resetlayoutWithOffset(_ offset: CGPoint = .zero) {
    let maxOffset = min(max(fabs(offset.x), fabs(offset.y)), 100) //
    let ratio = (1.0 - CGFloat(indexPathItem) * 0.1) + maxOffset / 1000
    let scale : CGFloat = min(ratio,1.0)
    let center_x = screenWidth / 2.0
    let center_y  = (screenHeight - 44 - 64) / 2.0  + ( cardHeight / 2 * (1 - scale)) + CGFloat(indexPathItem) * 20 - 20
    let newCenter_y = center_y - maxOffset / 5
    self.center = CGPoint(x: center_x, y: newCenter_y)
    self.transform = CGAffineTransform(scaleX: scale, y: scale)
  }
}
