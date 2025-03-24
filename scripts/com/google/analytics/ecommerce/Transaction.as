package com.google.analytics.ecommerce {
	import com.google.analytics.utils.Variables;
	
	public class Transaction {
		private var _items:Array;
		
		private var _id:String;
		
		private var _affiliation:String;
		
		private var _total:String;
		
		private var _tax:String;
		
		private var _shipping:String;
		
		private var _city:String;
		
		private var _state:String;
		
		private var _country:String;
		
		private var _vars:Variables;
		
		public function Transaction(id:String, affiliation:String, total:String, tax:String, shipping:String, city:String, state:String, country:String) {
			super();
			this._id = id;
			this._affiliation = affiliation;
			this._total = total;
			this._tax = tax;
			this._shipping = shipping;
			this._city = city;
			this._state = state;
			this._country = country;
			this._items = new Array();
		}
		
		public function toGifParams() : Variables {
			var _local1:Variables = new Variables();
			_local1.URIencode = true;
			_local1.utmt = "tran";
			_local1.utmtid = this.id;
			_local1.utmtst = this.affiliation;
			_local1.utmtto = this.total;
			_local1.utmttx = this.tax;
			_local1.utmtsp = this.shipping;
			_local1.utmtci = this.city;
			_local1.utmtrg = this.state;
			_local1.utmtco = this.country;
			_local1.post = ["utmtid","utmtst","utmtto","utmttx","utmtsp","utmtci","utmtrg","utmtco"];
			return _local1;
		}
		
		public function addItem(sku:String, name:String, category:String, price:String, quantity:String) : void {
			var _local6:Item = null;
			_local6 = this.getItem(sku);
			if(_local6 == null) {
				_local6 = new Item(this._id,sku,name,category,price,quantity);
				this._items.push(_local6);
			} else {
				_local6.name = name;
				_local6.category = category;
				_local6.price = price;
				_local6.quantity = quantity;
			}
		}
		
		public function getItem(sku:String) : Item {
			var _local2:Number = NaN;
			_local2 = 0;
			while(_local2 < this._items.length) {
				if(this._items[_local2].sku == sku) {
					return this._items[_local2];
				}
				_local2++;
			}
			return null;
		}
		
		public function getItemsLength() : Number {
			return this._items.length;
		}
		
		public function getItemFromArray(i:Number) : Item {
			return this._items[i];
		}
		
		public function get id() : String {
			return this._id;
		}
		
		public function get affiliation() : String {
			return this._affiliation;
		}
		
		public function get total() : String {
			return this._total;
		}
		
		public function get tax() : String {
			return this._tax;
		}
		
		public function get shipping() : String {
			return this._shipping;
		}
		
		public function get city() : String {
			return this._city;
		}
		
		public function get state() : String {
			return this._state;
		}
		
		public function get country() : String {
			return this._country;
		}
		
		public function set id(value:String) : void {
			this._id = value;
		}
		
		public function set affiliation(value:String) : void {
			this._affiliation = value;
		}
		
		public function set total(value:String) : void {
			this._total = value;
		}
		
		public function set tax(value:String) : void {
			this._tax = value;
		}
		
		public function set shipping(value:String) : void {
			this._shipping = value;
		}
		
		public function set city(value:String) : void {
			this._city = value;
		}
		
		public function set state(value:String) : void {
			this._state = value;
		}
		
		public function set country(value:String) : void {
			this._country = value;
		}
	}
}

