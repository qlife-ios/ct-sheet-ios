//
//	DayModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import boss_model_protocol_ios
import SwiftyJSON
import boss_basic_common_ios

@objc public  class DayModel : NSObject, NSCoding, BOSSModelProtocol {

	var produtPriceList : [ProdutPriceModel]!
	var date : Int!
	var dateHoliday : String!
	var dateName : String!
	var dateType : Int!
	var dateWorkState : Int!
	var dayStock : DayStock!

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
    required public init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
        produtPriceList = [ProdutPriceModel]()
		let produtPriceModelArray = json["product_prices"].arrayValue
		for produtPriceModelJson in produtPriceModelArray{
			let value = ProdutPriceModel(fromJson: produtPriceModelJson)
            produtPriceList.append(value)
		}
		date = json["date"].intValue
		dateHoliday = json["date_holiday"].stringValue
		dateName = json["date_name"].stringValue
		dateType = json["date_type"].intValue
		dateWorkState = json["date_work_state"].intValue
		let dayStockJson = json["day_stock"]
		if !dayStockJson.isEmpty{
			dayStock = DayStock(fromJson: dayStockJson)
		}
		
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if produtPriceList != nil{
			var dictionaryElements = [[String:Any]]()
			for produtPriceModelElement in produtPriceList {
				dictionaryElements.append(produtPriceModelElement.toDictionary())
			}
			dictionary["product_prices"] = dictionaryElements
		}
		if date != nil{
			dictionary["date"] = date
		}
		if dateHoliday != nil{
			dictionary["date_holiday"] = dateHoliday
		}
		if dateName != nil{
			dictionary["date_name"] = dateName
		}
		if dateType != nil{
			dictionary["date_type"] = dateType
		}
		if dateWorkState != nil{
			dictionary["date_work_state"] = dateWorkState
		}
		if dayStock != nil{
			dictionary["day_stock"] = dayStock.toDictionary()
		}
		
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required public init(coder aDecoder: NSCoder)
	{
        produtPriceList = aDecoder.decodeObject(forKey: "product_prices") as? [ProdutPriceModel]
         date = aDecoder.decodeObject(forKey: "date") as? Int
         dateHoliday = aDecoder.decodeObject(forKey: "date_holiday") as? String
         dateName = aDecoder.decodeObject(forKey: "date_name") as? String
         dateType = aDecoder.decodeObject(forKey: "date_type") as? Int
         dateWorkState = aDecoder.decodeObject(forKey: "date_work_state") as? Int
         dayStock = aDecoder.decodeObject(forKey: "day_stock") as? DayStock

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder)
	{
		if produtPriceList != nil{
			aCoder.encode(produtPriceList, forKey: "product_prices")
		}
		if date != nil{
			aCoder.encode(date, forKey: "date")
		}
		if dateHoliday != nil{
			aCoder.encode(dateHoliday, forKey: "date_holiday")
		}
		if dateName != nil{
			aCoder.encode(dateName, forKey: "date_name")
		}
		if dateType != nil{
			aCoder.encode(dateType, forKey: "date_type")
		}
		if dateWorkState != nil{
			aCoder.encode(dateWorkState, forKey: "date_work_state")
		}
		if dayStock != nil{
			aCoder.encode(dayStock, forKey: "day_stock")
		}
		

	}

}
