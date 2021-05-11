//
//  DrawingBoard.swift
//  LYGraffiti
//
//  Created by 周子聪 on 4/2/20.
//  Copyright © 2020 Monologue. All rights reserved.
//

import UIKit

public protocol DrawingBoardDelegate: AnyObject {
    func drawingBoard(_ drawingBoard: DrawingBoard, shouldDrawItemAt index: Int, coordinate: ImageCoordinate) -> Bool
    func drawingBoard(_ drawingBoard: DrawingBoard, updateDrawCount count: Int)
}

public class DrawingBoard: UIView {

    public weak var delegate: DrawingBoardDelegate?
    
    private var imageSize: CGSize?
    private var minDistance: CGFloat = 35
    
    typealias BrushImage = (id: String, image: UIImage)
    private var brushImage: BrushImage?
    
    private var imageLocus: [[ImageCoordinate]] = []
    private var circleCenter: CGPoint?
    
    private var lastPoint: CGPoint?
    private var currentPoint: CGPoint? {
        didSet {
            lastPoint = oldValue
        }
    }
    
    public var isEmpty: Bool {
        return imageLocus.isEmpty
    }
    
    /// 当前涂鸦信息
    public var imageCoordinates: [ImageCoordinate] {
        return imageLocus.flatMap { $0 }
    }
    /// 代表当前画板及涂鸦信息。对imageCoordinates属性的一层封装，并加上了画板大小
    public var imageCoordinatesResult: ImageCoordinatesResult {
        return ImageCoordinatesResult(points: imageCoordinates, size: self.bounds.size)
    }
    
    public init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = false
        self.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = false
        self.backgroundColor = .black
    }
    
    deinit {
        // print("DrawingBoard deinit")
    }
    /// 设置笔刷为指定图片
    /// - Parameters:
    ///   - id: 图片的唯一标识, 生成图片轨迹坐标需要使用此id
    ///   - image: 笔刷的图片
    public func setBrush(id: String, image: UIImage) {
        self.brushImage = (id, image)
    }
    
    /// 配置一些参数
    /// - Parameters:
    ///   - imageSize: 图片大小，nil代表自适应
    ///   - minDistance: 连续画多个的间隔，默认值为35
    public func config(imageSize: CGSize?, minDistance: CGFloat = 35) {
        self.imageSize = imageSize
        self.minDistance = minDistance
    }
    
    /// 撤销一次绘制，注意：不要给DrawingBoard添加subview，因为此处实现是调用一次或多次self.subviews.last?.removeFromSuperview()
    public func undo() {
        if let lastImageLocus = imageLocus.popLast() {
            for _ in 0 ..< lastImageLocus.count {
                self.subviews.last?.removeFromSuperview()
            }
            updateDrawCount()
        }
    }
    
    /// 清空所有绘制，注意：不要给DrawingBoard添加subview，因为此处实现是将self.subviews全部调用removeFromSuperview()
    public func clear() {
        imageLocus = []
        for v in self.subviews {
            v.removeFromSuperview()
        }
        updateDrawCount()
    }
    
    private func updateDrawCount() {
        delegate?.drawingBoard(self, updateDrawCount: imageCoordinates.count)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = brushImage, let beganPoint = touches.first?.location(in: self) else { return }
        currentPoint = beganPoint
        
        addImageView(position: beganPoint, isContinuous: false)
        // print("beganPoint: \(beganPoint)")
        
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = brushImage, let movedPoint = touches.first?.location(in: self) else { return }
        if movedPoint != currentPoint {
            currentPoint = movedPoint
            addImageViewIfCould()
            // print("movedPoint: \(movedPoint)")
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard brushImage != nil, let endedPoint = touches.first?.location(in: self) else { return }
        
        circleCenter = nil
        currentPoint = nil
        lastPoint = nil
        // print("endedPoint: \(endedPoint)")
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard brushImage != nil, let cancelledPoint = touches.first?.location(in: self) else { return }
        circleCenter = nil
        currentPoint = nil
        lastPoint = nil
        // print("cancelledPoint: \(cancelledPoint)")
    }
    
    
    /// 添加图片视图
    /// - Parameters:
    ///   - position: 位置
    ///   - isContinuous: 是否为连续添加，如果是，撤销时则会连同上一次添加的一起删除
    @discardableResult
    private func addImageView(position: CGPoint, isContinuous: Bool) -> Bool {
        guard let img = brushImage, self.bounds.contains(position) else { return false }
        
        let coordinate = ImageCoordinate(id: img.id, point: position)
        let shouldDraw = delegate?.drawingBoard(self, shouldDrawItemAt: imageCoordinates.count, coordinate: coordinate) ?? true
        if !shouldDraw {
            return false
        }
        
        let imageView = UIImageView(image: img.image)
        if let size = imageSize {
            imageView.contentMode = .scaleAspectFill
            imageView.frame.size = size
        } else {
            imageView.sizeToFit()
        }
        imageView.center = position
        addSubview(imageView)
        
        circleCenter = position
        
        if isContinuous {
            if var imageCoords = imageLocus.popLast() {
                imageCoords.append(coordinate)
                imageLocus.append(imageCoords)
            }
        } else {
            imageLocus.append([coordinate])
        }
        updateDrawCount()
        return true
    }
    
    private func addImageViewIfCould() {
        
        if let lastCenter = self.circleCenter, let startPoint = lastPoint, let endPoint = currentPoint {
            if let nextCircleCenter = getIntersectionPoint(circleCenter: lastCenter, radius: minDistance, startPoint: startPoint, endPoint: endPoint) {
                
                if addImageView(position: nextCircleCenter, isContinuous: true) {
                    // 迅速滑动时，lastPoint和currentPoint之间可能需要添加多个image
                    lastPoint = circleCenter
                    addImageViewIfCould()
                }
                
            }
        }
    }
    
    /// 求圆与线段的交点，参考自：https://thecodeway.com/blog/?p=932
    /// 没有交点返回nil，两个交点返回其中一个
    private func getIntersectionPoint(circleCenter: CGPoint, radius: CGFloat, startPoint: CGPoint, endPoint: CGPoint) -> CGPoint? {
        guard startPoint != endPoint else { return nil }
        let A = (endPoint.x-startPoint.x)*(endPoint.x-startPoint.x)+(endPoint.y-startPoint.y)*(endPoint.y-startPoint.y)
        let B = 2*((endPoint.x-startPoint.x)*(startPoint.x-circleCenter.x)+(endPoint.y-startPoint.y)*(startPoint.y-circleCenter.y))
        let C = circleCenter.x*circleCenter.x+circleCenter.y*circleCenter.y+startPoint.x*startPoint.x+startPoint.y*startPoint.y-2*(circleCenter.x*startPoint.x+circleCenter.y*startPoint.y)-radius*radius
        
        let condition: CGFloat = B*B-4*A*C
        if condition < 0 {
            return nil
        } else {
            let sqrtCondition = sqrt(condition)
            let u1 = (-B + sqrtCondition)/(2*A)
            let u2 = (-B - sqrtCondition)/(2*A)
            // print("u1: \(u1) u2: \(u2)")
            if u1 >= 0 && u1 <= 1 {
                let x = startPoint.x+u1*(endPoint.x-startPoint.x)
                let y = startPoint.y+u1*(endPoint.y-startPoint.y)
                return CGPoint(x: x, y: y)
            }
            if u2 >= 0 && u2 <= 1 {
                let x = startPoint.x+u2*(endPoint.x-startPoint.x)
                let y = startPoint.y+u2*(endPoint.y-startPoint.y)
                return CGPoint(x: x, y: y)
            }
            return nil
        }
    }
}
