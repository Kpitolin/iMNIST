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
	

	var weightVector : BNNSLayerData
	var biasVector : BNNSLayerData
	var inputVectorSize : Int
	var outputVectorSize : Int
	
	init?(weightVector : BNNSLayerData?, biasVector: BNNSLayerData?, inputVectorSize : Int, outputVectorSize: Int) {
		
		if let weightVector = weightVector, let biasVector = biasVector {
			self.weightVector = weightVector
			self.biasVector = biasVector
		}else if let safeBiasVector = Utils.importBiasesFrom(file: Constants.BIASES_FILENAME), let safeWeightVector = Utils.importWeightsFrom(file: Constants.WEIGHTS_FILENAME){
				self.biasVector = safeBiasVector
				self.weightVector = safeWeightVector
		}else{
			return nil
		}

		self.inputVectorSize = inputVectorSize
		self.outputVectorSize = outputVectorSize
		
	}
	

	func inferResultsFromImage(image: UIImage) -> [Float]?{

		var outArray : [Float]?

		// Define form of the input and ouput vectors (descriptors)
		var inVectorDescriptor : BNNSVectorDescriptor = BNNSVectorDescriptor(size: inputVectorSize, data_type: BNNSDataTypeFloat32, data_scale: 0, data_bias: 0)
		var outVectorDescriptor : BNNSVectorDescriptor = BNNSVectorDescriptor(size: outputVectorSize, data_type: BNNSDataTypeFloat32, data_scale: 0, data_bias: 0)
		
		// Import the weights and biases
		
		// Create the one and only layer of this NN
		var parameters : BNNSFullyConnectedLayerParameters = BNNSFullyConnectedLayerParameters(in_size: inputVectorSize, out_size: outputVectorSize, weights: weightVector, bias: biasVector, activation: BNNSActivation(function: BNNSActivationFunctionIdentity,alpha: 1,beta: 1))
		
		
		// Create the filter

		let filter = BNNSFilterCreateFullyConnectedLayer(&inVectorDescriptor,
		                                                 &outVectorDescriptor,
		                                                 &parameters,nil)
		
		// Convert output image to a MNIST compatible format  : a normalized vector of pixel values from a grayscale 28*28 image
		if let resizedImage = Utils.resize(image: image, with: CGFloat(Constants.MNIST_IMAGE_WIDTH)){
			
			if let safeInBuffer = Utils.convertImageToGrayVector(image: resizedImage){
				// we allocate typed memory for the output
				var outBuffer : [Float] = Array.init(repeating: 0.0, count: Constants.OUT_COUNT )
				// Here we do the inference
				let success = BNNSFilterApply(filter, safeInBuffer, &outBuffer)
				
				if (success == -1){
					print("Error: BNNS inference failed")
					outArray = nil
				}else{
					
					outArray = Utils.softmax(inArray: outBuffer, size: Constants.OUT_COUNT)
				}
			}
		}
		BNNSFilterDestroy(filter)

		return outArray
	}
	
	
}
