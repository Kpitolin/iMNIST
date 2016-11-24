//
//  DeepLearningModel.swift
//  The purpose of this class is to define a CNN model structure, import the weights and biases from a trained CNN, and do inference from it
//  iMNIST
//
//  Created by KEVIN on 11/23/16.
//  Copyright © 2016 KEVIN. All rights reserved.
//

import UIKit
import Accelerate


class DeepLearningModel: NSObject {
	
	let IN_COUNT = 784
	let OUT_COUNT = 10
	var weightVector = BNNSLayerData()
	var biasVector = BNNSLayerData()
	
	
	
	func resize(image: UIImage, with height: CGFloat) -> UIImage?{
		
		guard let imageRef = image.cgImage else {
			// handle error here
			return nil
		}
		 return UIImage(cgImage: imageRef, scale: image.size.height/height, orientation: image.imageOrientation)
	}
	
	
	// TODO: figure out why we have so much values and how to get down to 784 : one value per pixel
	func pixelValuesFromImage(imageRef: CGImage?) -> [UInt8]?
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
	func convertUIntArrayToFloatArray(array: [UInt8]?)-> [Float]{
		
		var resultArray = [Float]()
		
		if let safeArray = array{
			for item in safeArray {
				resultArray.append(Float(item)/255.0)
			}
		}
		return resultArray
		
	}
	
	func convertImageToGrayVector(image: UIImage) -> [Float]? {
		
		if let image = convertToGrayScale(image: image), let safeCgImage = image.cgImage {
			return convertUIntArrayToFloatArray(array: pixelValuesFromImage(imageRef: safeCgImage))
		}
		return nil
	}
	
	func convertToGrayScale(image: UIImage) -> UIImage? {
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
	

	
	//		// Describe input stack
	//		let in_stack = BNNSImageStackDescriptor(width: <#T##Int#>,
	//		                                        height: <#T##Int#>,
	//		                                        channels: <#T##Int#>,
	//		                                        row_stride: <#T##Int#>, // increment to next row
	//			image_stride: <#T##Int#>, // increment to next channel (pix)
	//			data_type: BNNSDataTypeFloat32,
	//			data_scale: 1,
	//			data_bias: 0)
	
	func inferResultsFromImage(image: UIImage) -> [Float]?{

		var inVectorDescriptor : BNNSVectorDescriptor = BNNSVectorDescriptor(size: IN_COUNT, data_type: BNNSDataTypeFloat32, data_scale: 0, data_bias: 0)
		var outVectorDescriptor : BNNSVectorDescriptor = BNNSVectorDescriptor(size: OUT_COUNT, data_type: BNNSDataTypeFloat32, data_scale: 0, data_bias: 0)
		
		
		 importCNN()
		
		var parameters : BNNSFullyConnectedLayerParameters = BNNSFullyConnectedLayerParameters(in_size: IN_COUNT, out_size: OUT_COUNT, weights: weightVector, bias: biasVector, activation: BNNSActivation(function: BNNSActivationFunctionIdentity,alpha: 1,beta: 1))
		
		
		// Create the filter
		//var filterParams = BNNSFilterParameters()
		//filterParams.
		let filter = BNNSFilterCreateFullyConnectedLayer(&inVectorDescriptor,
		                                                 &outVectorDescriptor,
		                                                 &parameters,nil)
		
		
		if let resizedImage = resize(image: image, with: 28), var safeInBuffer = convertImageToGrayVector(image: resizedImage){
			
			// Fill inBuffer with input here
			
			var outBuffer = [Float]()
			safeInBuffer.removeSubrange(784..<safeInBuffer.count)
			
			let success = BNNSFilterApply(filter, safeInBuffer, &outBuffer)
			
			if (success == -1){
				// Handle error here
				print("Error: inference failed")
			}
			
			//BNNSFilterDestroy(filter)
			
			return outBuffer
		}
		
		return nil
		
	}
	
	func importCNN(){
		if let safeBiasVector = importBiasesFrom(file: "biases"), let safeWeightVector = importWeightsFrom(file: "weights"){
			biasVector = safeBiasVector
			weightVector = safeWeightVector
		}else{
			// handler error here
		}
	}
	
	func importBiasesFrom(file : String) -> BNNSLayerData?{
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
	
	func importWeightsFrom(file : String) -> BNNSLayerData?{
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
					}else if (c == "]" && matrice.count < 784){
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
