package core.artifact {
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import playerio.DatabaseObject;
	
	public class ArtifactFactory {
		public function ArtifactFactory() {
			super();
		}
		
		public static function createArtifact(key:String, g:Game, p:Player, callback:Function) : void {
			var dataManager:IDataManager = DataLocator.getService();
			dataManager.loadKeyFromBigDB("Artifacts",key,function(param1:DatabaseObject):void {
				if(param1 == null) {
					callback(null);
					return;
				}
				var _local2:Artifact = new Artifact(param1);
				callback(_local2);
			});
		}
		
		public static function createArtifacts(keys:Array, g:Game, p:Player, callback:Function) : void {
			var dataManager:IDataManager = DataLocator.getService();
			dataManager.loadKeysFromBigDB("Artifacts",keys,function(param1:Array):void {
				var _local2:Artifact = null;
				try {
					for each(var _local3 in param1) {
						if(_local3 != null) {
							_local2 = new Artifact(_local3);
							p.artifacts.push(_local2);
						}
					}
				}
				catch(e:Error) {
					g.client.errorLog.writeError(e.toString(),"Something went wrong when loading artifacts, pid: " + p.id,e.getStackTrace(),{});
				}
				callback();
			});
		}
		
		public static function createArtifactFromSkin(skin:Object) : Artifact {
			var _local2:Artifact = new Artifact({});
			var _local3:Object = skin.specials;
			_local2.name = "skin artifact";
			_local2.stats.push(new ArtifactStat("corrosiveAdd",_local3["corrosiveAdd"]));
			_local2.stats.push(new ArtifactStat("corrosiveMulti",_local3["corrosiveMulti"]));
			_local2.stats.push(new ArtifactStat("energyAdd",_local3["energyAdd"]));
			_local2.stats.push(new ArtifactStat("energyMulti",_local3["energyMulti"]));
			_local2.stats.push(new ArtifactStat("kineticAdd",_local3["kineticAdd"]));
			_local2.stats.push(new ArtifactStat("kineticMulti",_local3["kineticMulti"]));
			_local2.stats.push(new ArtifactStat("speed",_local3["speed"] / 2));
			_local2.stats.push(new ArtifactStat("refire",_local3["refire"]));
			_local2.stats.push(new ArtifactStat("cooldown",_local3["cooldown"]));
			_local2.stats.push(new ArtifactStat("powerMax",_local3["powerMax"] / 1.5));
			_local2.stats.push(new ArtifactStat("powerReg",_local3["powerReg"] / 1.5));
			return _local2;
		}
	}
}

