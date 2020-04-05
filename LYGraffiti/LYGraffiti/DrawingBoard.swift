//
//  DrawingBoard.swift
//  LYGraffiti
//
//  Created by 周子聪 on 4/2/20.
//  Copyright © 2020 Laoyou. All rights reserved.
//

import UIKit

protocol DrawingBoardDelegate: AnyObject {
    func drawingBoard(_ drawingBoard: DrawingBoard)
}

public class DrawingBoard: UIView {

    private var imageSize: CGSize?
    private var gap: CGFloat = 50
    private var maxImageCount: Int = 100
    
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
    
    private var imageCoordinates: [ImageCoordinate] {
        return imageLocus.flatMap { $0 }
    }
    
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
        print("DrawingBoard deinit")
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
    ///   - gap: 连续画多个的间隔，默认值为50
    ///   - maxCount: 图片最大个数，默认值为100
    public func config(imageSize: CGSize?, gap: CGFloat = 50, maxCount: Int = 100) {
        self.imageSize = imageSize
        self.gap = gap
        self.maxImageCount = maxCount
    }
    
    /// 撤销一次绘制，注意：不要给DrawingBoard添加subview，因为此处实现是调用若干次self.subviews.last?.removeFromSuperview()
    public func undo() {
        if let lastImageLocus = imageLocus.popLast() {
            for _ in 0 ..< lastImageLocus.count {
                self.subviews.last?.removeFromSuperview()
            }
        }
    }
    
    /// 清空所有绘制，注意：不要给DrawingBoard添加subview，因为此处实现是将self.subviews全部调用removeFromSuperview()
    public func clear() {
        imageLocus = []
        for v in self.subviews {
            v.removeFromSuperview()
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let img = brushImage, let beganPoint = touches.first?.location(in: self) else { return }
        currentPoint = beganPoint
        
        addImageView(position: beganPoint, isContinuous: false)
        print("beganPoint: \(beganPoint)")
        
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let img = brushImage, let movedPoint = touches.first?.location(in: self) else { return }
        if movedPoint != currentPoint {
            currentPoint = movedPoint
            addImageViewIfCould()
            print("movedPoint: \(movedPoint)")
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let img = brushImage else { return }
        let endedPoint = touches.first?.location(in: self)
        print("endedPoint: \(endedPoint)")
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let img = brushImage else { return }
        let cancelledPoint = touches.first?.location(in: self)
        print("cancelledPoint: \(cancelledPoint)")
    }
    
    
    /// 添加图片视图
    /// - Parameters:
    ///   - position: 位置
    ///   - isContinuous: 是否为连续添加，如果是，撤销时则会连同上一次添加的一起删除
    @discardableResult
    private func addImageView(position: CGPoint, isContinuous: Bool) -> Bool {
        guard let img = brushImage, self.bounds.contains(position) else { return false }
        
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
        
        let coordinate = ImageCoordinate(id: img.id, point: position)

        if isContinuous {
            if var imageCoords = imageLocus.popLast() {
                imageCoords.append(coordinate)
                imageLocus.append(imageCoords)
            }
        } else {
            imageLocus.append([coordinate])
        }
        return true
    }
    
    private func addImageViewIfCould() {
        
        if let lastCenter = self.circleCenter, let startPoint = lastPoint, let endPoint = currentPoint {
            if let nextCircleCenter = getIntersectionPoint(circleCenter: lastCenter, radius: gap, startPoint: startPoint, endPoint: endPoint) {
                
                if addImageView(position: nextCircleCenter, isContinuous: true) {
                    // 迅速滑动时，lastPoint和currentPoint之间可能需要添加多个image
                    lastPoint = circleCenter
                    addImageViewIfCould()
                }
                
            }
        }
    }
    
    /// https://thecodeway.com/blog/?p=932
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
            print("u1: \(u1) u2: \(u2)")
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




//extension CGPath {
//    func points() -> [CGPoint]
//    {
//        var bezierPoints = [CGPoint]()
//        self.forEach(body: { (element: CGPathElement) in
//            let numberOfPoints: Int = {
//                switch element.type {
//                case .moveToPoint, .addLineToPoint: // contains 1 point
//                    return 1
//                case .addQuadCurveToPoint: // contains 2 points
//                    return 2
//                case .addCurveToPoint: // contains 3 points
//                    return 3
//                case .closeSubpath:
//                    return 0
//                @unknown default:
//                    return 0
//                }
//            }()
//            for index in 0..<numberOfPoints {
//                let point = element.points[index]
//                bezierPoints.append(point)
//            }
//        })
//        return bezierPoints
//    }
//
//    private func forEach(body: @escaping @convention(block) (CGPathElement) -> Void) {
//        typealias Body = @convention(block) (CGPathElement) -> Void
//        func callback(info: UnsafeMutableRawPointer, element: UnsafePointer<CGPathElement>) {
//            let body = unsafeBitCast(info, to: Body.self)
//            body(element.pointee)
//        }
//        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
//        self.apply(info: unsafeBody, function: callback as! CGPathApplierFunction)
//    }
//}
