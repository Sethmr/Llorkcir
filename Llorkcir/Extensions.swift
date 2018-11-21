//
//  Extensions.swift
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

    var asd: ASDimension {
        return ASDimension(unit: .points, value: self)
    }

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
