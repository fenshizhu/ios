//
//  ChooseStateView.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/25.
//

import UIKit

class ChooseStateView: UIView {
    
    private var tipView:UIView!
    private var tipLayer:CAShapeLayer!
    private var duration:TimeInterval = 0.2
    private var chosenKeyPath:String = "isChosen"
    private var notChosenKeyPath:String = "notChosen"
    
    var isChosen:Bool = false{
        didSet{
            if isChosen{
                self.layer.borderWidth = 3
                tipView.backgroundColor = UIColor.black
                tipView.layer.borderColor = UIColor.black.cgColor
                tipLayer.strokeColor = UIColor.white.cgColor
            }else{
                self.layer.borderWidth = 0
                tipView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
                tipView.layer.borderColor = UIColor.black.cgColor
                tipLayer.strokeColor = UIColor.clear.cgColor
            }
//            if isChosen != oldValue{
//                if isChosen{
//                    self.layer.borderColor = UIColor.black.cgColor
//                    tipView.backgroundColor = UIColor.black
//                    tipLayer.strokeColor = UIColor.white.cgColor
//
//                    let ani = CASpringAnimation(keyPath: "strokeEnd")
//                    ani.delegate = self
//                    ani.damping = 2
//                    ani.stiffness = 5
//                    ani.mass = 2
//                    ani.fromValue = 0
//                    ani.toValue = 1
//                    ani.repeatCount = 1
//                    ani.autoreverses = false
//                    ani.isRemovedOnCompletion = true
//                    ani.duration = self.duration
//                    tipLayer.add(ani, forKey: chosenKeyPath)
//                }else{
//                    self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
//                    tipView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
//                    tipLayer.strokeColor = UIColor.clear.cgColor
//
//                    let ani = CASpringAnimation(keyPath: "strokeStart")
//                    ani.delegate = self
//                    ani.damping = 2
//                    ani.stiffness = 5
//                    ani.mass = 2
//                    ani.fromValue = 1
//                    ani.toValue = 0
//                    ani.repeatCount = 1
//                    ani.autoreverses = false
//                    ani.isRemovedOnCompletion = true
//                    ani.duration = self.duration
//                    tipLayer.add(ani, forKey: notChosenKeyPath)
//                }
//            }else{
//                if isChosen{
//                    self.layer.borderColor = UIColor.black.cgColor
//                    tipView.backgroundColor = UIColor.black
//                    tipLayer.strokeColor = UIColor.white.cgColor
//                }else{
//                    self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
//                    tipView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
//                    tipLayer.strokeColor = UIColor.clear.cgColor
//                }
//            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.black.cgColor
        
        tipView = UIView()
        tipView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        tipView.layer.cornerRadius = 2
        tipView.layer.borderWidth = 0.5
        tipView.layer.borderColor = UIColor.black.cgColor
        self.addSubview(tipView)
        tipView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
            make.width.height.equalTo(12)
        }
        
        tipLayer = CAShapeLayer()
        tipLayer.strokeColor = UIColor.clear.cgColor
        tipLayer.fillColor = .none
        tipLayer.lineCap = .round
        tipLayer.lineJoin = .round
        tipLayer.lineWidth = 2
        tipLayer.frame = tipView.bounds
        tipView.layer.addSublayer(tipLayer)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 3, y: 6))
        path.addLine(to: CGPoint(x: 5, y: 8))
        path.addLine(to: CGPoint(x: 9, y: 3))
        tipLayer.path = path.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChooseStateView: CAAnimationDelegate{
    func animationDidStart(_ anim: CAAnimation) {
        let ani1 = tipLayer.animation(forKey: chosenKeyPath)
        let ani2 = tipLayer.animation(forKey: notChosenKeyPath)
        
        if anim == ani1{
            tipLayer.strokeColor = UIColor.white.cgColor
        }else if anim == ani2{
            tipLayer.strokeColor = UIColor.clear.cgColor
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag{
            tipLayer.removeAllAnimations()
        }
    }
}
