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
	

	var filter : BNNSFilter?
	
	override init() {
		super.init()
		buildMNISTModel()
	}

	func buildMNISTModel(){
		// Import the weights and biases


		if let safeBiasVector = Utils.importBiasesFrom(file: Constants.BIASES_FILENAME), let safeWeightVector = Utils.importWeightsFrom(file: Constants.WEIGHTS_FILENAME){

		// Define form of the input and ouput vectors (descriptors)
		var inVectorDescriptor : BNNSVectorDescriptor = BNNSVectorDescriptor(size: Constants.IN_COUNT, data_type: BNNSDataTypeFloat32, data_scale: 0, data_bias: 0)
		var outVectorDescriptor : BNNSVectorDescriptor = BNNSVectorDescriptor(size: Constants.OUT_COUNT, data_type: BNNSDataTypeFloat32, data_scale: 0, data_bias: 0)
		
		
		// Create the one and only layer of this NN
		
		var parameters : BNNSFullyConnectedLayerParameters = BNNSFullyConnectedLayerParameters(in_size: Constants.IN_COUNT, out_size: Constants.OUT_COUNT, weights: safeWeightVector, bias: safeBiasVector, activation: BNNSActivation(function: BNNSActivationFunctionIdentity,alpha: 0,beta: 0))
		
		
		// Create the filter
		
		if let safeFilter = BNNSFilterCreateFullyConnectedLayer(&inVectorDescriptor,
		                                                 &outVectorDescriptor,
		                                                 &parameters,nil){
			filter = safeFilter
			}
		}
	}

	func inferResultsFromImage(image: UIImage) -> [Float]?{

		var outArray : [Float]?

		
		
		// Convert output image to a MNIST compatible format  : a normalized vector of pixel values from a grayscale 28*28 image
		if let resizedImage = Utils.resize(image: image, with: CGFloat(Constants.MNIST_IMAGE_WIDTH)){
			
			if let safeInBuffer = Utils.convertImageToGrayVector(image: resizedImage), let filter = filter{
				// we allocate typed memory for the output
				var outBuffer : [Float] = Array.init(repeating: 0.0, count: Constants.OUT_COUNT )
				// Here we do the inference
				let inArray = safeInBuffer
				let success = BNNSFilterApply(filter, inArray, &outBuffer)
				if (success == -1){
					print("Error: BNNS inference failed")
					outArray = nil
				}else{
					print("output: \(outBuffer)")
					outArray = Utils.softmax(inArray: outBuffer, size: Constants.OUT_COUNT, ignoreNaN: true)
				}
			}
		}

		return outArray
	}
	
	
}
