//
//  HeroScene.swift
//  GameSprite001
//
//  Created by CW on 2020/3/13.
//  Copyright © 2020 CW. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

let enemyCategory: UInt32 = 0x1 << 0
let fistCategory: UInt32 = 0x1 << 1
let floorCategory: UInt32 = 0x1 << 2

class HeroScene: SKScene {
    
    var fistNode: SKSpriteNode!
    var floorNode:SKSpriteNode!
    var score: NSInteger = 0
    var enemyTexture:SKTexture = SKTexture(imageNamed: "hero")
    
    override func didMove(to view: SKView) {
        
        setupScene()
        
        addScoreLable()
        
        addfistNode()
        
        addFloor()
        
        repeatEnemy()
    
    }
    // MARK: 场景设置
    func setupScene() {
//        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        self.backgroundColor = SKColor.clear
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -4.3)
        self.physicsWorld.contactDelegate = self
    }
    
    // MARK: 分数
    lazy var scoreLabelNode:SKLabelNode = {
        let label = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        label.zPosition = 100
        label.text = "0"
        return label
    }()
    
    func addScoreLable() {
        score = 0
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
        scoreLabelNode.position = CGPoint(x: self.frame.size.width - 30, y: self.frame.size.height - 50)
    }
    
    func scorePlus() {
        score += 1
        scoreLabelNode.text = "\(score)" + "分"
    }
    
    // MARK: 添加敌人
    func addEnemy() {
        let enemy = SKSpriteNode(texture: enemyTexture)
        enemy.size = CGSize(width: 60, height: 60)
        
        // 出现位置横坐标随机
        let winSize:CGSize = self.size
        let minX = enemy.size.width / 2
        let maxX = winSize.width - enemy.size.width/2
        let rangeX = maxX - minX
        let randomX = (arc4random()%UInt32(rangeX)) + UInt32(minX);
        
        // 初始位置
        enemy.position = CGPoint(x:CGFloat(randomX),y:winSize.height + enemy.size.height/2);
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = fistCategory | floorCategory
        enemy.physicsBody?.collisionBitMask = fistCategory | floorCategory
        // 进场
        addChild(enemy)
    }
    
    func repeatEnemy() {
        let actionAddEnemy = SKAction.run {
            self.addEnemy()
        }
        let actionWaitNextEnemy = SKAction.wait(forDuration: 1)
        run(SKAction.repeatForever(SKAction.sequence([actionAddEnemy,actionWaitNextEnemy])))
    }
    
    // MARK: 添加拳头
    func addfistNode() {
        fistNode = SKSpriteNode(texture: SKTexture(imageNamed: "fist"))
        fistNode.size = CGSize(width: 40, height: 40)
        fistNode.physicsBody = SKPhysicsBody(circleOfRadius: fistNode.size.width)
        fistNode.physicsBody?.affectedByGravity = false
        fistNode.physicsBody?.allowsRotation = false
        fistNode.physicsBody?.isDynamic = false
        
        fistNode.physicsBody?.categoryBitMask = fistCategory
        fistNode.physicsBody?.contactTestBitMask = enemyCategory
        fistNode.physicsBody?.collisionBitMask = enemyCategory
        
        addChild(fistNode)
    }
    
    //MARK:爆炸效果
    lazy var exploreTexturesArray:[SKTexture] = {
         let explodeAtlas = SKTextureAtlas.init(named: "exploded")
          let allTextureArray = NSMutableArray.init(capacity: 16)
          for i in 0..<explodeAtlas.textureNames.count - 10 {
              let textureName = String(format: "%d@2x.png", arguments: [i+1])
              let texture = explodeAtlas.textureNamed(textureName)
              allTextureArray.add(texture)
          }
        return allTextureArray as! [SKTexture]
    }()
    
    func explode(point:CGPoint) {
  
        let bombNode = SKSpriteNode(texture: exploreTexturesArray[0])
        bombNode.position = point
        bombNode.name = "bomb"
        bombNode.size = CGSize(width: 50, height: 50)
        bombNode.zPosition = 2.0

        addChild(bombNode)
        
        //爆炸效果动画
        let animationAction = SKAction.animate(with: exploreTexturesArray, timePerFrame: 0.05)
        let player = explodedSound
        let soundAction = SKAction.run {
            player.play()
        }
        bombNode.run(SKAction.group([animationAction,soundAction])) {
            bombNode.removeFromParent()
        }
    }
    
    //MARK: 声音
    lazy var explodedSound:AVAudioPlayer = {
        var player : AVAudioPlayer?
        let mp3Path = Bundle.main.path(forResource: "bomb", ofType: "mp3")
        let pathURL = NSURL.fileURL(withPath: mp3Path!)
        do {
            try player = AVAudioPlayer(contentsOf: pathURL)
        } catch {
            print(error)
        }
        return player!
    }()

    // MARK: 地板
    func addFloor(){
        floorNode = SKSpriteNode(imageNamed:"hero")
        floorNode.position = CGPoint(x: 0, y: 0)
        floorNode.size = CGSize(width:10000, height: 10)
        floorNode.physicsBody = SKPhysicsBody(rectangleOf:floorNode.size)
        floorNode.physicsBody?.affectedByGravity = false
        floorNode.physicsBody?.allowsRotation = false
        floorNode.physicsBody?.isDynamic = false
        
        floorNode.physicsBody?.categoryBitMask = floorCategory
        floorNode.physicsBody?.contactTestBitMask = enemyCategory
        floorNode.physicsBody?.collisionBitMask = enemyCategory
        
        addChild(floorNode)
    }
}

/// MARK: 更新拳头位置
extension HeroScene{
   func updatefistNodePositon(point:CGPoint)  {
        if point.x > 0 && point.x < self.size.width
        && point.y > 0 && point.y < self.size.height{
         fistNode.position = point
        }else{
         print(point)
        }
    }
}

/// MARK: 碰撞代理
extension HeroScene: SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == fistNode ||
            contact.bodyB.node == fistNode{
            scorePlus()
        }
        
        if contact.bodyA.node == floorNode{
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyB.node == floorNode{
            contact.bodyA.node?.removeFromParent()
        }
        
        if contact.bodyA.node == fistNode{
            explode(point: (contact.bodyB.node?.position)!)
            contact.bodyB.node?.removeFromParent()
        }
        if contact.bodyB.node == fistNode{
            explode(point: (contact.bodyA.node?.position) ?? CGPoint(x: -100000, y: -10000))
            contact.bodyA.node?.removeFromParent()
        }
    }
}



