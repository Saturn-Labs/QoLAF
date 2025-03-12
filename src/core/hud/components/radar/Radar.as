package core.hud.components.radar
{
	import core.GameObject;
	import core.boss.Boss;
	import core.drops.Drop;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.solarSystem.Body;
	import core.spawner.Spawner;
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Radar extends Sprite
	{
		public static const outerDetectionRadius:Number = 5000;
		public static const innerDetectionRadius:Number = 2500;
		private var unitsDetected:Number = 0;
		private var _scale:Number = 10;
		public var radius:Number = 60;
		private var textureManager:ITextureManager;
		
		private var g:Game;
		
		private var blips:Vector.<Blip>;
		
		private var loaded:Boolean = false;
		private var blipBatch:MeshBatch;
		
		private var firstHalf:Boolean = true;
		private var quadBatch:MeshBatch;
		
		private var updateCount:int = 0;
		public function Radar(param1:Game)
		{
			blips = new Vector.<Blip>();
			blipBatch = new MeshBatch();
			quadBatch = new MeshBatch();
			super();
			this.g = param1;
			textureManager = TextureLocator.getService();
			touchable = false;
		}
		
		public function load():void
		{
			var _loc6_:* = null;
			drawBackground();
			for each (var _loc2_:* in g.shipManager.enemies)
			{
				createBlip(_loc2_, _loc7_);
			}
			for each (var _loc7_:* in g.shipManager.players)
			{
				if (!_loc7_.player.isMe)
				{
					createBlip(_loc7_);
				}
			}
			for each (var _loc4_:* in g.spawnManager.spawners)
			{
				if (_loc4_.alive)
				{
					createBlip(_loc4_);
				}
			}
			for each (var _loc3_:* in g.bodyManager.bodies)
			{
				if (_loc3_.type == "planet" || _loc3_.type == "junk yard" || _loc3_.type == "warpGate" || _loc3_.type == "shop" || _loc3_.type == "pirate" || _loc3_.type == "research" || _loc3_.type == "comet" || _loc3_.type == "sun")
				{
					createBlip(_loc3_);
				}
			}
			for each (var _loc1_:* in g.dropManager.drops)
			{
				createBlip(_loc1_);
			}
			for each (var _loc5_:* in g.bossManager.bosses)
			{
				if (_loc5_.alive)
				{
					createBlip(_loc5_);
				}
			}
			drawCenter();
			addChild(quadBatch);
			loaded = true;
		}
		
		private function drawBackground():void
		{
			var _loc1_:Image = new Image(textureManager.getTextureGUIByTextureName("radar_bg"));
			addChild(_loc1_);
		}
		
		private function drawCenter():void
		{
			var _loc1_:Image = new Image(textureManager.getTextureGUIByTextureName("radar_player"));
			_loc1_.pivotX = _loc1_.pivotY = _loc1_.width / 2;
			_loc1_.x = 60;
			_loc1_.y = 60;
			addChild(_loc1_);
		}
		
		private function createBlip(param1:GameObject, param2:PlayerShip = null):void
		{
			var _loc3_:Blip = null;
			_loc3_ = new Blip(param1, param2, g);
			blips.push(_loc3_);
		}
		
		public function add(param1:GameObject):void
		{
			var _loc2_:PlayerShip = null;
			if (!loaded)
			{
				return;
			}
			if (param1 is PlayerShip)
			{
				_loc2_ = param1 as PlayerShip;
				if (_loc2_.player.isMe)
				{
					return;
				}
			}
			createBlip(param1);
		}
		
		public function remove(param1:GameObject):void
		{
			var _loc2_:Blip = null;
			var _loc3_:int = 0;
			if (!loaded || blips == null)
			{
				return;
			}
			while (_loc3_ < blips.length)
			{
				_loc2_ = blips[_loc3_];
				if (_loc2_.isGameObject(param1))
				{
					blips.splice(_loc3_, 1);
					removeChild(_loc2_);
					_loc2_.dispose();
					return;
				}
				_loc3_++;
			}
		}
		
		public function update():void
		{
			var _loc2_:Blip = null;
			var _loc3_:int = 0;
			if (g.me.ship == null || g.me.isLanded)
			{
				return;
			}
			updateCount++;
			if (updateCount < 4)
			{
				return;
			}
			updateCount = 0;
			quadBatch.clear();
			var _loc1_:int = int(blips.length);
			_loc3_ = 0;
			while (_loc3_ < _loc1_)
			{
				_loc2_ = blips[_loc3_];
				if (_loc2_.go.distanceToCamera <= 5000)
				{
					if (_loc2_.updateVisibility())
					{
						quadBatch.addMesh(_loc2_);
					}
				}
				_loc3_++;
			}
		}
		
		public function inHostileZone():Boolean
		{
			if (unitsDetected > 0)
			{
				return true;
			}
			return false;
		}
		
		override public function dispose():void
		{
			for each (var _loc1_:* in blips)
			{
				_loc1_.dispose();
			}
			blips = null;
		}
	}
}

import core.GameObject;
import core.boss.Boss;
import core.drops.Drop;
import core.hud.components.Style;
import core.player.Player;
import core.scene.Game;
import core.ship.EnemyShip;
import core.ship.PlayerShip;
import core.solarSystem.Body;
import core.spawner.Spawner;
import starling.display.Image;
import starling.textures.Texture;
import textures.ITextureManager;
import textures.TextureLocator;

class Blip extends Image
{
	private static const scale:Number = 10;
	public static var radarRadius:Number = 60;
	public var go:GameObject;
	
	private var blipWidth:Number;
	
	private var blipHeight:Number;
	
	private var radius:Number;
	
	private var g:Game;
	
	public function Blip(param1:GameObject, param2:PlayerShip, param3:Game)
	{
		var _loc9_:Texture = null;
		var _loc4_:* = 0;
		var _loc8_:EnemyShip = null;
		var _loc7_:Spawner = null;
		var _loc6_:Body = null;
		this.go = param1;
		this.g = param3;
		touchable = false;
		var _loc5_:ITextureManager = TextureLocator.getService();
		if (param1 is EnemyShip)
		{
			_loc8_ = param1 as EnemyShip;
			if (_loc8_.hasFaction("AF"))
			{
				_loc4_ = Style.COLOR_FRIENDLY;
				_loc9_ = _loc5_.getTextureGUIByTextureName("radar_player");
			}
			else
			{
				_loc4_ = 16729156;
				_loc9_ = _loc5_.getTextureGUIByTextureName("radar_enemy");
			}
		}
		else if (param1 is PlayerShip)
		{
			_loc4_ = Style.COLOR_FRIENDLY;
			_loc9_ = _loc5_.getTextureGUIByTextureName("radar_player");
		}
		else if (param1 is Spawner)
		{
			_loc7_ = param1 as Spawner;
			if (_loc7_.hasFaction("AF"))
			{
				_loc4_ = Style.COLOR_FRIENDLY;
				_loc9_ = _loc5_.getTextureGUIByTextureName("radar_comet");
			}
			else
			{
				_loc4_ = 16729156;
				_loc9_ = _loc5_.getTextureGUIByTextureName("radar_spawner");
			}
		}
		else if (param1 is Body)
		{
			_loc6_ = param1 as Body;
			if (_loc6_.type == "planet")
			{
				_loc4_ = 2263074;
				_loc9_ = _loc5_.getTextureGUIByTextureName("radar_planet");
			}
			else if (_loc6_.type == "junk yard" || _loc6_.type == "warpGate" || _loc6_.type == "shop" || _loc6_.type == "pirate" || _loc6_.type == "research")
			{
				_loc4_ = 11184810;
				_loc9_ = _loc5_.getTextureGUIByTextureName("radar_station");
			}
			else if (_loc6_.type == "comet")
			{
				_loc4_ = 11184895;
				_loc9_ = _loc5_.getTextureGUIByTextureName("radar_comet");
			}
			else if (_loc6_.type == "sun")
			{
				_loc4_ = 16768392;
				_loc9_ = _loc5_.getTextureGUIByTextureName("radar_sun");
			}
		}
		else if (param1 is Drop)
		{
			_loc9_ = _loc5_.getTextureGUIByTextureName("radar_drop");
			_loc4_ = 15658734;
		}
		else if (param1 is Boss)
		{
			_loc9_ = _loc5_.getTextureGUIByTextureName("radar_boss");
			_loc4_ = 16729156;
		}
		super(_loc9_);
		color = _loc4_;
		blipWidth = width;
		blipHeight = height;
		radius = Math.sqrt(0.25 * blipWidth * blipWidth + 0.25 * blipHeight * blipHeight) - 1;
	}
	
	public function isGameObject(param1:GameObject):Boolean
	{
		if (this.go == param1)
		{
			return true;
		}
		return false;
	}
	
	public function getGameObject():GameObject
	{
		return go;
	}
	
	public function updateVisibility():Boolean
	{
		var _loc3_:Spawner = null;
		var _loc2_:Boss = null;
		var _loc6_:PlayerShip = null;
		var _loc1_:Player = null;
		var _loc5_:EnemyShip = null;
		var _loc4_:Boolean = Boolean(setRadarPos());
		if (_loc4_)
		{
			visible = true;
			alpha = getRadarAlphaIndex();
			if (go is Spawner)
			{
				_loc3_ = go as Spawner;
				if (!_loc3_.alive)
				{
					visible = false;
				}
			}
			else if (go is Boss)
			{
				_loc2_ = go as Boss;
				if (!_loc2_.alive)
				{
					visible = false;
				}
			}
			else if (go is PlayerShip)
			{
				_loc6_ = go as PlayerShip;
				_loc1_ = _loc6_.player;
				if (_loc6_.player == g.me)
				{
					color = Style.COLOR_LIGHT_GREEN;
				}
				else if (g.isSystemTypeDeathMatch())
				{
					color = Style.COLOR_HOSTILE;
				}
				else if (g.isSystemTypeDomination())
				{
					color = _loc1_.team == g.me.team ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
				}
				else if (g.isSystemPvPEnabled())
				{
					color = _loc1_.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
				}
				else
				{
					color = _loc1_.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_FRIENDLY;
				}
			}
			else if (go is EnemyShip)
			{
				_loc5_ = go as EnemyShip;
				_loc6_ = _loc5_.owner;
				if (_loc6_ != null)
				{
					if (_loc6_ == g.me.ship)
					{
						color = Style.COLOR_LIGHT_GREEN;
					}
					else if (g.isSystemTypeDeathMatch())
					{
						color = Style.COLOR_HOSTILE;
					}
					else if (g.isSystemTypeDomination())
					{
						color = _loc6_.team == g.me.team ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
					}
					else if (g.isSystemPvPEnabled())
					{
						color = _loc6_.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
					}
					else
					{
						color = _loc6_.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_FRIENDLY;
					}
				}
			}
		}
		else
		{
			visible = false;
		}
		return visible;
	}
	
	private function setRadarPos(param1:Boolean = true):Boolean
	{
		var _loc4_:Number = Number(go.distanceToCamera);
		var _loc2_:Number = Number(go.distanceToCameraX);
		var _loc3_:Number = Number(go.distanceToCameraY);
		if (_loc4_ >= 5000)
		{
			return false;
		}
		if (_loc4_ < 2500 - radius * scale)
		{
			_loc2_ /= 2500;
			_loc3_ /= 2500;
			x = _loc2_ * radarRadius + radarRadius - blipWidth / 2;
			y = _loc3_ * radarRadius + radarRadius - blipHeight / 2;
			return true;
		}
		if (param1)
		{
			_loc2_ /= _loc4_;
			_loc3_ /= _loc4_;
			_loc2_ *= radarRadius * scale - radius * scale;
			_loc3_ *= radarRadius * scale - radius * scale;
			x = _loc2_ / scale + radarRadius - blipWidth / 2;
			y = _loc3_ / scale + radarRadius - blipHeight / 2;
			return true;
		}
		return false;
	}
	
	private function getRadarAlphaIndex():Number
	{
		var _loc3_:Number = 5000;
		var _loc2_:Number = 2500;
		var _loc1_:Number = Number(go.distanceToCamera);
		if (_loc1_ < _loc3_ && _loc1_ >= _loc2_)
		{
			return 1 - (_loc1_ - _loc2_) / (_loc3_ - _loc2_);
		}
		return 1;
	}
	
	override public function dispose():void
	{
		go = null;
		texture.dispose();
		super.dispose();
	}
}
