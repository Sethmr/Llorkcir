//
//  FullScreenVideoController.swift
//  Llorkcir
//
//  Created by Seth Rininger on 11/21/18.
//  Copyright © 2018 Vimvest. All rights reserved.
//

import AsyncDisplayKit

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
        let button = ASButtonNode()
        let image: UIImage = #imageLiteral(resourceName: "NavBarXIcon")
        button.setImage(image, for: .normal)
        button.imageNode.style.preferredLayoutSize = image.size.clasp.asl
        button.imageNode.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(close), forControlEvents: .touchUpInside)
        button.hitTestSlop = UIEdgeInsets(top: -25.clasp, left: -25.clasp, bottom: -25.clasp, right: -25.clasp)
        return button
    } ()

    lazy var fullScreenButton: ASDisplayNode = {
        let button = ASButtonNode()
        button.addTarget(self, action: #selector(goFullScreen), forControlEvents: .touchUpInside)
        button.backgroundColor = .white
        button.cornerRadius = 4.clasp
        button.setTitle("Go Full Screen", with: .systemFont(ofSize: 12.clasp, weight: .medium), with: .black, for: .normal)
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

    @objc func goFullScreen(_ sender: ASButtonNode) {
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
