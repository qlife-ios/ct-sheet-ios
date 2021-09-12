//
//	DayModel.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import boss_model_protocol_ios
import SwiftyJSON
import boss_basic_common_ios

@objc public  class DayModel : NSObject, NSCoding, BOSSModelProtocol {

	var produtPriceList : [ProdutPriceModel]!   // 不同房型的房价列表
	var date : Int!   // 日期
	var dateHoliday : String!  // 节假日
	var dateName : String!   // 节假日名称
	var dateType : Int!       // 日期类型 -1空 0补班 1假日当天 2假日 3不放假的假日
	var dateWorkState : Int!  // 节假日是否上班 -1空 0不上班 1上班
	var dayStock : DayStock!   // 当日库存情况
    var isBefore: Bool = true

    // 展示日期
    var dayStr: Int = 1
    // 是不是今天
    var isToday: Bool = false
    
    var weekStr: Int = 1
    
    var showWeek: String = "一"
    
    var yearMonthDay: String? // 年月日
    
	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
    required public init(fromJson json: JSON!){
		if json.isEmpty{
			return
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
        let inDate = Date.intChangeDate(resultDate: self.date ?? 0)
        self.yearMonthDay = Date.changeTimesFormatContainYearMouthDayAndLine(date: inDate).0
        isToday = inDate.isToday()
        dayStr = inDate.getYearMonthAndDay().2
        self.isBefore = inDate.isBefore()
        produtPriceList = [ProdutPriceModel]()
        let produtPriceModelArray = json["product_prices"].arrayValue
        for produtPriceModelJson in produtPriceModelArray{
            let value = ProdutPriceModel(fromJson: produtPriceModelJson)
            produtPriceList.append(value)
        }
        let dateFormater = Date.intChangeDate(resultDate: date ?? 0)
        self.weekStr = dateFormater.getDateWeekDay()
        switch self.weekStr {
            case 1:
                self.showWeek = "一"
            case 2:
                self.showWeek = "二"
            case 3:
                self.showWeek = "三"
            case 4:
                self.showWeek = "四"
            case 5:
                self.showWeek = "五"
            case 6:
                self.showWeek = "六"
            case 7:
                self.showWeek = "日"
            default:
                self.showWeek = "一"
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
