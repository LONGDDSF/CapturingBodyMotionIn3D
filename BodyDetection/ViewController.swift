/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine
import Vision

public protocol PosePosionDelegate: class {
//    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CVPixelBuffer?, timestamp: CMTime)
    func poseDidCheckedPosion(leftWrist:CGPoint, rightWrist:CGPoint, referView:UIWindow)
}

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [-1, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    // line dots
    var overlayView :OverlayView!
    
    // game
    var sceneView: HeroSKView!
    public weak var gameDelegate: PosePosionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView = OverlayView()
        view.addSubview(overlayView)
        
//        arView.debugOptions(ARView.DebugOptions.init(rawValue: <#T##Int#>))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        overlayView.frame = view.bounds
        overlayView.backgroundColor = UIColor.clear
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }

        /*
         
         为了实现AR体验的功能，您可以创建以下子类之一，并通过在会话中运行它。一个会话一次只能运行一种配置，因此请选择最能促进所需的AR体验的一种配置。runWithConfiguration:

         ARWorldTrackingConfiguration
         跟踪设备相对于ARKit可以使用设备的后置摄像头找到并跟踪的任何表面，人物或已知图像和对象的位置和方向。

         ARBodyTrackingConfiguration
         使您可以使用设备的后置摄像头跟踪人物，飞机和图像。

         AROrientationTrackingConfiguration
         使用后置摄像头仅跟踪设备的方向。

         ARImageTrackingConfiguration
         仅跟踪通过使用设备的后置摄像头提供的已知图像。trackingImages

         ARFaceTrackingConfiguration
         仅跟踪设备自拍相机中的脸部，包括运动和面部表情。

         ARObjectScanningConfiguration
         使用后置摄像头收集有关您希望应用程序稍后在运行时识别的特定对象的高保真数据。

         ARPositionalTrackingConfiguration
         仅跟踪设备在3D空间中的位置。
         
         */
        // Run a body tracking configration.

        let configuration = ARObjectScanningConfiguration()
        configuration.videoFormat = ARWorldTrackingConfiguration.supportedVideoFormats[1]
        configuration.frameSemantics = .bodyDetection
        
        arView.session.run(configuration)
        
//        arView.scene.addAnchor(characterAnchor)
//
//        // Asynchronously load the 3D character.
//        var cancellable: AnyCancellable? = nil
//        cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
//            receiveCompletion: { completion in
//                if case let .failure(error) = completion {
//                    print("Error: Unable to load model: \(error.localizedDescription)")
//                }
//                cancellable?.cancel()
//        }, receiveValue: { (character: Entity) in
//            if let character = character as? BodyTrackedEntity {
//                // Scale the character to human size
//
//                character.scale = [0.7, 0.7, 0.7]
//                self.character = character
//                cancellable?.cancel()
//            } else {
//                print("Error: Unable to load model as BodyTrackedEntity")
//            }
//        })
        
        setupScene()
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            characterAnchor.position = bodyPosition + characterOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
   
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        let person = frame.detectedBody
        if person != nil{
            let skeleton2D = person!.skeleton
            let definition = skeleton2D.definition // List of Joint Landmarks
            let jointNames = definition.jointNames
//            let img = frame.capturedImage
//            let jointLandmarks = skeleton2D.jointLandmarks // Iterate over All the Landmarks
            
            let targetBodyPostion = "left_hand_joint"
            
            if jointNames.contains("left_hand_joint"){
                let SIMD2_posion = skeleton2D.landmark(for: ARSkeleton.JointName.init(rawValue: targetBodyPostion))
                let aview = view ?? UIView()
                let p_x = aview.frame.size.height * CGFloat(SIMD2_posion!.x)
                let p_y = aview.frame.size.width * (CGFloat(1) - CGFloat(SIMD2_posion!.y))
                let p = CGPoint(x: p_y, y: p_x)

                let awindow = aview.window ?? UIWindow()
                let new_p = aview.convert(p, to: awindow)

                gameDelegate?.poseDidCheckedPosion(leftWrist: new_p, rightWrist: new_p, referView: awindow)
            }
//            var pointsArr:[CGPoint] = NSMutableArray() as! [CGPoint]
//            for (_ , name) in jointNames.enumerated() {
//                let SIMD2_posion = skeleton2D.landmark(for: ARSkeleton.JointName.init(rawValue: name))
//
//                let tem_arview = arView ?? ARView()
//                let p_x_in_ar = tem_arview.frame.size.height * CGFloat(SIMD2_posion!.x)
//                let p_y_in_ar = tem_arview.frame.size.width * (CGFloat(1) - CGFloat(SIMD2_posion!.y))
//
////                p_x_in_ar =
//
//                let p_in_ar = CGPoint(x: p_y_in_ar, y: p_x_in_ar)
//
//                let aview = view ?? UIView()
//                let p_in_view = tem_arview.convert(p_in_ar, to: aview)
//                pointsArr.append(p_in_view)
//            }
//            overlayView.dots = pointsArr
//            overlayView.setNeedsDisplay()
        }
    }
    // MARK: Game
    func setupScene() {
      // Present the scene
      sceneView = HeroSKView()
      sceneView.frame = view.frame
      
      view.addSubview(sceneView)
      sceneView.setup()
      gameDelegate = sceneView
    }
}
