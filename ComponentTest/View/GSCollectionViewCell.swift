//
//  GSCollectionViewCell.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/25.
//

import UIKit
import SnapKit

class GSCollectionViewCell: UICollectionViewCell {
    private var imageView:UIImageView!
    private var chooseView:ChooseStateView!
    private var pressGes:UILongPressGestureRecognizer!
    
    var delegate:GSCollectionViewCellDelegate?
    var isChosen:Bool = false{
        didSet{
            if isChosen != oldValue{
                chooseView.isChosen = isChosen
            }
        }
    }
    
    var isChoosing:Bool = false{
        didSet{
            if isChoosing{
                pressGes.isEnabled = false
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.chooseView.alpha = 1
                }, completion: nil)
            }else{
                pressGes.isEnabled = true
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.chooseView.alpha = 0
                }, completion: nil)
            }
        }
    }
    
    override var isHighlighted: Bool{
        didSet{
            if isHighlighted{
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
            }else{
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        }
    }
    
    var image:UIImage?{
        didSet{
            imageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        chooseView = ChooseStateView()
        chooseView.alpha = 0
        self.contentView.addSubview(chooseView)
        chooseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pressGes = UILongPressGestureRecognizer(target: self, action: #selector(turnOnChooseModel))
        pressGes.minimumPressDuration = 1
        self.addGestureRecognizer(pressGes)
    }
    
    @objc private func turnOnChooseModel(_ sender: UILongPressGestureRecognizer){
        if sender.state == .ended{
            delegate?.endLongPress(sender)
        }
    }
    
    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol GSCollectionViewCellDelegate:NSObjectProtocol {
    func beginLongPress(_ sender: UILongPressGestureRecognizer)
    func endLongPress(_ sender: UILongPressGestureRecognizer)
}
