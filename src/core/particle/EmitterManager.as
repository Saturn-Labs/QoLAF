package core.particle
{
	import core.GameObject;
	import core.scene.Game;
	import debug.Console;
	
	public class EmitterManager
	{
		public var emitters:Vector.<Emitter>;
		
		private var g:Game;
		
		private var inactiveEmitters:Vector.<Emitter>;
		
		public function EmitterManager(param1:Game)
		{
			var _loc2_:int = 0;
			super();
			this.g = param1;
			emitters = new Vector.<Emitter>();
			inactiveEmitters = new Vector.<Emitter>();
			Console.write(" -- init emitter pool");
			_loc2_ = 0;
			while (_loc2_ < 40)
			{
				inactiveEmitters.push(new Emitter(param1));
				_loc2_++;
			}
			Console.write(" -- emitter pool complete ");
		}
		
		public function update():void
		{
			var _loc3_:int = 0;
			var _loc1_:Emitter = null;
			var _loc2_:int = int(emitters.length);
			_loc3_ = _loc2_ - 1;
			while (_loc3_ > -1)
			{
				_loc1_ = emitters[_loc3_];
				if (_loc1_.alive)
				{
					_loc1_.update();
				}
				else
				{
					removeEmitter(_loc1_, _loc3_);
				}
				_loc3_--;
			}
			CollectiveMeshBatch.AllMeshesAreUpdated();
		}
		
		public function getEmitter():Emitter
		{
			var _loc1_:Emitter = null;
			if (inactiveEmitters.length > 0)
			{
				_loc1_ = inactiveEmitters.pop();
			}
			else
			{
				_loc1_ = new Emitter(g);
			}
			_loc1_.dispose();
			emitters.push(_loc1_);
			_loc1_.alive = true;
			return _loc1_;
		}
		
		public function forceUpdate(param1:GameObject = null):void
		{
			var _loc3_:int = 0;
			var _loc2_:Emitter = null;
			_loc3_ = emitters.length - 1;
			while (_loc3_ > -1)
			{
				_loc2_ = emitters[_loc3_];
				if (_loc2_.target == param1 || param1 == null)
				{
					_loc2_.nextDistanceCalculation = 0;
				}
				_loc3_--;
			}
		}
		
		public function clean(param1:GameObject):void
		{
			var _loc4_:int = 0;
			var _loc2_:Emitter = null;
			var _loc3_:int = int(emitters.length);
			_loc4_ = _loc3_ - 1;
			while (_loc4_ > -1)
			{
				_loc2_ = emitters[_loc4_];
				if (_loc2_.target == param1)
				{
					removeEmitter(_loc2_, _loc4_);
				}
				_loc4_--;
			}
		}
		
		public function removeEmitter(param1:Emitter, param2:int):void
		{
			param1.killEmitter();
			emitters.splice(param2, 1);
			inactiveEmitters.push(param1);
			param1.dispose();
		}
		
		public function dispose():void
		{
			for each (var _loc1_:* in emitters)
			{
				_loc1_.dispose();
			}
			emitters = null;
			inactiveEmitters = null;
			CollectiveMeshBatch.dispose();
		}
	}
}
