//
//  FullScreenVideoController.swift
//  Llorkcir
//
//  Created by Seth Rininger on 11/21/18.
//  Copyright © 2018 Vimvest. All rights reserved.
//

import AsyncDisplayKit

extension CGSize {

    var asl: ASLayoutSize {
        return ASLayoutSize(width: width.asd, height: height.asd)
    }

    init(diameter: CGFloat) {
        self.init(width: diameter, height: diameter)
    }

    func adjustToScreenSize() -> CGSize {
        return CGSize(
            width: width.adjustToScreenSize(),
            height: height.adjustToScreenSize()
        )
    }

    func pixelRound() -> CGSize {
        return CGSize(
            width: width.pixelRound(),
            height: height.pixelRound()
        )
    }

    var clasp: CGSize {
        return CGSize(
            width: width.clasp,
            height: height.clasp
        )
    }
}

extension UIScreen {

    enum DeviceType {
        case iPad
        case small
        case medium
        case large
    }

    static func getDevice() -> DeviceType {
        switch main.bounds.size.width {
        case 320:
            if main.bounds.size.height == 480 {
                return .iPad
            } else {
                return .small
            }
        case 375:
            return .medium
        case 414:
            return .large
        default:
            return .large
        }
    }

    static var deviceType = getDevice()
}

extension CGFloat {

    var clasp: CGFloat { return self.adjustToScreenSize().pixelRound() }

    func adjustToScreenSize() -> CGFloat {
        switch UIScreen.deviceType {
        case .small, .iPad:
            return self * 0.7729468599 // 320.0/414.0
        case .medium:
            return self * 0.9057971014 // 375.0/414.0
        case .large:
            return self
        }
    }

    func pixelRound() -> CGFloat {
        switch UIScreen.main.scale {
        case 3:
            let truncatingRemainder = self.truncatingRemainder(dividingBy: 1)
            switch truncatingRemainder {
            case 0..<0.1666666667:
                return floor(self)
            case 0.1666666667..<0.5:
                return floor(self) + 0.33
            case 0.5..<0.8333333333:
                return floor(self) + 0.67
            default:
                return floor(self) + 1
            }
        default:
            let value: CGFloat = UIScreen.main.scale == 1 ? 1 : 0.5
            let remainder = self.truncatingRemainder(dividingBy: value)
            let shouldRoundUp = remainder >= (value / 2) ? true : false
            let multiple = floor(self / value)
            return !shouldRoundUp ? value * multiple : value * multiple + value
        }
    }

}

extension Int {
    var clasp: CGFloat { return CGFloat(self).adjustToScreenSize().pixelRound() }
}

class FullScreenVideoController: ASViewController<ASDisplayNode> {

    var statusBarHidden = false
    let mainVideoUrl: URL = URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0")!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    let containerNode = ASDisplayNode()

    init() {
        super.init(node: containerNode)
        modalPresentationStyle = .overCurrentContext
        containerNode.automaticallyManagesSubnodes = true
        containerNode.layoutSpecBlock = { [unowned self] _, _ in
            return ASInsetLayoutSpec(insets: .zero, child: self.contentNode)
        }
        modalPresentationCapturesStatusBarAppearance = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarHidden = true
        UIView.animate(withDuration: 0.3) {
            self.contentNode.alpha = 1
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    lazy var contentNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = .white
        node.layoutSpecBlock = { [unowned self] _, constrainedSize in
            let videoSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: [], child: self.videoNode)

            self.fullScreenButton.style.spacingAfter = 62.clasp
            let fullScreenButtonSpec = ASStackLayoutSpec(direction: .vertical,
                                                         spacing: 0,
                                                         justifyContent: .end,
                                                         alignItems: .center,
                                                         children: [self.fullScreenButton])
            let fsbSpec = ASBackgroundLayoutSpec(child: videoSpec, background: fullScreenButtonSpec)
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 43.clasp,
                                                                   left: CGFloat.infinity,
                                                                   bottom: CGFloat.infinity,
                                                                   right: 19.clasp),
                                              child: self.closeButton)
            let buttonSpec = ASRelativeLayoutSpec(horizontalPosition: .end, verticalPosition: .start, sizingOption: .minimumSize, child: insetSpec)

            return ASBackgroundLayoutSpec(child: buttonSpec, background: fsbSpec)
        }
        node.alpha = 0
        return node
    } ()

    lazy var videoNode: ASVideoNode = {
        let videoNode = ASVideoNode()
        let asset = AVAsset(url: mainVideoUrl)
        videoNode.asset = asset
        videoNode.shouldAutoplay = true
        videoNode.shouldAutorepeat = true
        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        videoNode.style.preferredLayoutSize = CGSize(width: 415, height: 234).clasp.asl
        return videoNode
    } ()

    lazy var closeButton: ASButtonNode = {
        let button = ImageButtonNode(image: #imageLiteral(resourceName: "NavBarXIcon"))
        button.addTarget(self, action: #selector(close), forControlEvents: .touchUpInside)
        button.hitTestSlop = UIEdgeInsets(inset: -25.clasp)
        return button
    } ()

    lazy var fullScreenButton: ASDisplayNode = {
        let button = WhiteGradientButtonNode(title: "Go Full Screen".localize(), isDynamicSize: true, tapped: goFullScreen)
        button.style.preferredLayoutSize = CGSize(width: 150, height: 35).clasp.asl
        return button
    } ()

    @objc func close(_ sender: ASButtonNode) {
        statusBarHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.videoNode.transform = CATransform3DIdentity
            self.closeButton.transform = CATransform3DIdentity
            self.contentNode.alpha = 0
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: { (_) in
            self.dismiss(animated: false)
        })
    }

    private func goFullScreen() {
        var transform = CATransform3DMakeRotation(-.pi/2, 0, 0, 1)
        let scale = UIScreen.main.bounds.height/self.videoNode.bounds.width
        transform = CATransform3DScale(transform, scale, scale, 1)
        let translation = closeButton.bounds.width + 19.clasp * 2 - UIScreen.main.bounds.width
        UIView.animate(withDuration: 0.2) {
            self.videoNode.transform = transform
            self.closeButton.transform = CATransform3DMakeTranslation(translation, 0, 0)
        }
    }

}
