//
//  UIView + Blink.swift
//  WakyZzz
//
//  Created by James Tapping on 09/09/2021.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
     func blink() {
        self.alpha = 0.5
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn, .repeat, .autoreverse, .allowUserInteraction], animations: {self.alpha = 1.0}, completion: nil)
     }
}
