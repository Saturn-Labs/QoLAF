package core.drops {
	import core.particle.*;
	import core.scene.Game;
	import data.*;
	import sound.ISound;
	import sound.SoundLocator;
	import textures.*;
	
	public class DropFactory {
		public function DropFactory() {
			super();
		}
		
		public static function createDrop(key:String, g:Game) : Drop {
			var _local4:IDataManager = DataLocator.getService();
			var _local3:Object = _local4.loadKey("Drops",key);
			return setDropProps(g,_local3,key);
		}
		
		public static function createDropFromCargo(name:String, g:Game) : Drop {
			var _local4:Object = null;
			var _local5:IDataManager = DataLocator.getService();
			var _local3:Object = _local5.loadRange("Drops","name",name);
			for(var _local6 in _local3) {
				_local4 = _local3[_local6];
				if(_local4.name == name) {
					return setDropProps(g,_local4,_local6.toString());
				}
			}
			return null;
		}
		
		public static function setDropProps(g:Game, obj:Object, key:String) : Drop {
			var _local4:Drop = g.dropManager.getDrop();
			_local4.obj = obj;
			_local4.name = obj.name;
			_local4.key = key;
			_local4.collisionRadius = obj.collisionRadius;
			_local4.switchTexturesByObj(obj);
			var _local5:ISound = SoundLocator.getService();
			_local5.preCacheSound("05TMoG1kxEiXVZJ_OPhD_A",null);
			return _local4;
		}
	}
}

