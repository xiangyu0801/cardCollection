//
//  Array+Extensions.swift
//  cardCollectionViewDemo
//
//  Created by xiangyu on 2017/6/1.
//  Copyright © 2017年 xiangyu. All rights reserved.
//


import Foundation
// 简单实现数组切片
extension Array {
  subscript(i1: Int, i2: Int, rest: Int...) -> [Element] {
    get {
      var result: [Element] = [self[i1], self[i2]]
      for index in rest {
        result.append(self[index])
      }
      return result
    }
    
    set (values) {
      for (index, value) in zip([i1, i2] + rest, values) {
        self[index] = value
      }
    }
  }
}
