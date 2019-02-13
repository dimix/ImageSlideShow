//
//  ImageSlideShowNavigationController.swift
//
//  Created by Dimitri Giani on 27/10/2016.
//  Copyright © 2016 Dimitri Giani. All rights reserved.
//

import UIKit

class ImageSlideShowNavigationController: UINavigationController {
	
	override var childForStatusBarStyle: UIViewController? {
		return topViewController
	}
	
	override var prefersStatusBarHidden: Bool {
		return viewControllers.last?.prefersStatusBarHidden ?? false
	}
}
