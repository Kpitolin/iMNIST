//
//  ViewController.swift
//  iMNIST
//
//  Created by KEVIN on 11/22/16.
//  Copyright © 2016 KEVIN. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	// the imageview must be square or we have to crop
	// MARK: - UI elements
	@IBOutlet weak var mainImgView: UIImageView!
	@IBOutlet weak var tempImgView: UIImageView!
	@IBOutlet weak var resultLabel: UILabel!
	var uiImage : UIImage?

	// MARK: - Drawing Attributes
	var model = DeepLearningModel(weightVector: nil, biasVector: nil, inputVectorSize: Constants.IN_COUNT, outputVectorSize: Constants.OUT_COUNT)
	var lastPoint = CGPoint.zero
	var red: CGFloat = 0.0
	var green: CGFloat = 0.0
	var blue: CGFloat = 0.0
	var brushWidth: CGFloat = 5.0
	var opacity: CGFloat = 1.0
	var swiped = false
	// MARK: - Other Attributes
	var timer = Timer()
	var results = [Float]()


	
	// MARK: - UIViewController lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		resultLabel.text = ""
	}
	

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Drawing-related methods
	// The drawing part was heavily inspired by Ray Wenderlich tutorial website : https://www.raywenderlich.com/87899/make-simple-drawing-app-uikit-swift
	func drawLineFrom(firstPoint: CGPoint, to lastPoint: CGPoint) {
		
		// 1
		UIGraphicsBeginImageContext(tempImgView.frame.size)
		let context : CGContext? = UIGraphicsGetCurrentContext()
		
		if context != nil {
			tempImgView.image?.draw(in: CGRect(x: 0, y: 0, width: tempImgView.frame.size.width, height: tempImgView.frame.size.height))
			
			// 2
			context?.move(to: firstPoint)
			context?.addLine(to: lastPoint)
			
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
			UIGraphicsEndImageContext()
		}else{
			let alertVC = UIAlertController(title: "Error", message: "Impossible to draw. Relaunch app and try again later.", preferredStyle: .alert)
			alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
			self.show(alertVC, sender: nil)
		}
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
	
	// MARK: - Timer methods
	
	func startTimer(){
		timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.startFadeAnimation), userInfo: nil, repeats: false)
	}
	
	func cancelTimer(){
		timer.invalidate()
	}
	
	// MARK : - UIResponder methods
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		swiped = false
		cancelTimer()
		if let touch = touches.first{
			lastPoint = touch.location(in: self.tempImgView)
		}
	}
	

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		if !swiped {
		// draw a single point
			drawLineFrom(firstPoint: lastPoint, to: lastPoint)
		}
		

		// we do that only if it was in mainImgView
		touches.forEach { (touch) in
			print(touch.location(in: mainImgView))
		}
		// Merge tempImgView into mainImgView
		UIGraphicsBeginImageContext(mainImgView.frame.size)
			mainImgView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImgView.frame.width, height: mainImgView.frame.size.height), blendMode: .normal, alpha: 1.0)
			tempImgView.image?.draw(in: CGRect(x: 0, y: 0, width: tempImgView.frame.size.width, height: tempImgView.frame.size.height), blendMode: .normal, alpha: opacity)
		
		mainImgView.image = UIGraphicsGetImageFromCurrentImageContext()
		if let cgimage = mainImgView.image?.cgImage?.copy(){
			uiImage = UIImage(cgImage: cgimage)
		}
		UIGraphicsEndImageContext()
		tempImgView.image = nil
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		// 6
		
		// we do that only if it was in mainImgView
		swiped = true
		if let touch = touches.first {
			let currentPoint = touch.location(in: tempImgView)
			drawLineFrom(firstPoint: lastPoint, to: currentPoint)
			// 7
			lastPoint = currentPoint
		}
	}
	
	
	// MARK: - Actions
	@IBAction func computeAction(_ sender: AnyObject) {
		inferDigitFromImage()
	}
	
	// MARK: - CNN-related methods
	
	func inferDigitFromImage(){
		if let model = model, let image = uiImage {
			if let safeResults = model.inferResultsFromImage(image: image) {
				results = safeResults
				print(results)
				startTimer()
			}else{
				let alertVC = UIAlertController(title: "Error", message: "BNNS inference failed", preferredStyle: .alert)
				alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
				self.show(alertVC, sender: nil)
			}
		}
	}
	

}

