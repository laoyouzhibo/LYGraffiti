//
//  PlayingBoard.swift
//  LYGraffiti
//
//  Created by 周子聪 on 4/4/20.
//  Copyright © 2020 Laoyou. All rights reserved.
//

import UIKit

class PlayingBoard: UIView {

    let totalDuration: TimeInterval = 4
    let stayDuration: TimeInterval = 1
    let dismissDuration: TimeInterval = 0.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = false
    }
    
    deinit {
        print("PlayingBoard deinit")
    }
    
    /// 播放图片轨迹动画，调用前需确保frame.size正确
    /// - Parameters:
    ///   - imageCoordinatesResult: 图片轨迹坐标
    ///   - images: Key: 图片id, Value: id对应的图片
    ///   - imageSize: 图片最终显示的大小, 单位point, nil代表sizeToFit
    ///   - completion: 动画完成的回调
    func play(imageCoordinatesResult: ImageCoordinatesResult, images: [String: UIImage], imageSize: CGSize?, completion: @escaping () -> Void) {
        
        guard let _ = self.superview else {
            return
        }
        /// DrawingBoard相对于当前PlayingBoard的坐标轴缩放比例
        let axisXScale = imageCoordinatesResult.size.width / self.frame.width
        let axisYScale = imageCoordinatesResult.size.height / self.frame.height
        
        let singleDuration = (totalDuration - stayDuration) / Double(imageCoordinatesResult.points.count)
        
        var imageViews: [UIImageView] = []
        
        for imageCoordinate in imageCoordinatesResult.points {
            guard let image = images[imageCoordinate.id] else { continue }
            
            let imageView = UIImageView(image: image)
            imageView.transform = .init(scaleX: 0.3, y: 0.3)
            imageView.alpha = 0
            if let size = imageSize {
                imageView.contentMode = .scaleAspectFill
                imageView.frame.size = size
            } else {
                imageView.sizeToFit()
            }
            imageView.center = CGPoint(x: imageCoordinate.point.x / axisXScale, y: imageCoordinate.point.y / axisYScale)
            addSubview(imageView)
            imageViews.append(imageView)

        }
        
        playSingleAnimation(imageViews: imageViews, index: 0, duration: singleDuration) {
            UIView.animate(withDuration: self.dismissDuration, delay: self.stayDuration, animations: {
                for imgView in imageViews {
                    imgView.alpha = 0
                    imgView.transform = .init(scaleX: 2, y: 2)
                }
            }, completion: { _ in
                for imgView in imageViews {
                    imgView.removeFromSuperview()
                }
                completion()
            })
        }
    }

    private func playSingleAnimation(imageViews: [UIImageView], index: Int, duration: TimeInterval, completion: @escaping () -> Void) {
        guard index >= 0 && index < imageViews.count else {
            return
        }
        let imageView = imageViews[index]
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            imageView.transform = .identity
            imageView.alpha = 1
        }, completion: { _ in
            if index == imageViews.count - 1 {
                completion()
            } else {
                self.playSingleAnimation(imageViews: imageViews, index: index+1, duration: duration, completion: completion)
            }
        })
    }
}
