//
//  Utils.swift
//  iMNIST
//
//  Created by KEVIN on 11/26/16.
//  Copyright © 2016 KEVIN. All rights reserved.
//

import UIKit
import Accelerate

class Utils {

	
	public class func resize(image: UIImage, with height: CGFloat) -> UIImage?{
		
		let scale = height / image.size.height
		let width = round(image.size.width * scale)
		
		UIGraphicsBeginImageContext(CGSize(width: width, height: height))
		
		
		image.draw(in: CGRect(x: 0, y: 0,width: width, height: height))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
	
	// TODO: figure out why we have so much values and how to get down to 784 : one value per pixel
	public class func pixelValuesFromImage(imageRef: CGImage?) -> [UInt8]?
	{
		var width = 0
		var height = 0
		var pixelValues: [UInt8]?
		if let imageRef = imageRef {
			width = imageRef.width
			height = imageRef.height
			let bitsPerComponent = imageRef.bitsPerComponent
			let bytesPerRow = imageRef.bytesPerRow
			let totalBytes = height * bytesPerRow
			
			let colorSpace = CGColorSpaceCreateDeviceGray()
			pixelValues = [UInt8](repeating: 0, count: totalBytes)
			
			let contextRef = CGContext(data: &pixelValues!, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
			contextRef?.draw(imageRef, in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))
		}
		
		return pixelValues
	}
	
	public class func convertPixelValuesArrayToNormalizedFloatArray(array: [UInt8]?)-> [Float]{
		
		var resultArray = [Float]()
		
		if let safeArray = array{
			for item in safeArray {
				resultArray.append(Float(item)/255.0)
			}
		}
		
		// We take the complementary here : grayscale consider white as 1, we need it to be 0
		resultArray = resultArray.map{ 1 - $0 }
		return resultArray
		
	}
	
	public class func convertImageToGrayVector(image: UIImage) -> [Float]? {
		if let safeImage = convertToGrayScale(image: image), let safeCgImage = safeImage.cgImage{
			return convertPixelValuesArrayToNormalizedFloatArray(array: pixelValuesFromImage(imageRef: safeCgImage))
		}
		return nil
	}
	
	public class func convertToGrayScale(image: UIImage) -> UIImage? {
		let imageRect:CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: image.size.width, height:  image.size.height))
		let colorSpace = CGColorSpaceCreateDeviceGray()
		let width = image.size.width
		let height = image.size.height
		
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
		if let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: Constants.MNIST_IMAGE_WIDTH, space: colorSpace, bitmapInfo: bitmapInfo.rawValue), let cgImage = image.cgImage?.copy(){
			
			// As the image contains just the handwriting, we draw a white rectangle (the model won't interpret alpha well)
			context.setFillColor(gray: 1, alpha: 1)
			context.fill(imageRect)
			context.draw(cgImage, in: imageRect)
			
			if let imageRef = context.makeImage(){
				let newImage = UIImage(cgImage: imageRef)
				return newImage
				
			}
		}
		return nil
	}
	
	// TODO: - output Float vector
	public class func importBiasesFrom(file : String) -> BNNSLayerData?{
		if let path = Bundle.main.path(forResource: file, ofType: "data") {
			do {
				let data = try String(contentsOfFile: path, encoding: .utf8)
				
				var numString = ""
				var vector = [Float]()
				for c in data.characters{
					
					if(c == "," || c == "]"){
						if let numFloat = Float(numString){
							vector.append(numFloat)
						}
						numString = ""
					}else if (c == "["){
						vector = [Float]()
					}else if (c != " "){
						numString.append(c)
					}
				}
				
				return BNNSLayerData(data: vector, data_type: BNNSDataTypeFloat32, data_scale: 0, data_bias: 0, data_table: nil)
			} catch {
				print(error)
			}
		}
		return nil
	}
	
	// TODO: - output Float vector
	public class func importWeightsFrom(file : String) -> BNNSLayerData?{
		if let path = Bundle.main.path(forResource: file, ofType: "data") {
			do {
				let data = try String(contentsOfFile: path, encoding: .utf8)
				
				var numString = ""
				var vector = [Float]()
				var matrice = [[Float]]()
				for c in data.characters{
					
					if(c == ","){
						if let numFloat = Float(numString){
							vector.append(numFloat)
						}
						numString = ""
						// TODO: - constants
					}else if (c == "]" && matrice.count < Constants.IN_COUNT){
						if let numFloat = Float(numString){
							vector.append(numFloat)
						}
						numString = ""
						
						matrice.append(vector)
					}else if (c == "["){
						vector = [Float]()
					}else if (c != " "){
						numString.append(c)
					}
				}
				
				// Invert the dimensions of the matrice
				var outMatrice = [[Float]]()
				let countY = matrice[0].count
				outMatrice = Array.init(repeating: Array.init(repeating:0, count:matrice.count), count: countY)
				for i in 0...matrice.count-1{
					for j in 0...matrice[i].count-1{
						outMatrice[j].insert(matrice[i][j], at: i)
					}
				}
				
				return BNNSLayerData(data: matrice, data_type: BNNSDataTypeFloat32, data_scale: 0, data_bias: 0, data_table: nil)
			} catch {
				print(error)
			}
		}
		return nil
		
	}
	
	
	public class func softmax(inArray : [Float], size : Int) -> [Float]
	{
		// Temporary buffer
		var ebuffer = [Float]()
		var out = [Float]()
		// Sum of exponentials
		var esum : Float = 0.0
		
		// Step through the in array, take the exponential of it.
		// Put it in 'ebuffer' and keep a running sum
		for i in 0...size-1 {
			print(inArray[i])
			let ed = expf(inArray[i])
			print(ed)
			esum += ed
			print(esum)
			ebuffer.append(ed)
		}
		
		// The output is the exponentials scaled so they
		// sum to 1.0
		for i in 0...size-1 {
			out.append(ebuffer[i]/esum)
		}
		return out
	}
}
