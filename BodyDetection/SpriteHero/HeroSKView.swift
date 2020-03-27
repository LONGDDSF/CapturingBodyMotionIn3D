//
//  HeroSKView.swift
//  GameSprite001
//
//  Created by CW on 2020/3/13.
//  Copyright © 2020 CW. All rights reserved.
//

import Foundation
import ARKit

class HeroSKView:  ARSKView{

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: scene
    private var heroScene: HeroScene!
    
    func setup()  {
        self.backgroundColor = UIColor.clear
        self.ignoresSiblingOrder = true
        self.showsFPS = false
        self.showsNodeCount = true

        setupScene()
    }
    
    func setupScene() {
        heroScene = HeroScene(size: CGSize(width:self.bounds.size.width, height: self.bounds.size.height))
        heroScene.scaleMode = .aspectFill
        presentScene(heroScene)
    }
}

extension HeroSKView : PosePosionDelegate{
    
    func poseDidCheckedPosion(leftWrist: CGPoint, rightWrist: CGPoint, referView: UIWindow) {
        let p_in_self = referView.convert(leftWrist, to: self)
        let p_in_scene = convert(p_in_self, to: heroScene)
        heroScene.updatefistNodePositon(point: p_in_scene)
    }
    
}
