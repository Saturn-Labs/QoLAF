package core.states.exploreStates
{
	import core.GameObject;
	import core.controlZones.ControlZone;
	import core.controlZones.ControlZoneManager;
	import core.hud.components.Box;
	import core.hud.components.ButtonExpandableHud;
	import core.hud.components.HudTimer;
	import core.hud.components.Text;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.hud.components.explore.ExploreArea;
	import core.hud.components.explore.ExploreMap;
	import core.particle.Emitter;
	import core.player.Explore;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.states.DisplayState;
	import extensions.PixelHitArea;
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class ExploreState extends DisplayState
	{
		public static var COLOR:uint = 3225899;
		private static var planetExploreAreas:Dictionary = null;
		private var min:Number = 0;
		private var max:Number = 1;
		private var value:Number = 0;
		private var _exploring:Boolean = false;
		private var exploreEffect:Vector.<Emitter>;

		private var effectBackground:Bitmap;
		private var effectContainer:Bitmap;
		private var effectTarget:GameObject;
		private var hasDrawnBody:Boolean = false;
		private var exploreText:Text;
		private var closeButton:ButtonExpandableHud;
		private var timer:Timer;
		private var startTime:Number = 0;
		private var finishTime:Number = 0;
		private var areaTypes:Dictionary;
		private var areas:Vector.<ExploreArea>;

		private var planetGfx:Image;
		private var areaBox:Sprite;
		private var areasText:Text;
		private var exploreMap:ExploreMap;
		private var b:Body;
		private var hasCollectedReward:Boolean = false;
		private var bodyAreas:Array;
		private var exploredAreas:Array;
		private var zoneExpireTimer:HudTimer;
		private var updateInterval:int = 5;
		public function ExploreState(param1:Game, param2:Body)
		{
			timer = new Timer(1000, 1);
			areaTypes = new Dictionary();
			super(param1, ExploreState);
			this.b = param2;
			zoneExpireTimer = new HudTimer(param1, 10);
		}

		override public function enter():void
		{
			var defX:int;
			var planetName:TextBitmap;
			var subHeader:TextBitmap;
			var box:Box;
			var obj:Object;
			super.enter();
			defX = 60;
			planetName = new TextBitmap(defX + 80, 44, b.name, 26);
			addChild(planetName);
			subHeader = new TextBitmap(planetName.x, planetName.y + planetName.height, "Planet overview");
			subHeader.format.color = 6710886;
			addChild(subHeader);
			addClanControl();
			areaBox = new Sprite();
			box = new Box(610, 50, "normal", 0.95, 12);
			areaBox.addChild(box);
			areaBox.x = 80;
			areaBox.y = 480;
			bodyAreas = b.getExploreAreaTypes();
			if (bodyAreas.length == 0)
			{
				areasText.text = "No areas to explore.";
				areasText.color = 11119017;
				areasText.size = 14;
				return;
			}
			for each (obj in bodyAreas)
			{
				areaTypes[obj.key] = obj;
			}
			if (exploredAreas)
			{
				createMap();
			}
			else
			{
				g.me.getExploredAreas(b, function(param1:Array):void
					{
						if (container == null)
						{
							return;
						}
						exploredAreas = param1;
						createMap();
					});
			}
		}

		private function addClanControl():void
		{
			var _loc5_:TextBitmap = null;
			var _loc9_:ControlZone = g.controlZoneManager.getZoneByKey(b.key);
			if (!_loc9_ || !g.isSystemTypeHostile())
			{
				return;
			}
			var _loc4_:int = 700;
			var _loc2_:int = 44;
			var _loc3_:TextBitmap = new TextBitmap(_loc4_, _loc2_, "Controlled by clan:", 12);
			_loc3_.alignRight();
			addChild(_loc3_);
			_loc2_ += 15;
			var _loc6_:TextBitmap = new TextBitmap(_loc4_, _loc2_, _loc9_.clanName, 26);
			_loc6_.alignRight();
			_loc6_.format.color = 16711680;
			addChild(_loc6_);
			var _loc1_:ITextureManager = TextureLocator.getService();
			var _loc8_:Texture = _loc1_.getTextureGUIByTextureName(_loc9_.clanLogo);
			var _loc7_:Image = new Image(_loc8_);
			_loc7_.scaleX = _loc7_.scaleY = 0.25;
			_loc7_.color = _loc9_.clanColor;
			_loc7_.x = _loc4_ - _loc6_.width - _loc7_.width - 10;
			_loc7_.y = _loc2_ + _loc6_.height - _loc7_.height - 2;
			addChild(_loc7_);
			_loc2_ += 30;
			if (_loc9_.releaseTime > g.time)
			{
				zoneExpireTimer.start(g.time, _loc9_.releaseTime);
				zoneExpireTimer.x = _loc4_ - 90;
				zoneExpireTimer.y = _loc2_;
				addChild(zoneExpireTimer);
			}
			else
			{
				_loc5_ = new TextBitmap(_loc4_, _loc2_, "expired", 12);
				_loc5_.alignRight();
				addChild(_loc5_);
			}
		}

		private function createMap():void
		{
			exploreMap = new ExploreMap(g, bodyAreas, exploredAreas, b);
			exploreMap.x = 50;
			exploreMap.y = 110;
			addChild(exploreMap);
			addExploreAreas(exploreMap);
			addChild(areaBox);
			var _loc1_:Box = new Box(610, 45, "normal", 0.95, 12);
			_loc1_.x = 80;
			_loc1_.y = 45;
			addImg(_loc1_);
		}

		private function showSelectTeam(param1:Event):void
		{
			var _loc2_:ExploreArea = param1.target as ExploreArea;
			sm.changeState(new SelectTeamState(g, b, _loc2_));
		}

		private function addExploreAreas(param1:ExploreMap):void
		{
			var _loc20_:* = null;
			var _loc13_:Object = null;
			var _loc14_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc9_:int = 0;
			var _loc7_:Array = null;
			var _loc8_:int = 0;
			var _loc18_:String = null;
			var _loc11_:Explore = null;
			var _loc19_:int = 0;
			var _loc4_:Boolean = false;
			var _loc6_:Boolean = false;
			var _loc12_:Boolean = false;
			var _loc5_:String = null;
			var _loc17_:Number = NaN;
			var _loc15_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc3_:ExploreArea = null;
			areas = new Vector.<ExploreArea>();
			if (b.obj.exploreAreas != null)
			{
				for each (var _loc16_:* in b.obj.exploreAreas)
				{
					_loc20_ = _loc16_;
					_loc13_ = areaTypes[_loc20_];
					_loc14_ = Number(_loc13_.skillLevel);
					_loc2_ = Number(_loc13_.rewardLevel);
					_loc9_ = int(_loc13_.size);
					_loc7_ = _loc13_.types;
					_loc8_ = int(_loc13_.majorType);
					_loc18_ = _loc13_.name;
					_loc11_ = g.me.getExploreByKey(_loc20_);
					_loc19_ = 0;
					_loc4_ = false;
					_loc6_ = false;
					_loc12_ = false;
					_loc5_ = null;
					_loc17_ = 0;
					_loc15_ = 0;
					_loc10_ = 0;
					if (_loc11_)
					{
						_loc19_ = _loc11_.successfulEvents;
						_loc6_ = _loc11_.finished;
						_loc4_ = _loc11_.failed;
						_loc12_ = _loc11_.lootClaimed;
						_loc15_ = _loc11_.failTime;
						_loc10_ = _loc11_.finishTime;
						_loc17_ = _loc11_.startTime;
					}
					_loc3_ = new ExploreArea(g, param1, b, _loc20_, _loc5_, _loc14_, _loc2_, _loc9_, _loc8_, _loc7_, _loc18_, _loc19_, _loc4_, _loc6_, _loc12_, _loc15_, _loc10_, _loc17_);
					_loc3_.addEventListener("showSelectTeam", showSelectTeam);
					_loc3_.addEventListener("showRewardScreen", showRewardScreen);
					areas.push(_loc3_);
					areaBox.addChild(_loc3_);
					g.tutorial.showExploreAdvice(_loc3_);
					g.tutorial.showSpecialUnlocks(_loc3_);
				}
			}
		}

		public function showRewardScreen(param1:Event):void
		{
			var _loc2_:ExploreArea = param1.target as ExploreArea;
			sm.changeState(new ReportState(g, _loc2_));
		}

		private function addImg(param1:Box):void
		{
			var _loc2_:Number = NaN;
			if (b.texture != null)
			{
				_loc2_ = 50 / b.texture.width;
				planetGfx = new Image(b.texture);
				planetGfx.scaleX = _loc2_;
				planetGfx.scaleY = _loc2_;
				planetGfx.x = 80;
				planetGfx.y = 45;
				addChild(planetGfx);
				hasDrawnBody = true;
			}
		}

		override public function execute():void
		{
			if (updateInterval-- > 0)
			{
				return;
			}
			if (ControlZoneManager.claimData)
			{
				sm.changeState(new ControlZoneState(g, b));
			}
			updateInterval = 5;
			for each (var _loc1_:* in areas)
			{
				if (areaBox.contains(_loc1_))
				{
					_loc1_.visible = false;
				}
				if (ExploreMap.selectedArea != null && ExploreMap.selectedArea.key == _loc1_.areaKey)
				{
					_loc1_.visible = true;
				}
				_loc1_.update();
			}
			zoneExpireTimer.update();
			super.execute();
		}

		public function stopEffect():void
		{
			for each (var _loc1_:* in areas)
			{
				_loc1_.stopEffect();
			}
		}

		override public function get type():String
		{
			return "ExploreState";
		}

		override public function exit():void
		{
			removeChild(areaBox, true);
			PixelHitArea.dispose();
			ToolTip.disposeType("skill");
			super.exit();
		}
	}
}
