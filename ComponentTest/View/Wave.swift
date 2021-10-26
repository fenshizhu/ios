//
//  Wave.swift
//  ComponentTest
//
//  Created by zou jingbo on 2021/10/19.
//

import UIKit
import SnapKit

@IBDesignable
class Wave: UIView {
    
    var waveAmplitude:CGFloat = 10{
        didSet{
            updateWave()
        }
    }
    var waveY:CGFloat = 0 //偏距
    {
        didSet{
            updateWave()
        }
    }
    var wavePalstance:CGFloat = 0.02{
        didSet{
            updateWave()
        }
    }

    var waveX:CGFloat = 0{
        didSet{
            updateWave()
        }
    }
    
    var waveColor:UIColor = UIColor.blue{
        didSet{
            waveLayer1?.fillColor = waveColor.cgColor
            waveLayer2?.fillColor = waveColor.cgColor
        }
    }
    
    private var waveLayer1:CAShapeLayer?
    private var waveLayer2:CAShapeLayer?
    private var timer:Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.addLayer()
        self.updateWave()
        self.createTimer()
    }
    
    private func addLayer(){
        waveLayer1 = CAShapeLayer()
        waveLayer1?.frame = self.bounds
        waveLayer1?.fillColor = UIColor.systemBlue.cgColor
        waveLayer1?.strokeColor = .none
        waveLayer1?.opacity = 0.5
        waveLayer1?.masksToBounds = true
        self.layer.addSublayer(waveLayer1!)
        
        waveLayer2 = CAShapeLayer()
        waveLayer2?.frame = self.bounds
        waveLayer2?.fillColor = UIColor.systemPink.cgColor
        waveLayer2?.strokeColor = .none
        waveLayer2?.masksToBounds = true
        self.layer.addSublayer(waveLayer2!)
    }
    
    private func updateWave(){
        //波浪宽度
        let waterWaveWidth = self.bounds.width
        //初始化运动路径
        let path = CGMutablePath()
        let maskPath = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: waveY))
        maskPath.move(to: CGPoint(x: 0, y: waveY))
        
        //初始化波浪的纵截距为waveY
        var y:CGFloat = waveY
        
//        正弦曲线公式：y=Asin(ωx+φ)+k
//        A——振幅，当物体作轨迹符合正弦曲线的直线往复运动时，其值为行程的1/2。
//        (ωx+φ)——相位，反映变量y所处的状态。
//        φ——初相(initial phase)，x=0时的相位；反映在坐标系上则为图像的左右移动。
//        k——偏距，反映在坐标系上则为图像的上移或下移。offsetY
//        ω——角速度(palstance)， 控制正弦周期(单位角度内震动的次数)
        
        //画正弦曲线
        for x in 0...Int(waterWaveWidth){
            y = waveAmplitude * sin(wavePalstance * CGFloat(x) + waveX) + (self.bounds.height - waveY)
            path.addLine(to: CGPoint(x: CGFloat(x), y: y))
        }
        
        //画余弦曲线
        for x in 0...Int(waterWaveWidth){
            y = waveAmplitude * cos(wavePalstance * CGFloat(x) + waveX) + (self.bounds.height - waveY)
            maskPath.addLine(to: CGPoint(x: CGFloat(x), y: y))
        }
        
        self.updateLayer(layer: waveLayer1!, path: path)
        self.updateLayer(layer: waveLayer2!, path: maskPath)
    }
    
    private func updateLayer(layer:CAShapeLayer, path:CGMutablePath){
        //填充底部颜色
        let waterWaveWidth = self.bounds.width
        path.addLine(to: CGPoint(x: waterWaveWidth, y: self.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: self.bounds.height))
        path.closeSubpath()
        
        layer.path = path
    }
    
    private func deleteTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    private func createTimer(){
        deleteTimer()
        
        timer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(waveAni), userInfo: nil, repeats: true)
    }
    
    @objc private func waveAni(){
        if waveY < self.bounds.height{
            waveY += 0.1
            waveX += 0.1
        }else{
            deleteTimer()
            waveY = 0
            waveX = 0
        }
    }

    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addLayer()
        self.updateWave()
    }
}
