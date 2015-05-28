//
//  NavigationControllerDelegate.swift
//  StanfordMap
//
//  Created by Anna Wang on 5/27/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
   
    func navigationController(navigationController: UINavigationController,
        animationControllerForOperation operation: UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            if fromVC.isMemberOfClass(MapViewController){
                return CircleTransitionAnimator()
            } else {
                return nil
            }
    }
}
