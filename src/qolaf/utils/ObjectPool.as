package qolaf.utils
{
	/**
	 * @author rydev
	 */
	public class ObjectPool
	{
		private var _factory:Function;
		private var _reset:Function;
		private var _inactive:Vector.<Object> = new Vector.<Object>();
		private var _active:Vector.<Object> = new Vector.<Object>();

		public function ObjectPool(factory:Function, reset:Function)
		{
			this._factory = factory;
			this._reset = reset;
		}

		public function isActive(obj:Object):Boolean
		{
			return _active.indexOf(obj) != -1;
		}

		public function isInactive(obj:Object):Boolean
		{
			return _inactive.indexOf(obj) != -1;
		}

		public function isFromThisPool(obj:Object):Boolean
		{
			return isInactive(obj) || isActive(obj);
		}

		public function getOne():Object
		{
			var obj:Object = null;
			if (_inactive.length >= 1)
			{
				obj = _inactive.pop();
			}
			else
			{
				if (_factory == null)
					throw new Error("Can't create a instance a object from the pool because the 'factory' is invalid!");
				obj = _factory();
			}
			_active.push(obj);
			return obj;
		}

		public function getMany(count:int):Vector.<Object>
		{
			var objs:Vector.<Object> = new Vector.<Object>();
			for (var i:int = 0; i < count; i++)
				objs.push(getOne());
			return objs;
		}

		public function recycleOne(obj:Object):void
		{
			if (!isActive(obj))
				return;
			var index:int = _active.indexOf(obj);
			_active.splice(index, 1);
			_inactive.push(obj);
			if (_reset != null)
				_reset(obj);
		}

		public function recycleMany(objs:Vector.<Object>):void
		{
			for each (var obj:Object in objs)
				recycleOne(obj);
		}
	}
}