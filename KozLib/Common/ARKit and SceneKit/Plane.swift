//
//  Plane.swift
//  KozLib
//
//  Created by Kelvin Kosbab on 9/24/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import SceneKit
import ARKit

class Plane : SCNNode {
  
  let anchor: ARPlaneAnchor
  let planeGeometry: SCNBox
  
  init(anchor: ARPlaneAnchor, isHidden: Bool) {
    
    // Using a SCNBox and not SCNPlane to make it easy for the geometry we add to the scene to interact with the plane.
    // For the physics engine to work properly give the plane some height so we get interactions between the plane and the gometry we add to the scene
    let planeHeight: CGFloat = 0.1
    self.anchor = anchor
    self.planeGeometry = SCNBox(width: CGFloat(anchor.extent.x), height: planeHeight, length: CGFloat(anchor.extent.z), chamferRadius: 0)
    super.init()
    
    // Instead of just visualizing the grid as a gray plane, we will render it in some Tron style colours.
    let material = SCNMaterial()
    material.diffuse.contents = #imageLiteral(resourceName: "tron_grid")
    
    // Since we are using a cube, we only want to render the tron grid on the top face, make the other sides transparent
    let transparentMaterial = SCNMaterial()
    transparentMaterial.diffuse.contents = UIColor(white: 1, alpha: 0)
    
    if isHidden {
      self.planeGeometry.materials = [ transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial ]
    } else {
      self.planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, material, transparentMaterial ]
    }
    
    // Since our plane has some height, move it down to be at the actual surface
    let planeNode = SCNNode(geometry: self.planeGeometry)
    planeNode.position = SCNVector3(x: 0, y: -Float(planeHeight) / 2, z: 0)
    
    // Give the plane a physics body so that items we add to the scene interact with it
    planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
    
    self.setTextureScale()
    self.addChildNode(planeNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // As the user moves around the extend and location of the plane may be updated. We need to update our 3D geometry to match the new parameters of the plane.
  func update(anchor: ARPlaneAnchor) {
    
    // As the user moves around the extend and location of the plane may be updated. We need to update our 3D geometry to match the new parameters of the plane.
    self.planeGeometry.width = CGFloat(anchor.extent.x)
    self.planeGeometry.length = CGFloat(anchor.extent.z)
    
    // When the plane is first created it's center is 0,0,0 and the nodes transform contains the translation parameters. As the plane is updated the planes translation remains the same but it's center is updated so we need to update the 3D geometry position
    self.position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)
    
    let node = self.childNodes.first
    node?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
    self.setTextureScale()
  }
  
  func setTextureScale() {
    let width = self.planeGeometry.width
    let height = self.planeGeometry.height
    
    // As the width/height of the plane updates, we want our tron grid material to cover the entire plane, repeating the texture over and over. Also if the grid is less than 1 unit, we don't want to squash the texture to fit, so scaling updates the texture co-ordinates to crop the texture in that case
    let material = self.planeGeometry.materials.first
    material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
    material?.diffuse.wrapS = .repeat
    material?.diffuse.wrapT = .repeat
  }
  
  func hide() {
    let transparentMaterial = SCNMaterial()
    transparentMaterial.diffuse.contents = UIColor(white: 1, alpha: 0)
    self.planeGeometry.materials = [ transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial ]
  }
}
