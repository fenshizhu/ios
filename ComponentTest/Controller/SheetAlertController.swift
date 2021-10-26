//
//  SheetAlertController.swift
//  gs cool
//
//  Created by zou jingbo on 2021/10/21.
//  Copyright © 2021 Greysh Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit

class SheetAlertController: UIViewController {
    private lazy var alertBox:SheetAlertView = {
        let alertBox = SheetAlertView()
        return alertBox
    }()
    private var safeView:UIView!
    
    enum ItemStyle{
        case bordered
        case remless
        case `default`
    }
    
    private var itemStyle:SheetAlertController.ItemStyle = .default
    
    var items:[GSButton] = []
    
    var message:String?{
        didSet{
            alertBox.message = self.message
        }
    }
    
    let swipeKeyPath:String = "swipe"
    let tapKeyPath:String = "tap"
    let buttonKeyPath:String = "button"
    
    var seletedIndex:Int = 0 //默认选中第一个按钮，只在bordered风格下生效
    {
        didSet{
            if seletedIndex < items.count && itemStyle == .bordered{
                for item in items{
                    if item.tag == seletedIndex{
                        item.isSelected = true
                    }else{
                        item.isSelected = false
                    }
                }
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .custom
    }
    
    convenience init(sytle:SheetAlertController.ItemStyle){
        self.init(nibName: nil, bundle: nil)
        
        self.itemStyle = sytle
        self.alertBox.itemStyle = sytle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.installUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.presentAni()
    }
    
    private func presentAni(){
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {[self] in
            safeView.alpha = 1
            safeView.snp.remakeConstraints { make in
                make.bottom.equalTo(0)
                make.left.equalTo(0)
                make.width.equalTo(width)
            }
            view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func dismissAni(keyPath:String?){
        let ani1 = CAKeyframeAnimation(keyPath: "position")
        ani1.values = [CGPoint(x: width * 0.5, y: height - self.safeView.frame.height * 0.5),CGPoint(x: width * 0.5, y: height + self.safeView.frame.height * 0.5)]
        ani1.keyTimes = [0,1]
        ani1.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        ani1.calculationMode = .cubic
        
        let ani2 = CAKeyframeAnimation(keyPath: "opacity")
        ani2.values = [1, 0]
        ani2.keyTimes = [0,1]
        ani2.calculationMode = .cubic
        ani2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let groupAni = CAAnimationGroup()
        groupAni.animations = [ani1,ani2]
        groupAni.delegate = self
        groupAni.repeatCount = 1
        groupAni.duration = 0.3
        groupAni.fillMode = .forwards
        groupAni.isRemovedOnCompletion = false
        groupAni.autoreverses = false
        
        self.safeView.layer.add(groupAni, forKey: keyPath)
    }
    
    func addItem(title:String, target:Any?, action:(()->Void)?){
        switch itemStyle {
        case .default, .remless:
            let btn = RemlessButton(frame: CGRect(x: 0, y: 0, width: width - 40 * ratio, height: 50 * ratio),title: title)
            btn.completion = action
            btn.addTarget(self, action: #selector(quit), for: .touchUpInside)
            alertBox.addButton(button: btn)
            items.append(btn)
            btn.tag = items.count - 1
        case .bordered:
            let btn = BorderedButton(frame: CGRect(x: 0, y: 0, width: width - 40 * ratio, height: 50 * ratio), title: title)
            btn.completion = action
            btn.addTarget(self, action: #selector(toBeSelected), for: .touchDown)
            btn.addTarget(self, action: #selector(quit), for: .touchUpInside)
            alertBox.addButton(button: btn)
            items.append(btn)
            btn.tag = items.count - 1
        }
        
        if items.count > 0{
            items[seletedIndex].isSelected = true
        }
    }
    
    @objc private func toBeSelected(_ sender:BorderedButton){
        seletedIndex = sender.tag
    }

    private func installUI(){
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        safeView = UIView()
        safeView.backgroundColor = UIColor.white
        safeView.layer.cornerRadius = 12 * ratio
        self.view.addSubview(safeView)
        safeView.addSubview(alertBox)
        safeView.alpha = 0
        
        let swipeGes = UISwipeGestureRecognizer(target: self, action: #selector(quitBySwipeGes))
        swipeGes.direction = .down
        safeView.addGestureRecognizer(swipeGes)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(quitByTapGes))
        self.view.addGestureRecognizer(tapGes)
        
        safeView.snp.makeConstraints { make in
            make.top.equalTo(height)
            make.left.equalTo(0)
            make.width.equalTo(width)
        }
        
        alertBox.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.width.equalTo(width)
            make.top.equalTo(0)
            make.bottom.equalTo(-self.view.safeAreaInsets.bottom)
        }
    }
    
    @objc private func quitBySwipeGes(_ sender: UISwipeGestureRecognizer){
        dismissAni(keyPath: swipeKeyPath)
    }
    
    @objc private func quitByTapGes(_ sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: sender.view)
        if touchPoint.y <= self.view.frame.height - self.safeView.frame.height{
            dismissAni(keyPath: tapKeyPath)
        }
    }
    
    @objc private func quit(_ sender: UIButton){
        
        dismissAni(keyPath: "\(buttonKeyPath)\(sender.tag)")
    }
    
    private func updateUI(){
       
        alertBox.snp.updateConstraints { make in
            make.left.equalTo(0)
            make.width.equalTo(width)
            make.top.equalTo(0)
            make.bottom.equalTo(-self.view.safeAreaInsets.bottom)
        }
    }
}

extension SheetAlertController: CAAnimationDelegate{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == self.safeView.layer.animation(forKey: swipeKeyPath){
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if anim == self.safeView.layer.animation(forKey: tapKeyPath){
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        for index in 0..<items.count{
            if anim == self.safeView.layer.animation(forKey: "\(buttonKeyPath)\(index)"){
                self.dismiss(animated: true, completion: items[index].completion)
            }
        }
    }
}

class SheetAlertView:UIView{
    var message:String?{
        didSet{
            self.addAttributeText()
        }
    }
    var btnsArr:[UIButton] = []
    
    var itemStyle:SheetAlertController.ItemStyle = .default
    
    private var maskLayer:CAShapeLayer!
    
    private var messageLabel:UILabel!
    
    private func addView(){
        self.backgroundColor = UIColor.white
        maskLayer = CAShapeLayer()
        self.layer.mask = maskLayer
        
        let solidLine = UIView()
        solidLine.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        solidLine.layer.cornerRadius = 1
        self.addSubview(solidLine)
        solidLine.snp.makeConstraints { make in
            make.top.equalTo(10 * ratio)
            make.centerX.equalToSuperview()
            make.width.equalTo(40 * ratio)
            make.height.equalTo(2)
        }
        
        messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        self.addSubview(messageLabel)
        
        if let message = message{
            let paramStyle = NSMutableParagraphStyle()
            paramStyle.lineSpacing = 7
            paramStyle.alignment = .center
            let attributes:[NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14 * ratio, weight: .medium),
                NSAttributedString.Key.foregroundColor:  UIColor(red: 0.2, green: 0.2, blue: 0.2,alpha:1),
                NSAttributedString.Key.paragraphStyle: paramStyle
            ]
            let attrText = NSMutableAttributedString(string: message)
            attrText.addAttributes(attributes, range: NSRange(location: 0, length: message.count))
            
            let messageSize = message.boundingRect(with: CGSize(width: width - 80 * ratio, height: 0), options: [.usesDeviceMetrics,.usesFontLeading,.usesLineFragmentOrigin], attributes: attributes, context: nil)
            
            messageLabel.attributedText = attrText
            
            messageLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(20 * ratio)
                make.width.equalTo(width - 70)
                make.height.equalTo(messageSize.height + 30 * ratio)
            }
        }else{
            messageLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(20 * ratio)
                make.width.equalTo(width - 70)
                make.height.equalTo(0)
            }
        }
    }
    
    private func addAttributeText(){
        if let message = message{
            let paramStyle = NSMutableParagraphStyle()
            paramStyle.lineSpacing = 7
            paramStyle.alignment = .center
            let attributes:[NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14 * ratio, weight: .medium),
                NSAttributedString.Key.foregroundColor:  UIColor(red: 0.2, green: 0.2, blue: 0.2,alpha:1),
                NSAttributedString.Key.paragraphStyle: paramStyle
            ]
            let attrText = NSMutableAttributedString(string: message)
            attrText.addAttributes(attributes, range: NSRange(location: 0, length: message.count))
            
            let messageSize = message.boundingRect(with: CGSize(width: width - 80 * ratio, height: 0), options: [.usesDeviceMetrics,.usesFontLeading,.usesLineFragmentOrigin], attributes: attributes, context: nil)
            
            messageLabel.attributedText = attrText
            
            messageLabel.snp.updateConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(20 * ratio)
                make.width.equalTo(width - 70)
                make.height.equalTo(messageSize.height + 30 * ratio)
            }
        }else{
            messageLabel.snp.updateConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(20 * ratio)
                make.width.equalTo(width - 70)
                make.height.equalTo(0)
            }
        }
    }
    
    func addButton(button:UIButton){
        btnsArr.append(button)
        self.addSubview(button)
        
        var itemSpacing:CGFloat!
        switch itemStyle {
        case .default, .remless:
            itemSpacing = 10 * ratio
        case .bordered:
            itemSpacing = 20 * ratio
        }
        
        if btnsArr.count == 1{
            button.snp.makeConstraints { make in
                make.top.equalTo(messageLabel.snp.bottom).offset(itemSpacing)
                make.centerX.equalToSuperview()
                make.width.equalTo(button.frame.width)
                make.height.equalTo(button.frame.height)
                make.bottom.equalTo(-itemSpacing)
            }
        }else{
            let count = btnsArr.count
            
            if count <= 2{
                btnsArr[count-2].snp.remakeConstraints { make in
                    make.top.equalTo(messageLabel.snp.bottom).offset(itemSpacing)
                    make.centerX.equalToSuperview()
                    make.width.equalTo(button.frame.width)
                    make.height.equalTo(button.frame.height)
                }
            }else{
                btnsArr[count-2].snp.remakeConstraints { make in
                    make.top.equalTo(btnsArr[count-3].snp.bottom).offset(itemSpacing)
                    make.centerX.equalToSuperview()
                    make.width.equalTo(button.frame.width)
                    make.height.equalTo(button.frame.height)
                }
            }
            
            button.snp.makeConstraints { make in
                make.top.equalTo(btnsArr[count-2].snp.bottom).offset(itemSpacing)
                make.centerX.equalToSuperview()
                make.width.equalTo(button.frame.width)
                make.height.equalTo(button.frame.height)
                make.bottom.equalTo(-itemSpacing)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = self.bounds
        maskLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 12, height: 12 * ratio)).cgPath
    }
    
    init(message:String?){
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 300))
        self.message = message
        self.addView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addView()
    }
    
    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: width, height: 300))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
