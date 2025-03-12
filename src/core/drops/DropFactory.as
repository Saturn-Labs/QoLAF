package core.drops
{
	import core.particle.*;
	import core.scene.Game;
	import data.*;
	import sound.ISound;
	import sound.SoundLocator;
	import textures.*;
	
	public class DropFactory
	{
		public function DropFactory()
		{
			super();
		}
		
		public static function createDrop(param1:String, param2:Game):Drop
		{
			var _loc4_:IDataManager = DataLocator.getService();
			var _loc3_:Object = _loc4_.loadKey("Drops", param1);
			return setDropProps(param2, _loc3_, param1);
		}
		
		public static function createDropFromCargo(param1:String, param2:Game):Drop
		{
			var _loc4_:Object = null;
			var _loc6_:IDataManager = DataLocator.getService();
			var _loc3_:Object = _loc6_.loadRange("Drops", "name", param1);
			for (var _loc5_:* in _loc3_)
			{
				_loc4_ = _loc3_[_loc5_];
				if (_loc4_.name == param1)
				{
					return setDropProps(param2, _loc4_, _loc5_.toString());
				}
			}
			return null;
		}
		
		public static function setDropProps(param1:Game, param2:Object, param3:String):Drop
		{
			var _loc4_:Drop = param1.dropManager.getDrop();
			_loc4_.obj = param2;
			_loc4_.name = param2.name;
			_loc4_.key = param3;
			_loc4_.collisionRadius = param2.collisionRadius;
			_loc4_.switchTexturesByObj(param2);
			var _loc5_:ISound = SoundLocator.getService();
			_loc5_.preCacheSound("05TMoG1kxEiXVZJ_OPhD_A", null);
			return _loc4_;
		}
	}
}
