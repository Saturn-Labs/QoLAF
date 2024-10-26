package qolaf.pooling
{
	/**
	 * @author rydev
	 */
	public class ObjectPool
	{
		private var inactiveObjects:Vector.<Object> = new Vector.<Object>;
		private var activeObjects:Vector.<Object> = new Vector.<Object>;
		private var factoryFunction:Function;
		
		public function ObjectPool(factory:Function) {
			factoryFunction = factory;
		}
		
		public function getObject(): Object {
			var obj:Object = null;
			if (inactiveObjects.length <= 0)
			{
				obj = factoryFunction();
				activeObjects.push(obj);
				return obj;
			}
			else 
			{
				obj = inactiveObjects.removeAt(0);
				activeObjects.push(obj);
				return obj;
			}
		}
		
		public function recicleObject(object:Object): void 
		{
			for (var i:Number = activeObjects.length - 1; i >= 0; i--) {
				var obj:Object = activeObjects[i];
				if (obj == object) {
					inactiveObjects.push(activeObjects.removeAt(i));
					return;
				}
			}
		}
	}
}