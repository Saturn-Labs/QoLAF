package com.google.analytics.core {
	import com.google.analytics.debug.DebugConfiguration;
	import com.google.analytics.ecommerce.Transaction;
	
	public class Ecommerce {
		private var _debug:DebugConfiguration;
		
		private var _trans:Array;
		
		public function Ecommerce(debug:DebugConfiguration) {
			super();
			this._debug = debug;
			this._trans = new Array();
		}
		
		public function addTransaction(id:String, affiliation:String, total:String, tax:String, shipping:String, city:String, state:String, country:String) : Transaction {
			var _local9:Transaction = null;
			_local9 = this.getTransaction(id);
			if(_local9 == null) {
				_local9 = new Transaction(id,affiliation,total,tax,shipping,city,state,country);
				this._trans.push(_local9);
			} else {
				_local9.affiliation = affiliation;
				_local9.total = total;
				_local9.tax = tax;
				_local9.shipping = shipping;
				_local9.city = city;
				_local9.state = state;
				_local9.country = country;
			}
			return _local9;
		}
		
		public function getTransaction(orderId:String) : Transaction {
			var _local2:Number = NaN;
			_local2 = 0;
			while(_local2 < this._trans.length) {
				if(this._trans[_local2].id == orderId) {
					return this._trans[_local2];
				}
				_local2++;
			}
			return null;
		}
		
		public function getTransFromArray(i:Number) : Transaction {
			return this._trans[i];
		}
		
		public function getTransLength() : Number {
			return this._trans.length;
		}
	}
}

