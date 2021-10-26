//
//  RotateLoading.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/18.
//

import UIKit

class RotateLoading: UIView {
    private var path1:UIBezierPath!
    private var path2:UIBezierPath!
    private var ballRadius:CGFloat!
    
    private lazy var round1:UIView = {
        let round1 = UIView()
        round1.backgroundColor = UIColor.orange
        return round1
    }()
    private lazy var round2:UIView = {
        let round2 = UIView()
        round2.backgroundColor = UIColor.orange
        return round2
    }()
    private lazy var round3:UIView = {
        let round3 = UIView()
        round3.backgroundColor = UIColor.orange
        return round3
    }()
    private var oldFrame:CGRect!
    
    var colors:[UIColor]?{
        didSet{
            guard let colors = colors else {return}
            self.round1.backgroundColor = colors[0]
            self.round2.backgroundColor = colors[1]
            self.round3.backgroundColor = colors[2]
        }
    }
    var radius:CGFloat?{
        didSet{
            guard let radius = radius else {
                return
            }
            self.removeAni()
            self.setViewFrame(radius:radius)
            self.addPath(radius:radius)
            self.addAni(radius:radius)
        }
    }
    
    init(frame: CGRect, radius:CGFloat){
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.oldFrame = self.frame
        self.radius = radius
        self.addView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.oldFrame = self.frame

        self.addView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if oldFrame != self.frame{
            if let radius = radius{
                self.removeAni()
                self.setViewFrame(radius:radius)
                self.addPath(radius:radius)
                self.addAni(radius:radius)
            }else{
                radius = self.bounds.width < self.bounds.height ? self.bounds.width * 0.5 : self.bounds.height * 0.5
            }
    
            oldFrame = self.frame
        }
    }
    
    private func addView(){
        self.addSubview(round1)
        self.addSubview(round2)
        self.addSubview(round3)
    }
    
    private func setViewFrame(radius:CGFloat){
        
        if self.frame.width > self.frame.height{
            let shortLength = self.frame.height
            let longLength = self.frame.width
            round1.frame = CGRect(x: longLength * 0.5 - 3 * radius, y: shortLength * 0.5 - radius, width: radius * 2, height: radius * 2)
            round2.frame = CGRect(x: longLength * 0.5 - radius, y: shortLength * 0.5 - radius, width: radius * 2, height: radius * 2)
            round3.frame = CGRect(x: longLength * 0.5 + radius, y: shortLength * 0.5 - radius, width: radius * 2, height: radius * 2)
        }else{
            let shortLength = self.frame.width
            let longLength = self.frame.height
            round1.frame = CGRect(x: shortLength * 0.5 - radius, y: longLength * 0.5 - 3 * radius, width: radius * 2, height: radius * 2)
            round2.frame = CGRect(x: shortLength * 0.5 - radius, y: shortLength * 0.5 - radius, width: radius * 2, height: radius * 2)
            round3.frame = CGRect(x: shortLength * 0.5 - radius, y: shortLength * 0.5 + radius, width: radius * 2, height: radius * 2)
        }
        round1.layer.cornerRadius = radius
        round2.layer.cornerRadius = radius
        round3.layer.cornerRadius = radius
    }
    
    private func addAni(radius:CGFloat){
        self.ballRadius = radius * 2
        UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.round1.transform = CGAffineTransform(translationX: -self.ballRadius, y: 0).scaledBy(x: 0.7, y: 0.7)
            self.round3.transform = CGAffineTransform(translationX: self.ballRadius, y: 0).scaledBy(x: 0.7, y: 0.7)
            self.round2.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        } completion: { finished in
            if finished{
                UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                    self.round1.transform = CGAffineTransform.identity
                    self.round2.transform = CGAffineTransform.identity
                    self.round3.transform = CGAffineTransform.identity
                }) { finished in
                    if finished{
                        self.rotate()
                    }
                }
            }
        }
    }
    
    private func addPath(radius:CGFloat){

        //第一个圆的曲线
        path1 = UIBezierPath()
        path1.move(to: round1.center)
        path1.addArc(withCenter: round2.center, radius: radius * 2, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi * 2), clockwise: false)
        
        let path1_1 = UIBezierPath()
        path1_1.move(to: round3.center)
        path1_1.addArc(withCenter: round2.center, radius: radius * 2, startAngle: 0, endAngle: CGFloat(Double.pi), clockwise: false)
        
        //组合两段圆弧
        path1.append(path1_1)
        
        //第三个圆的曲线
        path2 = UIBezierPath()
        path2.move(to: round3.center)
        path2.addArc(withCenter: round2.center, radius: radius * 2, startAngle: 0, endAngle: CGFloat(Double.pi), clockwise: false)
        
        let path2_1 = UIBezierPath()
        path2_1.move(to: round1.center)
        path2_1.addArc(withCenter: round2.center, radius: radius * 2, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi * 2), clockwise: false)
        path2.append(path2_1)
    }
    
    private func rotate(){
        
        //第一个圆的动画
        let ani1 = CAKeyframeAnimation(keyPath: "position")
        ani1.path = path1.cgPath
        ani1.isRemovedOnCompletion = false
        ani1.fillMode = .forwards
        ani1.calculationMode = .cubic
        ani1.repeatCount = 1
        ani1.duration = 1.4
        ani1.delegate = self
        ani1.autoreverses = false
        ani1.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        round1.layer.add(ani1, forKey: "rotation")
        
        //第三个圆的动画
        let ani3 = CAKeyframeAnimation(keyPath: "position")
        ani3.path = path2.cgPath
        ani3.isRemovedOnCompletion = false
        ani3.fillMode = .forwards
        ani3.calculationMode = .cubic
        ani3.repeatCount = 1
        ani3.duration = 1.4
        ani3.autoreverses = false
        ani3.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        round3.layer.add(ani3, forKey: nil)
    }
    
    private func removeAni(){
        self.round1.transform = CGAffineTransform.identity
        self.round2.transform = CGAffineTransform.identity
        self.round3.transform = CGAffineTransform.identity
        round1.layer.removeAllAnimations()
        round2.layer.removeAllAnimations()
        round3.layer.removeAllAnimations()
    }
    
    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: 200, height: 200))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RotateLoading:CAAnimationDelegate{
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let radius = radius else {
            return
        }
        self.addAni(radius: radius)
    }
}
