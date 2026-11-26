import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func sceneWillResignActive(_ scene: UIScene) {
    if let window = (scene as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }),
       window.viewWithTag(880032) == nil {
      let cover = UIView(frame: window.bounds)
      cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      cover.backgroundColor = UIColor(red: 0.976, green: 0.953, blue: 0.969, alpha: 1)
      cover.tag = 880032
      window.addSubview(cover)
    }
    super.sceneWillResignActive(scene)
  }
}
