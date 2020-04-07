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
        if drawingBoard == nil {
            let drawingBoard = DrawingBoard()
            drawingBoard.delegate = self
            self.drawingBoard = drawingBoard
            view.addSubview(drawingBoard)
            drawingBoard.frame = .init(x: 0, y: view.safeAreaInsets.top, width: view.bounds.width, height: view.bounds.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - 200)
        }
        
        if let image = sender.currentImage {
            drawingBoard.setBrush(id: "\(sender.tag)", image: image)
        }
    }
    
    @IBAction func undo(_ sender: Any) {
        drawingBoard?.undo()
    }
    
    @IBAction func clear(_ sender: Any) {
        drawingBoard?.clear()
    }
    
    @IBAction func send(_ sender: Any) {
        
        let jsonString = drawingBoard.imageCoordinatesResult.jsonString
        print(jsonString)
        self.drawingBoard.removeFromSuperview()
        
        if let imageCoordinatesResult = ImageCoordinatesResult(jsonString: jsonString) {
            play(imageCoordinatesResult: imageCoordinatesResult, images: ["0": #imageLiteral(resourceName: "gift1"), "1": #imageLiteral(resourceName: "gift2")], in: self.view, inset: .init(top: 20, left: 20, bottom: 20, right: 20))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

extension ViewController: DrawingBoardDelegate {
    func drawingBoard(_ drawingBoard: DrawingBoard, didDrawMax count: Int) {
        let alert = UIAlertController(title: nil, message: "最多绘制100个礼物", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
}
