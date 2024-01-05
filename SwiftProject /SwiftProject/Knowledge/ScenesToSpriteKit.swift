//
//  ScenesToSpriteKit.swift
//  SwiftProject
//
//  Created by kaki Yen on 2022/7/6.
//

import SwiftUI
import SpriteKit

class SceneVC: UIViewController {
    @TypeWrapper var imageName: String!
    var skView: SKView!
    var scene: SKScene!
    
    convenience init(_ imageName: String) {
        self.init()
        self.imageName = imageName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        instantiateView()
        instantiateScene()
        for _ in 0 ..< 3 {
            let sizeThreshold: Int = randomThrehold(90, 30)
            let velocityThreshold: Int = randomThrehold(10, -10)
            scene.addChild(instantiateNode(CGPoint.zero, CGSize(width: sizeThreshold, height: sizeThreshold), CGVector(dx: velocityThreshold, dy: velocityThreshold)))
        }
    }
    
    func instantiateNode(_ position: CGPoint, _ size: CGSize, _ velocity: CGVector) -> SKCropNode {
        let spriteNode: SKSpriteNode = SKSpriteNode(imageNamed: imageName)
        spriteNode.size = size
        
        let shapeNode: SKShapeNode = SKShapeNode(circleOfRadius: spriteNode.size.width / 2)
        shapeNode.fillColor = UIColor.black
        
        let cropNode: SKCropNode = SKCropNode()
        cropNode.position = position
        cropNode.maskNode = shapeNode
        cropNode.addChild(spriteNode)
        
        let circleOfRadius: CGFloat! = spriteNode.size.width / 2
        let physicsBody: SKPhysicsBody = SKPhysicsBody(circleOfRadius: circleOfRadius)
        physicsBody.affectedByGravity = false
        physicsBody.angularDamping = 0.0
        physicsBody.linearDamping = 0.0
        physicsBody.restitution = 1.0
        physicsBody.friction = 0.0
        physicsBody.velocity = velocity
        cropNode.physicsBody = physicsBody
        
        return cropNode
    }
    
    func instantiateScene() {
        scene = SKScene(size: skView.bounds.size)
        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
        skView.presentScene(scene)
    }
    
    func instantiateView() {
        skView = SKView(frame: CGRect(x: 0.0,
                                      y: (view.bounds.height - view.bounds.height / 2) / 2,
                                      width: view.bounds.width,
                                      height: view.bounds.height / 2))
        view.addSubview(skView)
    }
    
    func randomThrehold(_ max: Int, _ min: Int) -> Int {
        Int.random(in: min...max)
    }
}

struct SceneVCRepresentable: UIViewControllerRepresentable {
    var imageName: String
    
    func makeUIViewController(context: Context) -> some UIViewController {
        SceneVC(imageName)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct LandMarkSpriteView: View {
    var imageName: String
    
    var body: some View {
        SceneVCRepresentable(imageName: imageName)
    }
}
