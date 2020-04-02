//
//  DrawingBoard.swift
//  LYGraffiti
//
//  Created by 周子聪 on 4/2/20.
//  Copyright © 2020 Laoyou. All rights reserved.
//

import UIKit

public class DrawingBoard: UIView {

    public var brushImage: UIImage?

    public init(brushImage: UIImage?) {
        super.init(frame: .zero)
        self.brushImage = brushImage
        
        self.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(ges:)))
        self.addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pan(ges: UIPanGestureRecognizer) {
        print(ges.translation(in: self))
    }
}
