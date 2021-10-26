//
//  RemlessButton.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/21.
//

import UIKit

class RemlessButton: GSButton {
    
    override var isHighlighted: Bool{
        didSet{
            if isHighlighted{
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
//                self.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), for: .normal)
            }else{
                self.backgroundColor = UIColor.white
//                self.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }

    init(frame: CGRect, title:String) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12 * ratio
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(UIColor.black, for: .normal)
        self.backgroundColor = UIColor.white
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18 * ratio, weight: .medium)
        self.contentHorizontalAlignment = .left
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20 * ratio, bottom: 0, right: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
