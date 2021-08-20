//
//	ProdutPriceModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import boss_model_protocol_ios
import SwiftyJSON
import boss_basic_common_ios

@objc public  class ProdutPriceModel : NSObject, NSCoding, BOSSModelProtocol {


	var id : String!
	var channelPriceModel : [ChannelPriceModel]!
	var name : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
    required public init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		id = json["_id"].stringValue
		channelPriceModel = [ChannelPriceModel]()
		let channelPriceModelArray = json["channel"].arrayValue
		for channelPriceModelJson in channelPriceModelArray{
			let value = ChannelPriceModel(fromJson: channelPriceModelJson)
			channelPriceModel.append(value)
		}
		name = json["name"].stringValue
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if id != nil{
			dictionary["_id"] = id
		}
		if channelPriceModel != nil{
			var dictionaryElements = [[String:Any]]()
			for channelPriceModelElement in channelPriceModel {
				dictionaryElements.append(channelPriceModelElement.toDictionary())
			}
			dictionary["channel"] = dictionaryElements
		}
		if name != nil{
			dictionary["name"] = name
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required public init(coder aDecoder: NSCoder)
	{
         id = aDecoder.decodeObject(forKey: "_id") as? String
         channelPriceModel = aDecoder.decodeObject(forKey: "channel") as? [ChannelPriceModel]
         name = aDecoder.decodeObject(forKey: "name") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder)
	{
		if id != nil{
			aCoder.encode(id, forKey: "_id")
		}
		if channelPriceModel != nil{
			aCoder.encode(channelPriceModel, forKey: "channel")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}

	}

}
