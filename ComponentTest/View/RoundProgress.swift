//
//  SectorProgress.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/18.
//

import UIKit

///圆形下载进度
class RoundProgress: UIView {
    private var backLayer:CAShapeLayer!
    private var foreLayer:CAShapeLayer!
    private var gradientLayerLeft:CAGradientLayer!
    
    var value:CGFloat = 0{
        didSet{
            self.foreLayer.strokeEnd = self.value
        }
    }
    
    var lineWidth:CGFloat = 10{
        didSet{
            backLayer.lineWidth = lineWidth
            foreLayer.lineWidth = lineWidth
            
            foreLayer.frame = CGRect(x: 0.5 * lineWidth, y: 0.5 * lineWidth, width: self.bounds.width, height: self.bounds.height)
            gradientLayerLeft.frame = CGRect(x: -0.5 * lineWidth, y: -0.5 * lineWidth, width: self.bounds.width + lineWidth, height: self.bounds.height + lineWidth)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = self.frame.width * 0.5
        let path = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: CGFloat(Double.pi * 1.5), endAngle: CGFloat(Double.pi * 3.5), clockwise: true)
        
        backLayer.frame = self.bounds
        backLayer.path = path.cgPath
        foreLayer.frame = CGRect(x: 0.5 * lineWidth, y: 0.5 * lineWidth, width: self.bounds.width, height: self.bounds.height)
        foreLayer.path = path.cgPath
        
        gradientLayerLeft.frame = CGRect(x: -0.5 * lineWidth, y: -0.5 * lineWidth, width: self.bounds.width + lineWidth, height: self.bounds.height + lineWidth)
    }
    
    private func addView(){
        backLayer = CAShapeLayer()
        backLayer.fillColor = UIColor.clear.cgColor
        backLayer.lineWidth = self.lineWidth
        backLayer.strokeColor = UIColor.lightGray.cgColor
        self.layer.addSublayer(backLayer)
        
        foreLayer = CAShapeLayer()
        foreLayer.fillColor = UIColor.clear.cgColor
        foreLayer.lineWidth = self.lineWidth
        foreLayer.strokeColor = UIColor.red.cgColor
        foreLayer.strokeEnd = 0
        self.layer.addSublayer(foreLayer)
        
        gradientLayerLeft = CAGradientLayer()
        gradientLayerLeft.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor, UIColor.blue.cgColor]
        gradientLayerLeft.locations = [0, 0.5, 1]
        gradientLayerLeft.startPoint = CGPoint(x: 0, y: 0)
        gradientLayerLeft.endPoint = CGPoint(x: 0, y: 1)
        self.layer.addSublayer(gradientLayerLeft)
        
        //设置mask
        self.gradientLayerLeft.mask = self.foreLayer
    }

    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: 200, height: 200))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
