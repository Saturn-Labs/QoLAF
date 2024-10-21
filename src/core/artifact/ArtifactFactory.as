package core.artifact
{
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import playerio.DatabaseObject;
	
	public class ArtifactFactory
	{
		public function ArtifactFactory()
		{
			super();
		}
		
		public static function createArtifact(param1:String, param2:Game, param3:Player, param4:Function):void
		{
			var key:String = param1;
			var g:Game = param2;
			var p:Player = param3;
			var callback:Function = param4;
			var dataManager:IDataManager = DataLocator.getService();
			dataManager.loadKeyFromBigDB("Artifacts", key, function(param1:DatabaseObject):void
			{
				if (param1 == null)
				{
					callback(null);
					return;
				}
				var _loc2_:Artifact = new Artifact(param1);
				callback(_loc2_);
			});
		}
		
		public static function createArtifacts(param1:Array, param2:Game, param3:Player, param4:Function):void
		{
			var keys:Array = param1;
			var g:Game = param2;
			var p:Player = param3;
			var callback:Function = param4;
			var dataManager:IDataManager = DataLocator.getService();
			dataManager.loadKeysFromBigDB("Artifacts", keys, function(param1:Array):void
			{
				var _loc2_:Artifact = null;
				try
				{
					for each (var _loc3_:* in param1)
					{
						if (_loc3_ != null)
						{
							_loc2_ = new Artifact(_loc3_);
							p.artifacts.push(_loc2_);
						}
					}
				}
				catch (e:Error)
				{
					g.client.errorLog.writeError(e.toString(), "Something went wrong when loading artifacts, pid: " + p.id, e.getStackTrace(), {});
				}
				callback();
			});
		}
		
		public static function createArtifactFromSkin(param1:Object):Artifact
		{
			var _loc3_:Artifact = new Artifact({});
			var _loc2_:Object = param1.specials;
			_loc3_.name = "skin artifact";
			_loc3_.stats.push(new ArtifactStat("corrosiveAdd", _loc2_["corrosiveAdd"]));
			_loc3_.stats.push(new ArtifactStat("corrosiveMulti", _loc2_["corrosiveMulti"]));
			_loc3_.stats.push(new ArtifactStat("energyAdd", _loc2_["energyAdd"]));
			_loc3_.stats.push(new ArtifactStat("energyMulti", _loc2_["energyMulti"]));
			_loc3_.stats.push(new ArtifactStat("kineticAdd", _loc2_["kineticAdd"]));
			_loc3_.stats.push(new ArtifactStat("kineticMulti", _loc2_["kineticMulti"]));
			_loc3_.stats.push(new ArtifactStat("speed", _loc2_["speed"] / 2));
			_loc3_.stats.push(new ArtifactStat("refire", _loc2_["refire"]));
			_loc3_.stats.push(new ArtifactStat("cooldown", _loc2_["cooldown"]));
			_loc3_.stats.push(new ArtifactStat("powerMax", _loc2_["powerMax"] / 1.5));
			_loc3_.stats.push(new ArtifactStat("powerReg", _loc2_["powerReg"] / 1.5));
			return _loc3_;
		}
	}
}
