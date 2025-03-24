package core.states.exploreStates {
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
	
	public class ExploreState extends DisplayState {
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
		
		private var timer:Timer = new Timer(1000,1);
		
		private var startTime:Number = 0;
		
		private var finishTime:Number = 0;
		
		private var areaTypes:Dictionary = new Dictionary();
		
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
		
		public function ExploreState(g:Game, b:Body) {
			super(g,ExploreState);
			this.b = b;
			zoneExpireTimer = new HudTimer(g,10);
		}
		
		override public function enter() : void {
			var defX:int;
			var planetName:TextBitmap;
			var subHeader:TextBitmap;
			var box:Box;
			var obj:Object;
			super.enter();
			defX = 60;
			planetName = new TextBitmap(defX + 80,44,b.name,26);
			addChild(planetName);
			subHeader = new TextBitmap(planetName.x,planetName.y + planetName.height,"Planet overview");
			subHeader.format.color = 0x666666;
			addChild(subHeader);
			addClanControl();
			areaBox = new Sprite();
			box = new Box(610,50,"normal",0.95,12);
			areaBox.addChild(box);
			areaBox.x = 80;
			areaBox.y = 8 * 60;
			bodyAreas = b.getExploreAreaTypes();
			if(bodyAreas.length == 0) {
				areasText.text = "No areas to explore.";
				areasText.color = 0xa9a9a9;
				areasText.size = 14;
				return;
			}
			for each(obj in bodyAreas) {
				areaTypes[obj.key] = obj;
			}
			if(exploredAreas) {
				createMap();
			} else {
				g.me.getExploredAreas(b,function(param1:Array):void {
					if(container == null) {
						return;
					}
					exploredAreas = param1;
					createMap();
				});
			}
		}
		
		private function addClanControl() : void {
			var _local4:TextBitmap = null;
			var _local3:ControlZone = g.controlZoneManager.getZoneByKey(b.key);
			if(!_local3 || !g.isSystemTypeHostile()) {
				return;
			}
			var _local6:int = 700;
			var _local2:int = 44;
			var _local5:TextBitmap = new TextBitmap(_local6,_local2,"Controlled by clan:",12);
			_local5.alignRight();
			addChild(_local5);
			_local2 += 15;
			var _local9:TextBitmap = new TextBitmap(_local6,_local2,_local3.clanName,26);
			_local9.alignRight();
			_local9.format.color = 0xff0000;
			addChild(_local9);
			var _local7:ITextureManager = TextureLocator.getService();
			var _local1:Texture = _local7.getTextureGUIByTextureName(_local3.clanLogo);
			var _local8:Image = new Image(_local1);
			_local8.scaleX = _local8.scaleY = 0.25;
			_local8.color = _local3.clanColor;
			_local8.x = _local6 - _local9.width - _local8.width - 10;
			_local8.y = _local2 + _local9.height - _local8.height - 2;
			addChild(_local8);
			_local2 += 30;
			if(_local3.releaseTime > g.time) {
				zoneExpireTimer.start(g.time,_local3.releaseTime);
				zoneExpireTimer.x = _local6 - 90;
				zoneExpireTimer.y = _local2;
				addChild(zoneExpireTimer);
			} else {
				_local4 = new TextBitmap(_local6,_local2,"expired",12);
				_local4.alignRight();
				addChild(_local4);
			}
		}
		
		private function createMap() : void {
			exploreMap = new ExploreMap(g,bodyAreas,exploredAreas,b);
			exploreMap.x = 50;
			exploreMap.y = 110;
			addChild(exploreMap);
			addExploreAreas(exploreMap);
			addChild(areaBox);
			var _local1:Box = new Box(610,45,"normal",0.95,12);
			_local1.x = 80;
			_local1.y = 45;
			addImg(_local1);
		}
		
		private function showSelectTeam(e:Event) : void {
			var _local2:ExploreArea = e.target as ExploreArea;
			sm.changeState(new SelectTeamState(g,b,_local2));
		}
		
		private function addExploreAreas(expMap:ExploreMap) : void {
			var _local20:* = null;
			var _local2:Object = null;
			var _local4:Number = NaN;
			var _local7:Number = NaN;
			var _local14:int = 0;
			var _local5:Array = null;
			var _local10:int = 0;
			var _local17:String = null;
			var _local15:Explore = null;
			var _local18:int = 0;
			var _local9:Boolean = false;
			var _local8:Boolean = false;
			var _local11:Boolean = false;
			var _local16:String = null;
			var _local6:Number = NaN;
			var _local12:Number = NaN;
			var _local19:Number = NaN;
			var _local3:ExploreArea = null;
			areas = new Vector.<ExploreArea>();
			if(b.obj.exploreAreas != null) {
				for each(var _local13 in b.obj.exploreAreas) {
					_local20 = _local13;
					_local2 = areaTypes[_local20];
					_local4 = Number(_local2.skillLevel);
					_local7 = Number(_local2.rewardLevel);
					_local14 = int(_local2.size);
					_local5 = _local2.types;
					_local10 = int(_local2.majorType);
					_local17 = _local2.name;
					_local15 = g.me.getExploreByKey(_local20);
					_local18 = 0;
					_local9 = false;
					_local8 = false;
					_local11 = false;
					_local16 = null;
					_local6 = 0;
					_local12 = 0;
					_local19 = 0;
					if(_local15) {
						_local18 = _local15.successfulEvents;
						_local8 = _local15.finished;
						_local9 = _local15.failed;
						_local11 = _local15.lootClaimed;
						_local12 = _local15.failTime;
						_local19 = _local15.finishTime;
						_local6 = _local15.startTime;
					}
					_local3 = new ExploreArea(g,expMap,b,_local20,_local16,_local4,_local7,_local14,_local10,_local5,_local17,_local18,_local9,_local8,_local11,_local12,_local19,_local6);
					_local3.addEventListener("showSelectTeam",showSelectTeam);
					_local3.addEventListener("showRewardScreen",showRewardScreen);
					areas.push(_local3);
					areaBox.addChild(_local3);
					g.tutorial.showExploreAdvice(_local3);
					g.tutorial.showSpecialUnlocks(_local3);
				}
			}
		}
		
		public function showRewardScreen(e:Event) : void {
			var _local2:ExploreArea = e.target as ExploreArea;
			sm.changeState(new ReportState(g,_local2));
		}
		
		private function addImg(box:Box) : void {
			var _local2:Number = NaN;
			if(b.texture != null) {
				_local2 = 50 / b.texture.width;
				planetGfx = new Image(b.texture);
				planetGfx.scaleX = _local2;
				planetGfx.scaleY = _local2;
				planetGfx.x = 80;
				planetGfx.y = 45;
				addChild(planetGfx);
				hasDrawnBody = true;
			}
		}
		
		override public function execute() : void {
			if(updateInterval-- > 0) {
				return;
			}
			if(ControlZoneManager.claimData) {
				sm.changeState(new ControlZoneState(g,b));
			}
			updateInterval = 5;
			for each(var _local1 in areas) {
				if(areaBox.contains(_local1)) {
					_local1.visible = false;
				}
				if(ExploreMap.selectedArea != null && ExploreMap.selectedArea.key == _local1.areaKey) {
					_local1.visible = true;
				}
				_local1.update();
			}
			zoneExpireTimer.update();
			super.execute();
		}
		
		public function stopEffect() : void {
			for each(var _local1 in areas) {
				_local1.stopEffect();
			}
		}
		
		override public function get type() : String {
			return "ExploreState";
		}
		
		override public function exit() : void {
			removeChild(areaBox,true);
			PixelHitArea.dispose();
			ToolTip.disposeType("skill");
			super.exit();
		}
	}
}

