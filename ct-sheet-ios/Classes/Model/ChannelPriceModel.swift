//
//	ChannelPriceModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import boss_model_protocol_ios
import SwiftyJSON
import boss_basic_common_ios

@objc public  class ChannelPriceModel : NSObject, NSCoding, BOSSModelProtocol {


	var allowStock : Int! // 可用库存
	var channel : Int! // 渠道
	var price : Int! // 价格
    var channelImg: String?{
        get{
            switch self.channel {
                case 10:
                    return "channel_tujia"
                    
                case 20:
                    return "channel_airbnb"
                    
                case 30:
                    return "channel_xiaozhu"
                    
                case 40:
                    return "channel_zhenguo"
                    
                case .none:
                    return ""
                    
                case .some(_):
                    return ""
            }
        }
    }


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
    required public init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
        if json["allow_stock"].stringValue.count > 0 {
            allowStock = json["allow_stock"].intValue
        }else{
            allowStock = -1
        }
        
        if json["price"].stringValue.count > 0 {
            price = json["price"].intValue
        }else{
            price = -1
        }
		channel = json["channel"].intValue

	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if allowStock != nil{
			dictionary["allow_stock"] = allowStock
		}
		if channel != nil{
			dictionary["channel"] = channel
		}
		if price != nil{
			dictionary["price"] = price
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required public init(coder aDecoder: NSCoder)
	{
         allowStock = aDecoder.decodeObject(forKey: "allow_stock") as? Int
         channel = aDecoder.decodeObject(forKey: "channel") as? Int
         price = aDecoder.decodeObject(forKey: "price") as? Int
	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder)
	{
		if allowStock != nil{
			aCoder.encode(allowStock, forKey: "allow_stock")
		}
		if channel != nil{
			aCoder.encode(channel, forKey: "channel")
		}
		if price != nil{
			aCoder.encode(price, forKey: "price")
		}

	}

}
