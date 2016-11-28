//
//  DeepLearningModelTests.swift
//  iMNIST
//
//  Created by KEVIN on 11/26/16.
//  Copyright © 2016 KEVIN. All rights reserved.
//

import XCTest
@testable import iMNIST

class DeepLearningModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResize() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
	
	func testPixelValuesFromImage() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		
		
	}
	
	func testConvertPixelValuesArrayToNormalizedFloatArraySameValuesZero(){
		let array : [UInt8] = Array.init(repeating: 255, count: 10)
		
		Utils.convertPixelValuesArrayToNormalizedFloatArray(array: array).forEach { (item) in
			XCTAssertTrue(type(of: item) == Float.self)
			XCTAssertEqual(item,0)
			
		}
	}
	
	func testConvertPixelValuesArrayToNormalizedFloatArraySameValuesHalf(){
		let array : [UInt8] = Array.init(repeating: UInt8(127.5), count: 10)
		
		Utils.convertPixelValuesArrayToNormalizedFloatArray(array: array).forEach { (item) in
			XCTAssertTrue(type(of: item) == Float.self)
			XCTAssertLessThan(item, 0.6)
			XCTAssertGreaterThan(item, 0.4)
		}
	}
	
	func testConvertPixelValuesArrayToNormalizedFloatArrayPrecision(){
		let array : [UInt8] = Array.init(repeating: UInt8(229.5), count: 10)
		
		Utils.convertPixelValuesArrayToNormalizedFloatArray(array: array).forEach { (item) in
			XCTAssertTrue(type(of: item) == Float.self)
			XCTAssertLessThan(item, 0.11)
			XCTAssertGreaterThan(item, 0.09)
		}
	}
	
	func testConvertPixelValuesArrayToNormalizedFloatArraySameValuesOne(){
		let array : [UInt8] = Array.init(repeating: 0, count: 10)
		
		Utils.convertPixelValuesArrayToNormalizedFloatArray(array: array).forEach { (item) in
			XCTAssertTrue(type(of: item) == Float.self)
			XCTAssertEqual(item,1)
		}
	}
	

	func testConvertImageToGrayVector(){
		//UIImage()
		//XCTAssertEqual(Utils.convertImageToGrayVector(image: <#T##UIImage#>) , <#T##expression2: [T]##[T]#>)
		
	}
	
	func testSoftmaxTestOneValue(){
		let array = [0] as [Float]
		XCTAssertEqual(Utils.softmax(inArray: array, size: array.count), [1] as [Float])
	}
	
	func testSoftmaxTestTwoNegativeNormalizedValues(){
		let array = [-1,-2] as [Float]
		let softmaxZero = expf(-2)/(expf(-1)+expf(-2))
		let softmaxUn = expf(-1)/(expf(-1)+expf(-2))
		XCTAssertEqual(Utils.softmax(inArray: array, size: array.count), [softmaxUn,softmaxZero] as [Float])
	}
	
	func testSoftmaxTestTwoNormalizedValues(){
		let array = [1,0] as [Float]
		let softmaxZero = expf(0)/(expf(1)+expf(0))
		let softmaxUn = expf(1)/(expf(1)+expf(0))
		XCTAssertEqual(Utils.softmax(inArray: array, size: array.count), [softmaxUn,softmaxZero] as [Float])
	}
	
	
	func testSoftmaxTestTwoEqualValues(){
		let array = [0,0] as [Float]
		XCTAssertEqual(Utils.softmax(inArray: array, size: array.count), [0.5,0.5] as [Float])
	}
	
	
	func testSoftmaxTestTwoNan(){
		let array = [Float.nan,Float.nan] as [Float]
		
		for item in Utils.softmax(inArray: array, size: array.count){
			XCTAssertTrue(item.isNaN)
		}
	}

	
	func testSoftmaxTestReallySmallValue(){
		let array = [1.8e-80,1.9e-30,6] as [Float]
		
		for item in Utils.softmax(inArray: array, size: array.count){
			print(item)
			XCTAssertFalse(item.isNaN)
		}
	}
	
	func testSoftmaxTestTwoInf(){
		let array = [Float.infinity,Float.infinity] as [Float]
		for item in Utils.softmax(inArray: array, size: array.count){
			XCTAssertTrue(item.isNaN)
		}
	}
	
	
	
	
	
//	func convertToGrayScale(){
//		
//	}
//	
//	
//	func importBiasesFrom(){
//		
//	}
//	
//	func importWeightsFrom(){
//		
//	}
	
	
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
	
}
