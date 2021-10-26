//
//  ViewController.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/17.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let wave = Wave(frame: CGRect(x: self.view.center.x - 150, y: self.view.center.y - 150, width: 300, height: 300))
//        wave.waveColor = UIColor.systemBlue
//        wave.backgroundColor = UIColor(red: 176 / 255, green: 224 / 255, blue: 230 / 255, alpha: 0.5)
//        wave.layer.cornerRadius = 150
//        wave.clipsToBounds = true
//        self.view.addSubview(wave)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        let sheetController = SheetAlertController(sytle: .default)
//        sheetController.addItem(title: "Save to Camera roll", target: self, action: nil)
//        sheetController.addItem(title: "Share to Instagram", target: self, action: nil)
//        sheetController.addItem(title: "More", target: self, action: nil)

//        sheetController.message = "The content you selected will be deleted from the grid. This operation cannot be undone."
//        sheetController.addItem(title: "Delete", target: self, action: nil)
//        sheetController.addItem(title: "Cancel", target: self, action: nil)
        
//        self.present(sheetController, animated: false, completion: nil)
        
        let albumController = AlbumViewController()
        albumController.modalPresentationStyle = .custom
        self.present(albumController, animated: true, completion: nil)
    }
}

