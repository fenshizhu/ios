//
//  BorderedButton.swift
//  gs cool
//
//  Created by zou jingbo on 2021/10/21.
//  Copyright © 2021 Greysh Co., Ltd. All rights reserved.
//

import UIKit

class BorderedButton: GSButton {
    
    override var isSelected: Bool{
        didSet{
            if isSelected{
                self.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
                self.setTitleColor(UIColor.white, for: .normal)
            }else{
                self.backgroundColor = UIColor.white
                self.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }

    init(frame: CGRect, title:String) {
        super.init(frame: frame)
        
        self.setTitle(title, for: .normal)
        
        self.layer.cornerRadius = 6 * ratio
        self.layer.borderWidth = 0.5 * ratio
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16 * ratio, weight: .medium)
        self.backgroundColor = UIColor.white
        self.setTitleColor(UIColor.black, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
