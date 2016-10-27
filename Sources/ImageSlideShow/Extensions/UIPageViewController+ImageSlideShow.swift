//
//  UIPageViewController+Extensions.swift
//
//  Created by Dimitri Giani on 14/01/16.
//  Copyright © 2016 Dimitri Giani. All rights reserved.
//

import UIKit

extension UIPageViewController
{
	//	ScrollView
	
	func scrollView() -> UIScrollView?
	{
		for view in self.view.subviews
		{
			if let scrollview = view as? UIScrollView
			{
				return scrollview
			}
		}
		
		return nil
	}
	
	func setScrollEnabled(enabled:Bool)
	{
		scrollView()?.scrollEnabled = enabled
	}
}
