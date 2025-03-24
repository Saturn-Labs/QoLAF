package core.player {
	import core.hud.components.explore.ExploreArea;
	import core.scene.Game;
	import core.solarSystem.Area;
	import data.DataLocator;
	import data.IDataManager;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewMember {
		public static const RANKS:Vector.<String> = Vector.<String>(["Rookie","Private","Corporal","Sergeant","Sergeant major","2nd lieutenant","Lieutenant"]);
		
		public var key:String;
		
		public var name:String;
		
		private var _imageKey:String;
		
		public var texture:Texture;
		
		public var skills:Array;
		
		public var specials:Array;
		
		public var solarSystem:String;
		
		public var body:String;
		
		public var area:String;
		
		public var fullLocation:String;
		
		public var injuryStart:Number;
		
		public var injuryEnd:Number;
		
		public var trainingEnd:Number;
		
		public var trainingType:int;
		
		public var missions:int;
		
		public var successMissions:int;
		
		public var rank:int;
		
		public var seed:int;
		
		public var skillPoints:int;
		
		public var artifact:String;
		
		public var artifactEnd:Number;
		
		private var g:Game;
		
		public function CrewMember(g:Game) {
			super();
			this.g = g;
		}
		
		public static function getRank(i:int) : String {
			if(i < RANKS.length) {
				return RANKS[i];
			}
			return "";
		}
		
		public function set imageKey(imgkey:String) : void {
			_imageKey = imgkey;
			var _local3:IDataManager = DataLocator.getService();
			var _local4:Object = _local3.loadKey("Images",imgkey);
			if(_local4 == null || _local4.fileName == null) {
				g.client.errorLog.writeError("Error: Crew dont have an image key: " + imgkey + " on crew: " + key,"","",{});
				return;
			}
			var _local2:ITextureManager = TextureLocator.getService();
			texture = _local2.getTextureGUIByTextureName(_local4.fileName);
		}
		
		public function get imageKey() : String {
			return _imageKey;
		}
		
		public function hasSpecialAreaSkill(area:ExploreArea) : Boolean {
			for each(var _local2 in area.specialTypes) {
				if(specials[_local2] == null) {
					return false;
				}
				if(specials[_local2] == 0) {
					return false;
				}
			}
			return true;
		}
		
		public function hasUnlockedSpecialSkill(name:String) : Boolean {
			var _local2:int = Area.getSpecialIndex(name);
			if(specials[_local2] >= 1) {
				return true;
			}
			return false;
		}
		
		public function getTrainingTime() : Number {
			var _local1:int = (getTotalSkillValue() + skillPoints) / 3;
			var _local3:* = _local1 / 500 * (60) * (60) * 1000 * 6;
			var _local2:Number = 21600000;
			if(_local3 > _local2) {
				_local3 = _local2;
			}
			return _local3;
		}
		
		public function getTotalSkillValue() : int {
			return getSkillValueByName("Survival") + getSkillValueByName("Diplomacy") + getSkillValueByName("Combat");
		}
		
		public function availableForExplore(newArea:ExploreArea) : Boolean {
			if(area != null && area.length > 0) {
				return false;
			}
			if(isInjured) {
				return false;
			}
			if(isTraining) {
				return false;
			}
			if(isUpgrading) {
				return false;
			}
			return true;
		}
		
		public function getCompactFullLocation() : String {
			if(fullLocation == null) {
				return null;
			}
			var _local1:int = int(fullLocation.indexOf(","));
			if(_local1 > 0) {
				return fullLocation.substr(_local1 + 2,fullLocation.length);
			}
			return fullLocation;
		}
		
		public function getSkillValueByName(name:String) : int {
			if(name == "Survival") {
				return int(skills[0]);
			}
			if(name == "Diplomacy") {
				return int(skills[1]);
			}
			if(name == "Combat") {
				return int(skills[2]);
			}
			return 0;
		}
		
		public function getSkillIndexByName(name:String) : int {
			if(name == "Survival") {
				return 0;
			}
			if(name == "Diplomacy") {
				return 1;
			}
			if(name == "Combat") {
				return 2;
			}
			return 0;
		}
		
		public function isIdle() : Boolean {
			if(isInjured) {
				return false;
			}
			if(isDeployed) {
				return false;
			}
			if(isTraining) {
				return false;
			}
			if(isUpgrading) {
				return false;
			}
			return true;
		}
		
		public function isIdleOrInjured() : Boolean {
			if(isDeployed) {
				return false;
			}
			if(isTraining) {
				return false;
			}
			if(isUpgrading) {
				return false;
			}
			return true;
		}
		
		public function get isTraining() : Boolean {
			return trainingEnd != 0;
		}
		
		public function get isTrainingComplete() : Boolean {
			return g.time > trainingEnd;
		}
		
		public function get isUpgrading() : Boolean {
			return artifactEnd > g.time;
		}
		
		public function get isUpgradeComplete() : Boolean {
			return artifactEnd > 0 && artifactEnd < g.time;
		}
		
		public function get injuryTime() : Number {
			if(g.time > injuryStart && g.time < injuryEnd) {
				return injuryEnd - g.time;
			}
			return 0;
		}
		
		public function get isWaitingForPickup() : Boolean {
			if(area == null || area == "") {
				return false;
			}
			for each(var _local1 in g.me.explores) {
				if(_local1.areaKey == area) {
					if(_local1.finishTime < g.time) {
						return true;
					}
				}
			}
			return false;
		}
		
		public function get isDeployed() : Boolean {
			return area != null && area != "";
		}
		
		public function get isInjured() : Boolean {
			return injuryEnd != 0 && injuryEnd > g.time;
		}
		
		public function getToolTipText() : String {
			var _local2:int = 0;
			var _local1:String = "Survival:  <FONT COLOR=\'#ffffff\'>" + getSkillValueByName("Survival") + "</FONT>\n" + "Diplomacy:  <FONT COLOR=\'#ffffff\'>" + getSkillValueByName("Diplomacy") + "</FONT>\n" + "Combat:  <FONT COLOR=\'#ffffff\'>" + getSkillValueByName("Combat") + "</FONT>\n\n" + "Specials:\n";
			var _local3:int = 0;
			_local2 = 0;
			while(_local2 < specials.length) {
				if(specials[_local2] >= 1) {
					_local1 += Area.SPECIALTYPEHTML[_local2] + "\n";
					_local3++;
				}
				_local2++;
			}
			if(_local3 == 0) {
				_local1 += "<FONT COLOR=\'#ffffff\'>None</FONT>";
			}
			return _local1;
		}
		
		public function completeTraining(newPoints:int) : void {
			skillPoints = newPoints;
			trainingEnd = 0;
			trainingType = 0;
		}
	}
}

