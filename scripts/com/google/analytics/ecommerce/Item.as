package com.google.analytics.ecommerce {
	import com.google.analytics.utils.Variables;
	
	public class Item {
		private var _id:String;
		
		private var _sku:String;
		
		private var _name:String;
		
		private var _category:String;
		
		private var _price:String;
		
		private var _quantity:String;
		
		public function Item(id:String, sku:String, name:String, category:String, price:String, quantity:String) {
			super();
			this._id = id;
			this._sku = sku;
			this._name = name;
			this._category = category;
			this._price = price;
			this._quantity = quantity;
		}
		
		public function toGifParams() : Variables {
			var _local1:Variables = new Variables();
			_local1.URIencode = true;
			_local1.post = ["utmt","utmtid","utmipc","utmipn","utmiva","utmipr","utmiqt"];
			_local1.utmt = "item";
			_local1.utmtid = this._id;
			_local1.utmipc = this._sku;
			_local1.utmipn = this._name;
			_local1.utmiva = this._category;
			_local1.utmipr = this._price;
			_local1.utmiqt = this._quantity;
			return _local1;
		}
		
		public function get id() : String {
			return this._id;
		}
		
		public function get sku() : String {
			return this._sku;
		}
		
		public function get name() : String {
			return this._name;
		}
		
		public function get category() : String {
			return this._category;
		}
		
		public function get price() : String {
			return this._price;
		}
		
		public function get quantity() : String {
			return this._quantity;
		}
		
		public function set id(value:String) : void {
			this._id = value;
		}
		
		public function set sku(value:String) : void {
			this._sku = value;
		}
		
		public function set name(value:String) : void {
			this._name = value;
		}
		
		public function set category(value:String) : void {
			this._category = value;
		}
		
		public function set price(value:String) : void {
			this._price = value;
		}
		
		public function set quantity(value:String) : void {
			this._quantity = value;
		}
	}
}

