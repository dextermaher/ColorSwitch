//
//  GameScene.swift
//  ColorSwitch
//
//  Created by Dexter Maher on 3/11/21.
//
//

import SpriteKit

enum PlayColors {
    static let colors = [
        UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 241/255, green: 1966/255, blue: 15/255, alpha: 1.0),
        UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
        UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0),
    ]
}

enum SwitchState: Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex: Int?
    
    let scoreLabel = SKLabelNode(text: "0")
    var score = 0
 
    override func didMove(to view: SKView) {
        setUpPhysics()
            layoutScene()
    }
    
    
    // MARK: UPDATE ITEMS
    
    func updateScoreLabel() {
        scoreLabel.text = "\(score)"
    }
    
    func turnWheel() {
        if let newState = SwitchState(rawValue: switchState.rawValue + 1){
            switchState = newState
        } else {
            switchState = .red
        }
        
        colorSwitch.run(SKAction.rotate(byAngle: .pi/2, duration: 0.1))
    }
    
    func playGameOverMusic() {
        let soundAction = SKAction.playSoundFileNamed("wxp", waitForCompletion: true)
        self.run(soundAction){
            self.gameOver()
        }
    }
    
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "RecentScore")
        if score > UserDefaults.standard.integer(forKey: "HighScore"){
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
        
        let menuScene = MenuScene(size: view!.bounds.size)
        view!.presentScene(menuScene)
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        turnWheel()
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory{
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode: contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    run(SKAction.playSoundFileNamed("bling", waitForCompletion: false))
                    score += 1
                    physicsWorld.gravity = CGVector(dx: 0.0, dy: Double(-1 * score))
                    updateScoreLabel()
                    ball.run(SKAction.fadeOut(withDuration: 0.2), completion: {
                        ball.removeFromParent()
                        self.spawnBall()
                    })
                } else {
//                    gameOver()
                    playGameOverMusic()
                }
            }
        }
    }
    
}
