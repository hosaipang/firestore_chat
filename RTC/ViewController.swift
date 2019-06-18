//
//  ViewController.swift
//  RTC
//
//  Created by king on 29/4/2019.
//  Copyright © 2019 Real. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rtc = RTCManager();
        rtc.setup()
    }


}

