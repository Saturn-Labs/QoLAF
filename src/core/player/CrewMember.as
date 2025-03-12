package core.player
{
	import core.hud.components.explore.ExploreArea;
	import core.scene.Game;
	import core.solarSystem.Area;
	import data.DataLocator;
	import data.IDataManager;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewMember
	{
		public static const RANKS:Vector.<String> = Vector.<String>(["Rookie", "Private", "Corporal", "Sergeant", "Sergeant major", "2nd lieutenant", "Lieutenant"]);
		
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
		
		public function CrewMember(param1:Game)
		{
			super();
			this.g = param1;
		}
		
		public static function getRank(param1:int):String
		{
			if (param1 < RANKS.length)
			{
				return RANKS[param1];
			}
			return "";
		}
		
		public function set imageKey(param1:String):void
		{
			_imageKey = param1;
			var _loc4_:IDataManager = DataLocator.getService();
			var _loc3_:Object = _loc4_.loadKey("Images", param1);
			if (_loc3_ == null || _loc3_.fileName == null)
			{
				g.client.errorLog.writeError("Error: Crew dont have an image key: " + param1 + " on crew: " + key, "", "", {});
				return;
			}
			var _loc2_:ITextureManager = TextureLocator.getService();
			texture = _loc2_.getTextureGUIByTextureName(_loc3_.fileName);
		}
		
		public function get imageKey():String
		{
			return _imageKey;
		}
		
		public function hasSpecialAreaSkill(param1:ExploreArea):Boolean
		{
			for each (var _loc2_:* in param1.specialTypes)
			{
				if (specials[_loc2_] == null)
				{
					return false;
				}
				if (specials[_loc2_] == 0)
				{
					return false;
				}
			}
			return true;
		}
		
		public function hasUnlockedSpecialSkill(param1:String):Boolean
		{
			var _loc2_:int = Area.getSpecialIndex(param1);
			if (specials[_loc2_] >= 1)
			{
				return true;
			}
			return false;
		}
		
		public function getTrainingTime():Number
		{
			var _loc1_:int = (getTotalSkillValue() + skillPoints) / 3;
			var _loc3_:* = _loc1_ / 500 * 60 * 60 * 1000 * 6;
			var _loc2_:Number = 21600000;
			if (_loc3_ > _loc2_)
			{
				_loc3_ = _loc2_;
			}
			return _loc3_;
		}
		
		public function getTotalSkillValue():int
		{
			return getSkillValueByName("Survival") + getSkillValueByName("Diplomacy") + getSkillValueByName("Combat");
		}
		
		public function availableForExplore(param1:ExploreArea):Boolean
		{
			if (area != null && area.length > 0)
			{
				return false;
			}
			if (isInjured)
			{
				return false;
			}
			if (isTraining)
			{
				return false;
			}
			if (isUpgrading)
			{
				return false;
			}
			return true;
		}
		
		public function getCompactFullLocation():String
		{
			if (fullLocation == null)
			{
				return null;
			}
			var _loc1_:int = int(fullLocation.indexOf(","));
			if (_loc1_ > 0)
			{
				return fullLocation.substr(_loc1_ + 2, fullLocation.length);
			}
			return fullLocation;
		}
		
		public function getSkillValueByName(param1:String):int
		{
			if (param1 == "Survival")
			{
				return int(skills[0]);
			}
			if (param1 == "Diplomacy")
			{
				return int(skills[1]);
			}
			if (param1 == "Combat")
			{
				return int(skills[2]);
			}
			return 0;
		}
		
		public function getSkillIndexByName(param1:String):int
		{
			if (param1 == "Survival")
			{
				return 0;
			}
			if (param1 == "Diplomacy")
			{
				return 1;
			}
			if (param1 == "Combat")
			{
				return 2;
			}
			return 0;
		}
		
		public function isIdle():Boolean
		{
			if (isInjured)
			{
				return false;
			}
			if (isDeployed)
			{
				return false;
			}
			if (isTraining)
			{
				return false;
			}
			if (isUpgrading)
			{
				return false;
			}
			return true;
		}
		
		public function isIdleOrInjured():Boolean
		{
			if (isDeployed)
			{
				return false;
			}
			if (isTraining)
			{
				return false;
			}
			if (isUpgrading)
			{
				return false;
			}
			return true;
		}
		
		public function get isTraining():Boolean
		{
			return trainingEnd != 0;
		}
		
		public function get isTrainingComplete():Boolean
		{
			return g.time > trainingEnd;
		}
		
		public function get isUpgrading():Boolean
		{
			return artifactEnd > g.time;
		}
		
		public function get isUpgradeComplete():Boolean
		{
			return artifactEnd > 0 && artifactEnd < g.time;
		}
		
		public function get injuryTime():Number
		{
			if (g.time > injuryStart && g.time < injuryEnd)
			{
				return injuryEnd - g.time;
			}
			return 0;
		}
		
		public function get isWaitingForPickup():Boolean
		{
			if (area == null || area == "")
			{
				return false;
			}
			for each (var _loc1_:* in g.me.explores)
			{
				if (_loc1_.areaKey == area)
				{
					if (_loc1_.finishTime < g.time)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		public function get isDeployed():Boolean
		{
			return area != null && area != "";
		}
		
		public function get isInjured():Boolean
		{
			return injuryEnd != 0 && injuryEnd > g.time;
		}
		
		public function getToolTipText():String
		{
			var _loc3_:int = 0;
			var _loc1_:String = "Survival:  <FONT COLOR='#ffffff'>" + getSkillValueByName("Survival") + "</FONT>\n" + "Diplomacy:  <FONT COLOR='#ffffff'>" + getSkillValueByName("Diplomacy") + "</FONT>\n" + "Combat:  <FONT COLOR='#ffffff'>" + getSkillValueByName("Combat") + "</FONT>\n\n" + "Specials:\n";
			var _loc2_:int = 0;
			_loc3_ = 0;
			while (_loc3_ < specials.length)
			{
				if (specials[_loc3_] >= 1)
				{
					_loc1_ += Area.SPECIALTYPEHTML[_loc3_] + "\n";
					_loc2_++;
				}
				_loc3_++;
			}
			if (_loc2_ == 0)
			{
				_loc1_ += "<FONT COLOR='#ffffff'>None</FONT>";
			}
			return _loc1_;
		}
		
		public function completeTraining(param1:int):void
		{
			skillPoints = param1;
			trainingEnd = 0;
			trainingType = 0;
		}
	}
}
