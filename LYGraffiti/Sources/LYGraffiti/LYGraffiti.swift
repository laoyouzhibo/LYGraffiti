//
//  LYGraffiti.swift
//  LYGraffiti
//
//  Created by 周子聪 on 4/5/20.
//  Copyright © 2020 Monologue. All rights reserved.
//

import UIKit

public func play(imageCoordinatesResult: ImageCoordinatesResult, images: [String: UIImage], imageSize: CGSize?, in view: UIView, inset: UIEdgeInsets, completion: @escaping () -> Void) {
    let playingBoard = PlayingBoard()
    view.addSubview(playingBoard)
        
    let maxWidth = view.bounds.width - inset.left - inset.right
    let maxHeight = view.bounds.height - inset.top - inset.bottom
    
    let originSize = imageCoordinatesResult.size
    
    if originSize.width / originSize.height > maxWidth / maxHeight {
        // 使用最大宽度等比缩放, 垂直居中
        let height = maxWidth / originSize.width * originSize.height
        let y = (view.bounds.height - height) / 2
        playingBoard.frame = .init(x: inset.left, y: y, width: maxWidth, height: height)
    } else {
        // 使用最大高度等比缩放, 水平居中
        let width = maxHeight / originSize.height * originSize.width
        let x = (view.bounds.width - width) / 2
        playingBoard.frame = .init(x: x, y: inset.top, width: width, height: maxHeight)
    }
    
    playingBoard.play(imageCoordinatesResult: imageCoordinatesResult, images: images, imageSize: imageSize) {
        playingBoard.removeFromSuperview()
        completion()
    }
}
