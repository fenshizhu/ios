//
//  NavBar.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/22.
//

import UIKit
import SnapKit

class NavBar: UIView {
    
    private var headingLabel:UILabel!
    private var imgView:UIImageView!
    
    var leftItem:UIButton?{
        willSet{
            leftItem?.removeFromSuperview()
        }
        
        didSet{
            if let leftItem = leftItem{
                self.addSubview(leftItem)
                leftItem.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(10)
                    make.width.height.equalTo(44)
                }
            }
        }
    }
    
    var rightItem:UIButton?{
        willSet{
            rightItem?.removeFromSuperview()
        }
        
        didSet{
            if let rightItem = rightItem{
                self.addSubview(rightItem)
                rightItem.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.right.equalTo(-10)
                    make.width.height.equalTo(44)
                }
            }
        }
    }
    
    var heading:String?{
        didSet{
            headingLabel.text = heading
        }
    }
    
    weak var delegate:NavBarDelegate?
    
    var isOpen:Bool = false{
        didSet{
            if isOpen{
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    self.imgView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                } completion: { finished in
                    if finished{
                        self.delegate?.openDropDownList()
                    }
                }
            }else{
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    self.imgView.transform = CGAffineTransform.identity
                } completion: { finished in
                    if finished{
//                        self.imgView.transform = CGAffineTransform.identity
                        self.delegate?.closeDropDownList()
                    }
                }

            }
        }
    }
    
    private func addView(){
        self.backgroundColor = UIColor.white
        
        headingLabel = UILabel()
        headingLabel.textAlignment = .center
        headingLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1,alpha:1)
        headingLabel.font = UIFont.systemFont(ofSize: 18 * ratio, weight: .medium)
        self.addSubview(headingLabel)
        headingLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-14 * ratio)
            make.height.equalToSuperview()
        }
        
        headingLabel.isUserInteractionEnabled = true
        headingLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(makeImgRotate)))
        
        imgView = UIImageView(image: UIImage(named: "album_dropdown"))
        imgView.contentMode = .scaleAspectFit
        self.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(headingLabel.snp.right).offset(6 * ratio)
            make.width.equalTo(22 * ratio)
            make.height.equalToSuperview()
        }
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(makeImgRotate)))
    }
    
    @objc private func makeImgRotate(){
        isOpen.toggle()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addView()
    }

    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: 375, height: 44))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol NavBarDelegate:NSObjectProtocol {
    func openDropDownList()
    func closeDropDownList()
}
