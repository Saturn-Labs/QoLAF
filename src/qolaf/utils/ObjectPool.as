package qolaf.utils 
{
	/**
	 * @author rydev
	 */
	public class ObjectPool 
	{
		private var factory:Function;
		private var reset:Function;
		
		private var inactive:Vector.<Object>;
		private var active:Vector.<Object>;
		
		public function ObjectPool(factory:Function, reset:Function) {
			this.factory = factory;
			this.reset = reset;
		}
		
		public function isActive(obj:Object):Boolean {
			return active.indexOf(obj) != -1;
		}
		
		public function isInactive(obj:Object):Boolean {
			return inactive.indexOf(obj) != -1;
		}
		
		public function isFromThisPool(obj:Object):Boolean {
			return isInactive() || isActive();
		}
		
		public function getOne():Object {
			var obj:Object = null;
			if (inactive.length >= 1) {
				obj = inactive.pop();
			}
			else {
				if (factory == null)
					throw new Error("Can't create a instance a object from the pool because the 'factory' is invalid!");
				obj = factory();
			}
			active.push(obj);
			return obj;
		}
		
		public function getMany(count:int):Vector.<Object> {
			var objs:Vector.<Object> = new Vector.<Object>();
			for (var i:int = 0; i < count; i++)
				objs.push(getOne());
			return objs;
		}
		
		public function recycleOne(obj:Object):void {
			if (!isActive(obj))
				return;
			var index:int = active.indexOf(obj);
			active.splice(index, 1);
			inactive.push(obj);
			if (reset != null)
				reset(obj);
		}
		
		public function recycleMany(objs:Vector.<Object>):void {
			for each (var obj:Object in objs)
				recycleOne(obj);
		}
	}
}