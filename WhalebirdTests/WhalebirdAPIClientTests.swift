//
//  WhalebirdAPIClientTests.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/02/24.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit
import XCTest

class WhalebirdAPIClientTests: XCTestCase {
    
    func testConvertLocalTime() {
        let utcTimeString = "2015-02-24 18:11"
        var jstTimeString = WhalebirdAPIClient.convertLocalTime(utcTimeString)
        XCTAssertEqual(jstTimeString, "02月25日 03:11", "convert local time should success")
    }
    
    func testEscapeString() {
        let specialString = "5&gt;1&amp;&amp;109&lt;290&quot;"
        var escapedString = WhalebirdAPIClient.escapeString(specialString)
        XCTAssertEqual(escapedString, "5>1&&109<290\"", "escape special string should success")
    }
    
    func testCleanDictionary() {
        var nullDictionary = NSMutableDictionary()
        var nullChildDictionary = NSMutableDictionary()
        nullChildDictionary.setValue(NSNull(), forKey: "nullObject")
        nullChildDictionary.setValue(1, forKey: "intObject")
        nullDictionary.setValue(2, forKey: "intObject")
        nullDictionary.setValue(NSNull(), forKey: "nullObject")
        nullDictionary.setValue(nullChildDictionary, forKey: "childDictionary")
        
        var notNullDictionary = WhalebirdAPIClient.sharedClient.cleanDictionary(nullDictionary)
        
        XCTAssertEqual(notNullDictionary.objectForKey("intObject") as Int, 2, "int object should not touch")
        XCTAssertEqual(notNullDictionary.objectForKey("nullObject") as String, "", "null objecct should convert string")
        XCTAssertEqual(notNullDictionary.objectForKey("childDictionary")?.objectForKey("intObject") as Int, 1, "int object should not touch")
        XCTAssertEqual(notNullDictionary.objectForKey("childDictionary")?.objectForKey("nullObject") as String, "", "null object should convert string")
        
    }

}
