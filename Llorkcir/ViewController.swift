//
//  ViewController.swift
//  Llorkcir
//
//  Created by Seth Rininger on 11/21/18.
//  Copyright © 2018 Vimvest. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(FullScreenVideoController(), animated: true, completion: nil)
    }

}

