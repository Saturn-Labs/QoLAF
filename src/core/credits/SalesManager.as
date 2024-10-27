package core.credits
{
	import core.scene.Game;
	import playerio.Message;
	
	public class SalesManager
	{
		public static const TYPE_FLUX:String = "flux";
		
		public static const TYPE_ITEM:String = "item";
		
		public static const TYPE_SPECIAL_SKIN:String = "sskin";
		
		public static const TYPE_PACKAGE:String = "pack";
		
		public static var eventList:Vector.<SaleEvent> = null;
		
		public var saleList:Vector.<Sale>;
		
		private var g:Game;
		
		public function SalesManager(param1:Game)
		{
			saleList = new Vector.<Sale>();
			super();
			this.g = param1;
		}
		
		public static function isSalePeriod():Boolean
		{
			var _loc1_:SaleEvent = null;
			if (eventList == null)
			{
				eventList = new Vector.<SaleEvent>();
				_loc1_ = new SaleEvent(2016, 10, 28, 7, 96);
				eventList.push(_loc1_);
			}
			for each (var _loc2_:* in eventList)
			{
				if (_loc2_.isNow())
				{
					return true;
				}
			}
			return false;
		}
		
		public function refresh():void
		{
			g.rpc("refreshSales", listArrived);
		}
		
		private function listArrived(param1:Message):void
		{
			var _loc3_:int = 0;
			var _loc2_:Sale = null;
			_loc3_ = 0;
			while (_loc3_ < param1.length)
			{
				_loc2_ = new Sale(g);
				_loc2_.type = param1.getString(_loc3_++);
				_loc2_.startTime = param1.getNumber(_loc3_++);
				_loc2_.endTime = param1.getNumber(_loc3_++);
				_loc2_.key = param1.getString(_loc3_++);
				_loc2_.vaultKey = param1.getString(_loc3_++);
				_loc2_.saleBonus = param1.getInt(_loc3_++);
				_loc2_.normalPrice = param1.getInt(_loc3_++);
				_loc2_.salePrice = param1.getInt(_loc3_++);
				_loc2_.description = param1.getString(_loc3_);
				saleList.push(_loc2_);
				_loc3_++;
			}
		}
		
		public function isSkinSale(param1:String = null):Boolean
		{
			for each (var _loc2_:* in saleList)
			{
				if (_loc2_.type == "item" && _loc2_.isNow() && (param1 == null || _loc2_.key == param1 || _loc2_.vaultKey == param1))
				{
					return true;
				}
			}
			return false;
		}
		
		public function getSkinSale(param1:String):Sale
		{
			for each (var _loc2_:* in saleList)
			{
				if (_loc2_.type == "item" && _loc2_.isNow() && (param1 == null || _loc2_.key == param1 || _loc2_.vaultKey == param1))
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function isPackageSale(param1:String = null):Boolean
		{
			for each (var _loc2_:* in saleList)
			{
				if (_loc2_.type == "pack" && _loc2_.isNow() && (param1 == null || _loc2_.key == param1 || _loc2_.vaultKey == param1))
				{
					return true;
				}
			}
			return false;
		}
		
		public function getPackageSale(param1:String):Sale
		{
			for each (var _loc2_:* in saleList)
			{
				if (_loc2_.type == "pack" && _loc2_.isNow() && (param1 == null || _loc2_.key == param1 || _loc2_.vaultKey == param1))
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function isSpecialSkinSale(param1:String = null):Boolean
		{
			for each (var _loc2_:* in saleList)
			{
				if (_loc2_.type == "sskin" && _loc2_.isNow() && (param1 == null || _loc2_.key == param1 || _loc2_.vaultKey == param1))
				{
					return true;
				}
			}
			return false;
		}
		
		public function getSpecialSkinSale(param1:String = null):Boolean
		{
			for each (var _loc2_:* in saleList)
			{
				if (_loc2_.type == "sskin" && _loc2_.isNow() && (param1 == null || _loc2_.key == param1 || _loc2_.vaultKey == param1))
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function isFluxSale():Boolean
		{
			for each (var _loc1_:* in saleList)
			{
				if (_loc1_.type == "flux" && _loc1_.isNow())
				{
					return true;
				}
			}
			return false;
		}
		
		public function getSkinSales():Vector.<Sale>
		{
			var _loc1_:Vector.<Sale> = new Vector.<Sale>();
			for each (var _loc2_:* in saleList)
			{
				if (_loc2_.type == "item" && _loc2_.isNow())
				{
					_loc1_.push(_loc2_);
				}
			}
			return _loc1_;
		}
		
		public function getSpecialSkinSales():Vector.<Sale>
		{
			var _loc1_:Vector.<Sale> = new Vector.<Sale>();
			for each (var _loc2_:* in saleList)
			{
				if (_loc2_.type == "sskin" && _loc2_.isNow())
				{
					_loc1_.push(_loc2_);
				}
			}
			return _loc1_;
		}
		
		public function getPackageSales():Vector.<Sale>
		{
			var _loc1_:Vector.<Sale> = new Vector.<Sale>();
			for each (var _loc2_:* in saleList)
			{
				if (_loc2_.type == "pack" && _loc2_.isNow())
				{
					_loc1_.push(_loc2_);
				}
			}
			return _loc1_;
		}
		
		public function isSale():Boolean
		{
			for each (var _loc1_:* in saleList)
			{
				if (_loc1_.isNow())
				{
					return true;
				}
			}
			return false;
		}
		
		public function getFluxSale():Sale
		{
			for each (var _loc1_:* in saleList)
			{
				if (_loc1_.type == "flux" && _loc1_.isNow())
				{
					return _loc1_;
				}
			}
			return null;
		}
	}
}
