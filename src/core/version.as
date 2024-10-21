package core
{
	
	public class version
	{
		private var _value:Number = 0;
		
		public function version(param1:uint = 0, param2:uint = 0, param3:uint = 0, param4:uint = 0)
		{
			super();
			this._value = param1 << 28 | param2 << 24 | param3 << 16 | param4;
		}
		
		public function get build():uint
		{
			return (this._value & 0xFF0000) >>> 16;
		}
		
		public function set build(param1:uint):void
		{
			this._value = this._value & 4278255615 | param1 << 16;
		}
		
		public function get major():uint
		{
			return this._value >>> 28;
		}
		
		public function set major(param1:uint):void
		{
			this._value = this._value & 0x0FFFFFFF | param1 << 28;
		}
		
		public function get minor():uint
		{
			return (this._value & 0x0F000000) >>> 24;
		}
		
		public function set minor(param1:uint):void
		{
			this._value = this._value & 4043309055 | param1 << 24;
		}
		
		public function get revision():uint
		{
			return this._value & 0xFFFF;
		}
		
		public function set revision(param1:uint):void
		{
			this._value = this._value & 4294901760 | param1;
		}
		
		public function toString(param1:int = 0, param2:String = "."):String
		{
			var _loc4_:int = 0;
			var _loc5_:int = 0;
			var _loc3_:Array = [this.major, this.minor, this.build, this.revision];
			if (param1 > 0 && param1 < 5)
			{
				_loc3_ = _loc3_.slice(0, param1);
			}
			else
			{
				_loc5_ = int(_loc3_.length);
				_loc4_ = _loc5_ - 1;
				while (_loc4_ > 0)
				{
					if (_loc3_[_loc4_] != 0)
					{
						break;
					}
					_loc3_.pop();
					_loc4_--;
				}
			}
			return _loc3_.join(param2);
		}
		
		public function valueOf():Number
		{
			return this._value;
		}
	}
}
