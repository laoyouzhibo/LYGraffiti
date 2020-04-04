//
//  ViewController.swift
//  LYGraffitiDemo
//
//  Created by 周子聪 on 4/2/20.
//  Copyright © 2020 Laoyou. All rights reserved.
//

import UIKit
import LYGraffiti

class ViewController: UIViewController {
    
    
    weak var drawingBoard: DrawingBoard!
    
    @IBAction func giftButtonClick(_ sender: UIButton) {
        if let image = sender.currentImage {
            drawingBoard.setBrush(id: "\(sender.tag)", image: image)
        }
    }
    
    @IBAction func undo(_ sender: Any) {
        drawingBoard.undo()
    }
    
    @IBAction func clear(_ sender: Any) {
        drawingBoard.clear()
    }
    
    @IBAction func send(_ sender: Any) {
        print(drawingBoard.imageCoordinatesResult.jsonString)
        OperationQueue.main.schedule(after: .init(Date().addingTimeInterval(5.0))) {
            self.drawingBoard.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let drawingBoard = DrawingBoard()
        self.drawingBoard = drawingBoard
        view.addSubview(drawingBoard)
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawingBoard?.frame = .init(x: 0, y: view.safeAreaInsets.top, width: view.bounds.width, height: view.bounds.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - 200)
    }
}

