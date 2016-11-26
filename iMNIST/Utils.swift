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
		
		guard let imageRef = image.cgImage else {
			// handle error here
			return nil
		}
		return UIImage(cgImage: imageRef, scale: image.size.height/height, orientation: image.imageOrientation)
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
	
	// TODO: Use functionnal programming map instead of doing a for
	public class func convertUIntArrayToFloatArray(array: [UInt8]?)-> [Float]{
		
		var resultArray = [Float]()
		
		if let safeArray = array{
			for item in safeArray {
				resultArray.append(Float(item)/255.0)
			}
		}
		return resultArray
		
	}
	
	public class func convertImageToGrayVector(image: UIImage) -> [Float]? {
		
		if let image = convertToGrayScale(image: image), let safeCgImage = image.cgImage {
			return convertUIntArrayToFloatArray(array: pixelValuesFromImage(imageRef: safeCgImage))
		}
		return nil
	}
	
	public class func convertToGrayScale(image: UIImage) -> UIImage? {
		let imageRect:CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: image.size.width, height:  image.size.height))
		let colorSpace = CGColorSpaceCreateDeviceGray()
		let width = image.size.width
		let height = image.size.height
		
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
		if let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue), let cgImage = image.cgImage{
			context.draw(cgImage, in: imageRect)
			
			if let imageRef = context.makeImage(){
				let newImage = UIImage(cgImage: imageRef)
				return newImage
				
			}
		}
		return nil
	}
	
	
	public class func importBiasesFrom(file : String) -> BNNSLayerData?{
		if let path = Bundle.main.path(forResource: file, ofType: "data") {
			do {
				let data = try String(contentsOfFile: path, encoding: .utf8)
				
				var numString = ""
				var vector = [Double]()
				for c in data.characters{
					
					if(c == "," || c == "]"){
						if let numDouble = Double(numString){
							vector.append(numDouble)
						}
						numString = ""
					}else if (c == "["){
						vector = [Double]()
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
	
	public class func importWeightsFrom(file : String) -> BNNSLayerData?{
		if let path = Bundle.main.path(forResource: file, ofType: "data") {
			do {
				let data = try String(contentsOfFile: path, encoding: .utf8)
				
				var numString = ""
				var vector = [Double]()
				var matrice = [[Double]]()
				for c in data.characters{
					
					if(c == ","){
						if let numDouble = Double(numString){
							vector.append(numDouble)
						}
						numString = ""
						// TODO: - constants
					}else if (c == "]" && matrice.count < Constants.IN_COUNT){
						if let numDouble = Double(numString){
							vector.append(numDouble)
						}
						numString = ""
						
						matrice.append(vector)
					}else if (c == "["){
						vector = [Double]()
					}else if (c != " "){
						numString.append(c)
					}
				}
				
				return BNNSLayerData(data: matrice, data_type: BNNSDataTypeFloat32, data_scale: 0, data_bias: 0, data_table: nil)
			} catch {
				print(error)
			}
		}
		return nil
		
	}
}
