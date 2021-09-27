//
//	DayStock.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import boss_model_protocol_ios
import SwiftyJSON
import boss_basic_common_ios

@objc public  class DayStock : NSObject, NSCoding, BOSSModelProtocol {


	var allStock : Int!
	var soldNum : Int!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
    required public init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		allStock = json["all_stock"].intValue
		soldNum = json["sold_num"].intValue
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if allStock != nil{
			dictionary["all_stock"] = allStock
		}
		if soldNum != nil{
			dictionary["sold_num"] = soldNum
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required public init(coder aDecoder: NSCoder)
	{
         allStock = aDecoder.decodeObject(forKey: "all_stock") as? Int
         soldNum = aDecoder.decodeObject(forKey: "sold_num") as? Int

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder)
	{
		if allStock != nil{
			aCoder.encode(allStock, forKey: "all_stock")
		}
		if soldNum != nil{
			aCoder.encode(soldNum, forKey: "sold_num")
		}

	}

}
