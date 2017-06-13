//
//  cardCollectionViewController.swift
//  cardCollectionViewDemo
//
//  Created by xiangyu on 2017/6/1.
//  Copyright © 2017年 xiangyu. All rights reserved.
//

import UIKit
let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height
let cardHeight: CGFloat = UIScreen.main.bounds.size.height - 44  - 64 - 80 * screemSizeRatio
var cardWidth : CGFloat {
  return cardHeight * 0.685
}

func synchronized(_ lock: Any, closure: () -> ()) {
  objc_sync_enter(lock)
  closure()
  objc_sync_exit(lock)
}

class cardCollectionViewController: UIViewController {
  fileprivate let identifier = "cardCollectionViewCell"
  fileprivate var pages = 1
  fileprivate var limit = 10 // 每页限定10条数据
  
  private var isLeft: Bool?
  fileprivate var allDataSource: [UIImage] = [] // 需要显示的所有数据
  fileprivate var dataSource: [UIImage] = [] // 屏幕上显示的cell数据源
  fileprivate var insertIndex = 0 // 从allDataSource中拿一条数据 插入到dataSource中
  fileprivate var visibleCellsCount = 4 // 屏幕上显示cell的个数
  var collectionView: UICollectionView?
  fileprivate var isAnimating = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    // Do any additional setup after loading the view.
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard self.allDataSource.count == 0 else { return }
    requestData(false)
  }
  
  private func setupCollectionView() {
    
    let collectionViewFlowLayout = cardCollectionViewFlowLayout()
    addPanGest()
    
    collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 44 - 64), collectionViewLayout: collectionViewFlowLayout)
    collectionView?.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    collectionView?.scrollsToTop = false
    
    collectionView?.register(UINib(nibName: "cardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
    collectionView?.dataSource = self
    collectionView?.delegate = self
    self.view.addSubview(collectionView!)
    collectionView?.layoutIfNeeded()
  }
  private func addPanGest() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestHandle(_:)))
    view.addGestureRecognizer(panGesture)
  }
  
  fileprivate func requestData(_ refreshNext: Bool) {
    
    var array = [UIImage]()
    for i in 0..<10 {
      guard let image = UIImage(named: "image\(i)") else { return }
      array.append(image)
    }
    
    self.pages += refreshNext && array.count >= limit ? 1 : 0
    synchronized(self.dataSource) {
      self.allDataSource.append(contentsOf: array)
      if self.pages == 1 {
        if array.count > self.visibleCellsCount {
          self.dataSource.append(contentsOf: array[0,1,2,3])
          self.insertIndex = self.visibleCellsCount
        } else {
          self.dataSource.append(contentsOf: array)
          self.insertIndex = 0
        }
      }
    }
    self.collectionView?.reloadData()
  }
  
  @objc private func panGestHandle(_ panGest: UIPanGestureRecognizer) {
    guard !isAnimating else { return }
    guard let cell = ((collectionView?.cellForItem(at:IndexPath(row: 0, section: 0) )) as? cardCollectionViewCell), self.allDataSource.count > 1 else {
      return
    }
    guard let lastCell = (collectionView?.cellForItem(at:IndexPath(row: 3, section: 0))) else {
      return
    }
    let movePoint = panGest.translation(in: view)
    collectionView?.movetoPoint = movePoint
    if (panGest.state == .changed) {
      cell.center = CGPoint(x: cell.center.x + movePoint.x, y: cell.center.y + movePoint.y )
      cell.currentAngle = (cell.center.x - cell.frame.size.width / 2.0) / cell.frame.size.width / 4.0;
      cell.transform = CGAffineTransform(rotationAngle: cell.currentAngle!)
      
      let movePointOffset = CGPoint(x: cell.center.x - (cell.originalCenter?.x ?? 0), y: cell.center.y - (cell.originalCenter?.y ?? 0))
      isLeft = (movePointOffset.x < 0)
      let _ = collectionView?.visibleCells.filter({$0 !== cell && $0 !== lastCell}).map({
        guard let card = $0 as? cardCollectionViewCell else { return }
        card.resetlayoutWithOffset(movePointOffset)
      })
      panGest.setTranslation(.zero, in: view)
      
    } else if (panGest.state == .ended) {
      let vel = panGest.velocity(in: view)
      let centerOffsetX = UIScreen.main.bounds.size.width / 3.0
      
      if (vel.x > centerOffsetX || vel.x < -centerOffsetX)  {
        self.remove()
        return ;
      }
      if (cell.frame.origin.x + cell.frame.size.width > 150 && cell.frame.origin.x < cell.frame.size.width - 150) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
          cell.center = cell.originalCenter!
          cell.transform = CGAffineTransform(rotationAngle: 0)
          let _ = self.collectionView?.visibleCells.filter({$0 !== cell && $0 !== lastCell}).map({
            guard let card = $0 as? cardCollectionViewCell else { return }
            card.resetlayoutWithOffset(.zero)
          })
        })
      } else {
        self.remove()
      }
    }
  }
  
  private func remove() {
    isAnimating = true
    let cell = collectionView?.cellForItem(at:IndexPath(row: 0, section: 0) ) as! cardCollectionViewCell
    UIView.animate(withDuration: 0.3, animations: {
      // left
      if (self.isLeft!) {
        cell.center = CGPoint(x: -cell.frame.size.width / 2, y: cell.center.y - cell.currentAngle! * cell.frame.size.height);
      } else { // right
        cell.center = CGPoint(x: screenWidth + cell.frame.size.width / 2, y: cell.center.y + cell.currentAngle! * cell.frame.size.height);
      }
    })
    let user = self.dataSource.first
    cell.alpha = 0
    cell.center = cell.originalCenter!
    if self.insertIndex >= self.allDataSource.count {
      self.insertIndex = 0
    }
    self.dataSource.remove(at: 0)
    self.collectionView?.deleteItems(at: [IndexPath(item: 0, section: 0)])
    self.collectionView?.performBatchUpdates({
      self.dataSource.append(self.allDataSource[self.insertIndex])
      let insert = min(self.visibleCellsCount - 1, self.allDataSource.count - 1)
      self.collectionView?.insertItems(at: [IndexPath(item: insert, section: 0)])
      
    }, completion: { (comlete) in
      self.isAnimating = !comlete
      // 计算可见cell的indexpath值
      let cell1 = self.collectionView?.cellForItem(at:IndexPath(row: 0, section: 0) ) as! cardCollectionViewCell
      let lastCell = self.collectionView?.cellForItem(at:IndexPath(row: 3, section: 0) ) as! cardCollectionViewCell
      let _ = self.collectionView?.visibleCells.filter({$0 !== cell1 && $0 !== lastCell}).map({
        guard let card = $0 as? cardCollectionViewCell else { return }
        card.indexPathItem -= 1
      })
    })
    
    self.insertIndex += 1
    if self.insertIndex == (self.pages - 1) * 10 + 7 {
      self.requestData(true)
    }
  }
}

extension cardCollectionViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! cardCollectionViewCell
    cell.indexPathItem = indexPath.row
    let image = dataSource[indexPath.row]
    cell.imageView.image = image
    return cell
  }
}

extension cardCollectionViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }
}

extension UICollectionView {
  private static var movetoPointKey: Character!
  var movetoPoint: CGPoint {
    set {
      objc_setAssociatedObject(self, &UICollectionView.movetoPointKey, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
    get {
      return (objc_getAssociatedObject(self, &UICollectionView.movetoPointKey) as? CGPoint) ?? CGPoint.zero
    }
    
  }
}

