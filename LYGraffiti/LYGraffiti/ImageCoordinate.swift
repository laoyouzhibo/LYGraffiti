//
//  ImageCoordinate.swift
//  LYGraffiti
//
//  Created by 周子聪 on 4/3/20.
//  Copyright © 2020 Monologue. All rights reserved.
//

import Foundation
import UIKit


/// 图片的坐标信息，x、y均以像素为单位
public struct ImageCoordinate: Codable {
    
    public let id: String
    public let x: Int
    public let y: Int
    
    /// 将x、y的单位转化为point
    public var point: CGPoint {
        return CGPoint(x: CGFloat(x) / UIScreen.main.scale, y: CGFloat(y) / UIScreen.main.scale)
    }
    
    init(id: String, point: CGPoint) {
        self.id = id
        self.x = (UIScreen.main.scale * point.x).rounded()
        self.y = (UIScreen.main.scale * point.y).rounded()
    }
}

/// 涂鸦生成的Result，originalWidth、originalHeight代表画板大小，均以像素为单位
public struct ImageCoordinatesResult: Codable {
    public let points: [ImageCoordinate]
    public let originalWidth: Int
    public let originalHeight: Int
    
    /// 将宽、高的单位转化为point
    public var size: CGSize {
        return CGSize(width: CGFloat(originalWidth) / UIScreen.main.scale, height: CGFloat(originalHeight) / UIScreen.main.scale)
    }
    
    init(points: [ImageCoordinate], size: CGSize) {
        self.points = points
        self.originalWidth = (UIScreen.main.scale * size.width).rounded()
        self.originalHeight = (UIScreen.main.scale * size.height).rounded()
    }
    
    public init?(jsonString: String) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let data = jsonString.data(using: .utf8),
            let result = try? decoder.decode(ImageCoordinatesResult.self, from: data) {
            self.points = result.points
            self.originalWidth = result.originalWidth
            self.originalHeight = result.originalHeight
        } else {
            return nil
        }
    }
    
    public var jsonString: String {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let data = try? encoder.encode(self),
            let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "{}"
    }
    
    public var dictionaryValue: [String: Any] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let data = try? encoder.encode(self) {
            if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                return dict
            }
        }
        return [:]
    }
}

fileprivate extension CGFloat {
    
    /// 四舍五入为Int值
    func rounded() -> Int {
        let intPart = Int(self)
        let decimalPart = self - CGFloat(intPart)
        return decimalPart >= 0.5 ? intPart + 1 : intPart
    }
}
