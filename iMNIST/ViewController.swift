//
//  ViewController.swift
//  iMNIST
//
//  Created by KEVIN on 11/22/16.
//  Copyright © 2016 KEVIN. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var mainImgView: UIImageView!
	@IBOutlet weak var tempImgView: UIImageView!
	
	// MARK: - Drawing Attributes
	
	var lastPoint = CGPoint.zero
	var red: CGFloat = 0.0
	var green: CGFloat = 0.0
	var blue: CGFloat = 0.0
	var brushWidth: CGFloat = 1.0
	var opacity: CGFloat = 1.0
	var swiped = false
	
	// MARK: - Other Attributes

	var timer = Timer()

	
	// MARK: - UIViewController lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Drawing-related methods
	// The drawing part was heavily inspired by Ray Wenderlich tutorial website : https://www.raywenderlich.com/87899/make-simple-drawing-app-uikit-swift
	func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
	
		
		// 1
		UIGraphicsBeginImageContext(view.frame.size)
		let context = UIGraphicsGetCurrentContext()
		
		tempImgView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
		
		// 2
		context?.move(to: fromPoint)
		context?.addLine(to: toPoint)
		
		// 3
		context?.setLineCap(.round)
		context?.setLineWidth(brushWidth)
		context?.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor)
		context?.setBlendMode(.normal)
		
		// 4
		context?.strokePath()
		
		// 5
		tempImgView.image = UIGraphicsGetImageFromCurrentImageContext()
		tempImgView.alpha = opacity
		//let uiImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		
	}
	
	func resetCanvas(){
		mainImgView.image = nil
	}
	
	func startFadeAnimation() {
		UIView.animate(withDuration: 2.0, animations: {
			self.mainImgView.alpha = 0
			}) { (finished) in
				if (finished){
					self.mainImgView.image = nil
					self.mainImgView.alpha = 1
				}

		}
		
	}
	
	
	func startTimer(){
		timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.startFadeAnimation), userInfo: nil, repeats: false)
	}
	
	func cancelTimer(){
		timer.invalidate()
	}
	
	// MARK : - UIResponder methods
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		swiped = false
		timer.invalidate()
		if let touch = touches.first{
			lastPoint = touch.location(in: self.view)
		}
	}
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	  if !swiped {
		// draw a single point
		drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
	  }
			
	  // Merge tempImgView into mainImgView
	  UIGraphicsBeginImageContext(mainImgView.frame.size)
	  mainImgView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: 1.0)
	  tempImgView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: opacity)
	  mainImgView.image = UIGraphicsGetImageFromCurrentImageContext()
	  UIGraphicsEndImageContext()
			
	  tempImgView.image = nil
	  startTimer()
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		// 6
		swiped = true
		if let touch = touches.first {
			let currentPoint = touch.location(in: view)
			drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
			
			// 7
			lastPoint = currentPoint
		}
	}

}

