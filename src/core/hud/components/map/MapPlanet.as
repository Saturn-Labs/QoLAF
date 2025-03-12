package core.hud.components.map
{
	import core.controlZones.ControlZone;
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.Style;
	import core.hud.components.ToolTip;
	import core.player.CrewMember;
	import core.player.LandedBody;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.solarSystem.Body;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Util;
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class MapPlanet extends MapBodyBase
	{
		public function MapPlanet(param1:Game, param2:Sprite, param3:Body)
		{
			super(param1, param2, param3);
			param2.addChild(crew);
			param2.addChild(text);
			param2.addChild(percentage);
			layer.useHandCursor = true;
			addImage();
			addCrew();
			addTooltip();
			addOrbits();
			addText();
			init();
		}
		
		private function addImage():void
		{
			if (body.texture == null)
			{
				return;
			}
			var _loc2_:Number = Map.SCALE * 1.5;
			radius = body.texture.width / 2 * _loc2_;
			if (radius < 4)
			{
				_loc2_ = 4 / (body.texture.width / 2);
			}
			radius = body.texture.width / 2 * _loc2_;
			var _loc1_:Image = new Image(body.texture);
			_loc1_.scaleX = _loc2_;
			_loc1_.scaleY = _loc2_;
			layer.addChild(_loc1_);
			imgHover = new Image(body.texture);
			imgHover.scaleX = _loc2_;
			imgHover.scaleY = _loc2_;
			imgHover.blendMode = "add";
			imgSelected = imgHover;
		}
		
		private function addCrew():void
		{
			var _loc1_:Image = null;
			var _loc3_:int = 0;
			for each (var _loc2_:* in g.me.crewMembers)
			{
				if (_loc2_.body == body.key)
				{
					_loc1_ = new Image(_loc2_.texture);
					_loc1_.height *= 0.2;
					_loc1_.width *= 0.2;
					_loc1_.x = _loc3_ * (_loc1_.width + 4);
					crew.addChild(_loc1_);
					_loc3_++;
				}
			}
		}
		
		private function addTooltip():void
		{
			var _loc7_:int = 0;
			var _loc13_:IDataManager = null;
			var _loc3_:Object = null;
			var _loc12_:ControlZone = null;
			var _loc9_:Number = NaN;
			var _loc11_:Boolean = false;
			for each (var _loc10_:* in g.me.landedBodies)
			{
				if (_loc10_.key == body.key)
				{
					_loc11_ = true;
					break;
				}
			}
			var _loc2_:String = "";
			if (!_loc11_)
			{
				_loc2_ = "Name: " + body.name + "\nAreas: Unknown";
				new ToolTip(g, layer, _loc2_, null, "Map", 400);
				return;
			}
			var _loc1_:Array = [];
			var _loc5_:int = 0;
			var _loc6_:int = 0;
			_loc2_ += "Name: " + body.name + "\nAreas: ";
			for each (var _loc8_:* in body.obj.exploreAreas)
			{
				_loc13_ = DataLocator.getService();
				_loc3_ = _loc13_.loadKey("BodyAreas", _loc8_);
				if (_loc3_.skillLevel > 99)
				{
					_loc7_ = 34;
				}
				else
				{
					_loc7_ = 26;
				}
				_loc2_ += "\n<FONT COLOR='" + Area.COLORTYPESTR[_loc3_.majorType] + "'> " + _loc3_.skillLevel + "      </FONT>";
				_loc1_.push({"img": CrewDisplayBox.IMAGES_SKILLS[_loc3_.majorType], "x": _loc7_, "y": 38 + 19 * _loc5_});
				_loc6_ = 0;
				for each (var _loc4_:* in _loc3_.types)
				{
					_loc6_++;
					_loc2_ += "    ";
					_loc1_.push({"img": CrewDisplayBox.IMAGES_SPECIALS[_loc4_], "x": _loc7_ + _loc6_ * 18, "y": 38 + 19 * _loc5_});
				}
				if (g.me.hasExploredArea(_loc8_))
				{
					_loc2_ += "  Complete";
				}
				else
				{
					_loc2_ += "  Unexplored";
				}
				_loc5_++;
			}
			if (body.explorable && g.me.clanId != "" && g.isSystemTypeHostile())
			{
				_loc12_ = g.controlZoneManager.getZoneByKey(body.key);
				if (_loc12_)
				{
					_loc2_ += "\n\n";
					_loc2_ += "Controlled by\n";
					_loc2_ += _loc12_.clanName + "\n";
					if (_loc12_.releaseTime > g.time)
					{
						_loc9_ = _loc12_.releaseTime - g.time;
						_loc2_ += "<FONT COLOR=\"#ff0000\">locked for " + Util.getFormattedTime(_loc9_) + "</FONT>\n";
					}
				}
			}
			new ToolTip(g, layer, _loc2_, _loc1_, "Map", 400);
		}
		
		private function addText():void
		{
			var _loc4_:ControlZone = null;
			if (!body.landable)
			{
				return;
			}
			text.size = 11;
			text.format.color = Style.COLOR_MAP_PLANET;
			text.text = body.name;
			if (body.explorable && g.me.clanId != "" && g.isSystemTypeHostile())
			{
				_loc4_ = g.controlZoneManager.getZoneByKey(body.key);
				if (!_loc4_ || _loc4_.releaseTime < g.time)
				{
					text.format.color = Style.COLOR_LIGHT_GREEN;
				}
			}
			var _loc2_:int = 0;
			var _loc3_:int = 0;
			for each (var _loc1_:* in body.obj.exploreAreas)
			{
				if (g.me.hasExploredArea(_loc1_))
				{
					_loc3_++;
				}
				_loc2_++;
			}
			if (_loc2_ > 0)
			{
				percentage.size = 11;
				percentage.format.color = Style.COLOR_BYLINE;
				percentage.text = Math.floor(_loc3_ / _loc2_ * 100).toString() + "%";
			}
		}
	}
}
