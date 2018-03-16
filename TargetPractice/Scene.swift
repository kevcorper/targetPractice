//
//  Scene.swift
//  TargetPractice
//
//  Created by Kevin Perkins on 3/16/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    let remainingTargetsLabel = SKLabelNode()
    var timer : Timer?
    var targetsCreated = 0
    var targetCount = 0 {
        didSet {
            remainingTargetsLabel.text = "Remaining: \(targetCount)"
        }
    }
    let startTime = Date()
    
    override func didMove(to view: SKView) {
        remainingTargetsLabel.fontSize = 36
        remainingTargetsLabel.fontName = "AmericanTypewriter"
        remainingTargetsLabel.color    = .white
        remainingTargetsLabel.position = CGPoint(x: 0, y: view.frame.midY - 50)
        addChild(remainingTargetsLabel)
        targetCount = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            self.createTarget()
        })
    }
    
    func createTarget() {
        if targetsCreated == 20 {
            timer?.invalidate()
            timer = nil
            return
        }
        targetsCreated += 1
        targetCount += 1
        
        guard let sceneView = self.view as? ARSKView else {return}
        
        let random = GKRandomSource.sharedRandom()
        let xRotation = matrix_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * random.nextUniform(), 1, 0, 0))
        let yRotation = matrix_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * random.nextUniform(), 0, 1, 0))
        
        let rotation = simd_mul(xRotation, yRotation)
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        let transform = simd_mul(rotation, translation)
        
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        
        let location = touch.location(in: self)
        let hits = nodes(at: location)

        if let sprite = hits.first {
            let scaleOut = SKAction.scale(to: 2, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let group = SKAction.group([scaleOut, fadeOut])
            let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
            
            sprite.run(sequence)
            
            targetCount -= 1
            
            if targetsCreated == 20 && targetCount == 0 {
                gameOver()
            }
        }
    }
    
    func gameOver() {
        
        remainingTargetsLabel.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        addChild(gameOver)
        
        let timeTaken = Date().timeIntervalSince(startTime)
        let timeLabel = SKLabelNode(text: "Time taken: \(Int(timeTaken)) seconds")
        
        timeLabel.fontSize = 36
        timeLabel.fontName = "AmericanTypewriter"
        timeLabel.color = .white
        timeLabel.position = CGPoint(x: 0, y: -view!.frame.midY + 50)
        
        addChild(timeLabel)
    }
}










