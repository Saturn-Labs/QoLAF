package core.hud.components.map {
	import core.boss.Boss;
	import core.deathLine.DeathLine;
	import core.hud.components.ButtonExpandableHud;
	import core.hud.components.TextBitmap;
	import core.hud.components.pvp.DominationManager;
	import core.hud.components.pvp.DominationZone;
	import core.player.Player;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.spawner.Spawner;
	import generics.Localize;
	import generics.Util;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Map extends Sprite {
		public static var SCALE:Number = 0.1;
		
		public static var WIDTH:Number = 698;
		
		public static var HEIGHT:Number = 538;
		
		public static var CORNER:Number = 10;
		
		public static var PADDING:Number = 31;
		
		public var clearedFraction:Number = 0;
		
		private var mapBgr:Image;
		
		private var mapContainer:Sprite = new Sprite();
		
		private var coords:TextBitmap = new TextBitmap();
		
		private var mapPlayers:Vector.<MapPlayer> = new Vector.<MapPlayer>();
		
		private var mapBodies:Vector.<MapBodyBase> = new Vector.<MapBodyBase>();
		
		private var mapSpawners:Vector.<MapSpawner> = new Vector.<MapSpawner>();
		
		private var mapBosses:Vector.<MapBoss> = new Vector.<MapBoss>();
		
		private var mapDeathLines:Vector.<MapDeathLine> = new Vector.<MapDeathLine>();
		
		private var mapLastKilled:MapKilled;
		
		private var pvpZones:Vector.<MapPvpZone> = new Vector.<MapPvpZone>();
		
		private var closeButton:ButtonExpandableHud;
		
		private var g:Game;
		
		public function Map(g:Game) {
			this.g = g;
			super();
		}
		
		public function load(scale:Number = 0.1, width:Number = 698, height:Number = 538, padding:Number = 31, corner:Number = 10, pvpMode:Boolean = false) : void {
			var textureManager:ITextureManager;
			var q:Quad;
			var maxRadius:Number;
			var areaCount:Number;
			var exploreCount:Number;
			var b:Body;
			var area:String;
			var name:TextBitmap;
			var explored:TextBitmap;
			var b2:Body;
			var mapSun:MapSun;
			var mapElite:MapEliteArea;
			var mapHidden:MapHidden;
			var mapStation:MapStation;
			var boss:Boss;
			var mapBoss:MapBoss;
			var line:DeathLine;
			var mapDeathLine:MapDeathLine;
			var mapPlanet:MapPlanet;
			var spawner:Spawner;
			var mapSpawner:MapSpawner;
			var isDomination:Boolean;
			var dm:DominationManager;
			var dz:DominationZone;
			var dzs:Sprite;
			var player:Player;
			var mapPlayer:MapPlayer;
			var mask:Quad;
			g.hud.hideMapHint();
			textureManager = TextureLocator.getService();
			if(pvpMode) {
				mapBgr = new Image(textureManager.getTextureGUIByTextureName("hud_radar_pvp.png"));
				q = new Quad(width,height,0);
				q.alpha = 0.8;
				addChild(q);
				mapBgr.y = -8;
			} else {
				mapBgr = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
			}
			addChild(mapBgr);
			addChild(mapContainer);
			maxRadius = 200;
			areaCount = 0;
			exploreCount = 0;
			SCALE = scale;
			WIDTH = width;
			HEIGHT = height;
			PADDING = padding;
			CORNER = corner;
			for each(b in g.bodyManager.bodies) {
				if(b.type != "comet") {
					if(b.course.orbitRadius * SCALE > maxRadius) {
						SCALE = maxRadius / b.course.orbitRadius;
					}
					if(b.type == "planet") {
						for each(area in b.obj.exploreAreas) {
							if(g.me.hasExploredArea(area)) {
								exploreCount++;
							}
							areaCount++;
						}
					}
				}
			}
			if(areaCount > 0) {
				clearedFraction = exploreCount / areaCount * 100;
			}
			name = new TextBitmap(PADDING + 10,PADDING + 10,g.solarSystem.name,16);
			name.format.color = 16689475;
			name.alpha = 0.8;
			name.batchable = true;
			if(!pvpMode) {
				addChild(name);
			}
			explored = new TextBitmap(name.x + name.width + 4,name.y + 2,Util.formatDecimal(clearedFraction,1) + Localize.t("% Explored"));
			explored.format.color = 0x686868;
			explored.batchable = true;
			if(!pvpMode) {
				addChild(explored);
			}
			for each(b2 in g.bodyManager.bodies) {
				if(b2.type == "sun") {
					mapSun = new MapSun(g,mapContainer,b2);
					mapBodies.push(mapSun);
				} else if(b2.type == "warning") {
					mapElite = new MapEliteArea(g,mapContainer,b2);
					mapBodies.push(mapElite);
				} else if(b2.type == "hidden") {
					mapHidden = new MapHidden(g,mapContainer,b2);
					mapBodies.push(mapHidden);
				}
			}
			for each(b2 in g.bodyManager.bodies) {
				if(b2.type != "comet") {
					if(b2.type == "paintShop" || b2.type == "warpGate" || b2.type == "research" || b2.type == "shop" || b2.type == "junk yard" || b2.type == "hangar" || b2.type == "cantina") {
						mapStation = new MapStation(g,mapContainer,b2);
						mapStation.selected = g.hud.compas.hasTarget(b2);
						mapBodies.push(mapStation);
					}
				}
			}
			for each(boss in g.bossManager.bosses) {
				if(!boss.awaitingActivation) {
					mapBoss = new MapBoss(mapContainer,boss);
					mapBosses.push(mapBoss);
				}
			}
			for each(line in g.deathLineManager.lines) {
				if(g.isSystemTypeDomination()) {
					mapDeathLine = new MapDeathLine(g,mapContainer,line,0x888888);
				} else {
					mapDeathLine = new MapDeathLine(g,mapContainer,line,0xff8888);
				}
				mapDeathLines.push(mapDeathLine);
			}
			for each(b2 in g.bodyManager.bodies) {
				if(b2.type == "planet") {
					mapPlanet = new MapPlanet(g,mapContainer,b2);
					mapPlanet.selected = g.hud.compas.hasTarget(b2);
					mapBodies.push(mapPlanet);
				}
			}
			for each(spawner in g.spawnManager.spawners) {
				mapSpawner = new MapSpawner(mapContainer,spawner);
				mapSpawners.push(mapSpawner);
			}
			isDomination = g.solarSystem.type == "pvp dom";
			if(g.pvpManager != null && isDomination) {
				dm = g.pvpManager as DominationManager;
				for each(dz in dm.zones) {
					dzs = new MapPvpZone(g,dz);
					dzs.x = dz.x * Map.SCALE;
					dzs.y = dz.y * Map.SCALE;
					pvpZones.push(dzs);
					mapContainer.addChild(dzs);
				}
			}
			for each(player in g.playerManager.players) {
				mapPlayer = new MapPlayer(mapContainer,player,g,isDomination);
				mapPlayers.push(mapPlayer);
			}
			mapLastKilled = new MapKilled(mapContainer,g);
			mask = new Quad(WIDTH,HEIGHT);
			mask.width = WIDTH;
			mask.height = HEIGHT;
			mapContainer.mask = mask;
			coords.format.color = 0x888888;
			coords.size = 14;
			coords.batchable = true;
			if(!pvpMode) {
				addChild(coords);
			}
			closeButton = new ButtonExpandableHud(function():void {
				dispatchEvent(new Event("close"));
			},Localize.t("close"));
			closeButton.x = 760 - 46 - closeButton.width;
			closeButton.y = 0;
			if(!pvpMode) {
				addChild(closeButton);
			}
		}
		
		public function playerJoined(p:Player) : void {
			var _local2:MapPlayer = new MapPlayer(mapContainer,p,g,g.solarSystem.type == "pvp dom");
			mapPlayers.push(_local2);
		}
		
		public function update() : void {
			var _local1:DisplayObject = null;
			for each(var _local2 in mapBodies) {
				_local2.update();
			}
			for each(var _local4 in pvpZones) {
				_local4.update();
			}
			for each(var _local6 in mapPlayers) {
				_local6.update();
				if(_local6.isMe) {
					_local1 = mapContainer.mask;
					_local1.x = -(WIDTH / 2) + _local6.x + PADDING / 2;
					_local1.y = -(HEIGHT / 2) + _local6.y + PADDING / 2;
					coords.text = Localize.t("Current position:") + " " + Math.round(_local6.x) + ", " + Math.round(_local6.y);
					coords.y = PADDING + HEIGHT - coords.height - 10;
					coords.x = PADDING + 10;
					mapContainer.x = WIDTH / 2 - _local6.x + PADDING / 2;
					mapContainer.y = HEIGHT / 2 - _local6.y + PADDING / 2;
				}
			}
			for each(var _local3 in mapSpawners) {
				_local3.update();
			}
			for each(var _local5 in mapBosses) {
				_local5.update();
			}
			mapLastKilled.update();
		}
		
		override public function dispose() : void {
			for each(var _local2 in mapDeathLines) {
				_local2.dispose();
			}
			for each(var _local1 in mapPlayers) {
				_local1.dispose();
			}
			mapDeathLines.length = 0;
			mapBosses.length = 0;
			mapBodies.length = 0;
			mapPlayers.length = 0;
			mapSpawners.length = 0;
		}
	}
}

