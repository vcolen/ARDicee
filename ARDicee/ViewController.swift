//
//  ViewController.swift
//  ARDicee
//
//  Created by Victor Colen on 09/06/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation)
            
            if let hitResult = results.first {
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
                
                if let diceNode = diceScene?.rootNode.childNode(
                    withName: "Dice",
                    recursively: true
                ) {
                    diceNode.position = SCNVector3(
                        x: hitResult.simdWorldCoordinates.x,
                        y: hitResult.simdWorldCoordinates.y + diceNode.boundingSphere.radius,
                        z: hitResult.simdWorldCoordinates.z
                    )
                    
                    diceArray.append(diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                }
            }
        }
    }
    
    func rollAll() {
        if diceArray.isEmpty == false {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = (Float(arc4random_uniform(4)) + 1) * Float.pi/2
        
        dice.runAction(
            SCNAction.rotate(by: CGFloat(randomX * 5), around: dice.worldRight , duration: 0.5)
        )
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3(
                x: planeAnchor.center.x,
                y: 0,
                z: planeAnchor.center.z
            )
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
}
