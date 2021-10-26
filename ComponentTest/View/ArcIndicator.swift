//
//  ArcIndicator.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/17.
//

import UIKit
import SnapKit

class ArcIndicatorView:UIView{
    private var indicator:ArcIndicator!
    private var messageLabel:UILabel?
    var message:String?{
        didSet{
            messageLabel = UILabel()
            messageLabel?.textAlignment = .center
            messageLabel?.textColor = UIColor(red:150/255.0, green:150/255.0, blue:150/255.0, alpha:1)
            messageLabel?.font = UIFont.systemFont(ofSize: self.frame.height * 0.15, weight: .medium)
            messageLabel?.text = self.message
            self.addSubview(messageLabel!)
            messageLabel!.snp.makeConstraints { make in
                make.top.equalTo(self.indicator.snp.bottom).offset(self.frame.height * 0.1)
                make.centerX.equalToSuperview()
            }
            
            indicator.snp.updateConstraints { make in
                make.centerY.equalTo(self.frame.height * 0.4)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(self.frame.width * 0.4)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 15
        
        indicator = ArcIndicator()
        self.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerY.equalTo(self.frame.height * 0.5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(self.frame.width * 0.4)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        indicator.snp.updateConstraints { make in
            make.centerY.equalTo(messageLabel == nil ? self.frame.height * 0.5 : self.frame.height * 0.4)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(self.frame.width * 0.4)
        }
    }
    
    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ArcIndicator: UIView {
    private var backLayer:CAShapeLayer!
    private var roundLayer:CAShapeLayer!
    var duration:TimeInterval = 1.5{
        didSet{
            self.addAni()
        }
    }
    
    var roundColor:UIColor = UIColor.red{
        didSet{
            self.roundLayer.strokeColor = roundColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addView()
        
        self.addAni()
    }
    
    private func addView(){
        let radius = self.frame.width * 0.5
        
        backLayer = CAShapeLayer()
        backLayer.frame = self.bounds
        backLayer.lineWidth = 3
        backLayer.strokeColor = UIColor(red:229/255.0, green:229/255.0, blue:229/255.0, alpha:1).cgColor
        backLayer.fillColor = UIColor.clear.cgColor
        backLayer.path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat(Double.pi * 3.5), clockwise: true).cgPath
        self.layer.addSublayer(backLayer)
        
        roundLayer = CAShapeLayer()
        roundLayer.frame = self.bounds
        roundLayer.lineWidth = 3
        roundLayer.strokeColor = self.roundColor.cgColor
        roundLayer.fillColor = UIColor.clear.cgColor
        roundLayer.path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat(Double.pi * 3.5), clockwise: true).cgPath
        roundLayer.lineDashPattern = [6,3]
        self.layer.addSublayer(roundLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = self.frame.width * 0.5
        
        backLayer.path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat(Double.pi * 3.5), clockwise: true).cgPath
        roundLayer.path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat(Double.pi * 3.5), clockwise: true).cgPath
    }
    
    private func addAni(){
        let strokeStartAni = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAni.fromValue = -1
        strokeStartAni.toValue = 1
        
        let strokeEndAni = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAni.fromValue = 0
        strokeEndAni.toValue = 1
        
        let groupAni = CAAnimationGroup()
        groupAni.animations = [strokeStartAni,strokeEndAni]
        groupAni.duration = self.duration
        groupAni.repeatCount = HUGE
        groupAni.autoreverses = false
        groupAni.fillMode = .forwards
        groupAni.isRemovedOnCompletion = false
        self.roundLayer.add(groupAni, forKey: nil)
    }
    
    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: 40, height: 40))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
