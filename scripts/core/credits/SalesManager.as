package core.credits {
	import core.scene.Game;
	import playerio.Message;
	
	public class SalesManager {
		public static const TYPE_FLUX:String = "flux";
		
		public static const TYPE_ITEM:String = "item";
		
		public static const TYPE_SPECIAL_SKIN:String = "sskin";
		
		public static const TYPE_PACKAGE:String = "pack";
		
		public static var eventList:Vector.<SaleEvent> = null;
		
		public var saleList:Vector.<Sale> = new Vector.<Sale>();
		
		private var g:Game;
		
		public function SalesManager(g:Game) {
			super();
			this.g = g;
		}
		
		public static function isSalePeriod() : Boolean {
			var _local2:SaleEvent = null;
			if(eventList == null) {
				eventList = new Vector.<SaleEvent>();
				_local2 = new SaleEvent(2016,10,28,7,96);
				eventList.push(_local2);
			}
			for each(var _local1 in eventList) {
				if(_local1.isNow()) {
					return true;
				}
			}
			return false;
		}
		
		public function refresh() : void {
			g.rpc("refreshSales",listArrived);
		}
		
		private function listArrived(m:Message) : void {
			var _local3:int = 0;
			var _local2:Sale = null;
			_local3 = 0;
			while(_local3 < m.length) {
				_local2 = new Sale(g);
				_local2.type = m.getString(_local3++);
				_local2.startTime = m.getNumber(_local3++);
				_local2.endTime = m.getNumber(_local3++);
				_local2.key = m.getString(_local3++);
				_local2.vaultKey = m.getString(_local3++);
				_local2.saleBonus = m.getInt(_local3++);
				_local2.normalPrice = m.getInt(_local3++);
				_local2.salePrice = m.getInt(_local3++);
				_local2.description = m.getString(_local3);
				saleList.push(_local2);
				_local3++;
			}
		}
		
		public function isSkinSale(key:String = null) : Boolean {
			for each(var _local2 in saleList) {
				if(_local2.type == "item" && _local2.isNow() && (key == null || _local2.key == key || _local2.vaultKey == key)) {
					return true;
				}
			}
			return false;
		}
		
		public function getSkinSale(key:String) : Sale {
			for each(var _local2 in saleList) {
				if(_local2.type == "item" && _local2.isNow() && (key == null || _local2.key == key || _local2.vaultKey == key)) {
					return _local2;
				}
			}
			return null;
		}
		
		public function isPackageSale(key:String = null) : Boolean {
			for each(var _local2 in saleList) {
				if(_local2.type == "pack" && _local2.isNow() && (key == null || _local2.key == key || _local2.vaultKey == key)) {
					return true;
				}
			}
			return false;
		}
		
		public function getPackageSale(key:String) : Sale {
			for each(var _local2 in saleList) {
				if(_local2.type == "pack" && _local2.isNow() && (key == null || _local2.key == key || _local2.vaultKey == key)) {
					return _local2;
				}
			}
			return null;
		}
		
		public function isSpecialSkinSale(key:String = null) : Boolean {
			for each(var _local2 in saleList) {
				if(_local2.type == "sskin" && _local2.isNow() && (key == null || _local2.key == key || _local2.vaultKey == key)) {
					return true;
				}
			}
			return false;
		}
		
		public function getSpecialSkinSale(key:String = null) : Boolean {
			for each(var _local2 in saleList) {
				if(_local2.type == "sskin" && _local2.isNow() && (key == null || _local2.key == key || _local2.vaultKey == key)) {
					return _local2;
				}
			}
			return null;
		}
		
		public function isFluxSale() : Boolean {
			for each(var _local1 in saleList) {
				if(_local1.type == "flux" && _local1.isNow()) {
					return true;
				}
			}
			return false;
		}
		
		public function getSkinSales() : Vector.<Sale> {
			var _local2:Vector.<Sale> = new Vector.<Sale>();
			for each(var _local1 in saleList) {
				if(_local1.type == "item" && _local1.isNow()) {
					_local2.push(_local1);
				}
			}
			return _local2;
		}
		
		public function getSpecialSkinSales() : Vector.<Sale> {
			var _local2:Vector.<Sale> = new Vector.<Sale>();
			for each(var _local1 in saleList) {
				if(_local1.type == "sskin" && _local1.isNow()) {
					_local2.push(_local1);
				}
			}
			return _local2;
		}
		
		public function getPackageSales() : Vector.<Sale> {
			var _local2:Vector.<Sale> = new Vector.<Sale>();
			for each(var _local1 in saleList) {
				if(_local1.type == "pack" && _local1.isNow()) {
					_local2.push(_local1);
				}
			}
			return _local2;
		}
		
		public function isSale() : Boolean {
			for each(var _local1 in saleList) {
				if(_local1.isNow()) {
					return true;
				}
			}
			return false;
		}
		
		public function getFluxSale() : Sale {
			for each(var _local1 in saleList) {
				if(_local1.type == "flux" && _local1.isNow()) {
					return _local1;
				}
			}
			return null;
		}
	}
}

