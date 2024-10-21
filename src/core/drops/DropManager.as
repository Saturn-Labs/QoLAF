package core.drops
{
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import debug.Console;
	import flash.utils.Dictionary;
	import generics.Random;
	import playerio.Message;
	
	public class DropManager
	{
		public static const PICKUPINTERVAL:Number = 250;
		
		public static const ATTEMPTS_TO_TIMEOUT:int = 80;
		
		public var dropsById:Dictionary;
		
		public var drops:Vector.<Drop>;
		
		private var createdDropIds:Dictionary;
		
		private var pickupQueue:Vector.<PickUpMsg>;
		
		private var nextPickUpTime:Number;
		
		private var g:Game;
		
		public function DropManager(param1:Game)
		{
			super();
			this.g = param1;
			nextPickUpTime = 0;
			drops = new Vector.<Drop>();
			dropsById = new Dictionary();
			createdDropIds = new Dictionary();
			pickupQueue = new Vector.<PickUpMsg>();
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("spawnDrops", onSpawn);
		}
		
		public function initDrops(param1:Message):void
		{
			spawn(param1);
		}
		
		public function update():void
		{
			var _loc3_:int = 0;
			var _loc1_:Drop = null;
			var _loc2_:int = int(drops.length);
			_loc3_ = _loc2_ - 1;
			while (_loc3_ > -1)
			{
				_loc1_ = drops[_loc3_];
				_loc1_.update();
				if (_loc1_.expired)
				{
					remove(_loc1_, _loc3_);
					g.emitterManager.clean(_loc1_);
				}
				_loc3_--;
			}
			if (nextPickUpTime > g.time)
			{
				return;
			}
			_loc2_ = int(pickupQueue.length);
			_loc3_ = _loc2_ - 1;
			while (_loc3_ > -1)
			{
				if (pickupQueue.length > _loc3_)
				{
					tryPickup(null, pickupQueue[_loc3_], pickupQueue[_loc3_].i);
				}
				_loc3_--;
			}
			nextPickUpTime = g.time + 250;
		}
		
		public function getDrop():Drop
		{
			return new Drop(g);
		}
		
		private function remove(param1:Drop, param2:int):void
		{
			drops.splice(param2, 1);
			g.hud.radar.remove(param1);
			createdDropIds[param1.id.toString()] = false;
			dropsById[param1.id.toString()] = null;
			param1.removeFromCanvas();
			param1.reset();
		}
		
		private function onSpawn(param1:Message):void
		{
			spawn(param1);
		}
		
		public function spawn(param1:Message, param2:int = 0, param3:int = 0):void
		{
			var _loc8_:* = 0;
			var _loc6_:String = null;
			var _loc4_:int = 0;
			var _loc7_:Boolean = false;
			var _loc5_:int = int(param3 != 0 ? param3 : param1.length - param2);
			_loc8_ = param2;
			while (_loc8_ < param2 + _loc5_)
			{
				_loc6_ = param1.getString(_loc8_);
				_loc4_ = param1.getInt(_loc8_ + 1);
				_loc7_ = param1.getBoolean(_loc8_ + 2);
				if (_loc6_ == null || _loc6_ == "")
				{
					g.showErrorDialog("Init drops didn't work correctly! message: " + param1.toString(), true);
					return;
				}
				if (_loc6_ == "empty")
				{
					return;
				}
				createdDropIds[_loc4_.toString()] = true;
				if (!_loc7_)
				{
					createSetDrop(DropFactory.createDrop(_loc6_, g), param1, _loc8_);
				}
				else
				{
					createSetDrop(DropFactory.createDropFromCargo(_loc6_, g), param1, _loc8_);
				}
				_loc8_ += 9;
			}
		}
		
		public function getDropItems(param1:String, param2:Game, param3:Number):DropBase
		{
			var _loc5_:Boolean = false;
			var _loc6_:int = 0;
			var _loc4_:int = 0;
			var _loc12_:int = 0;
			var _loc7_:DropItem = null;
			if (param1 == "" || param1 == null)
			{
				return null;
			}
			var _loc8_:Random = new Random(param3);
			var _loc11_:Object = DataLocator.getService().loadKey("Drops", param1);
			var _loc10_:DropBase = new DropBase();
			_loc10_.crate = _loc11_.crate;
			if (_loc10_.crate)
			{
				if (_loc8_.randomNumber() >= _loc11_.chance)
				{
					_loc10_.crate = false;
					return null;
				}
				_loc5_ = Boolean(_loc11_.artifactChance);
				_loc10_.containsArtifact = _loc5_ > _loc8_.randomNumber();
			}
			if (_loc11_.type == "mission")
			{
				_loc6_ = int(_loc11_.fluxMax);
				_loc4_ = int(_loc11_.fluxMin);
				_loc10_.flux = _loc4_;
				_loc12_ = 0;
				while (_loc12_ < _loc6_ - _loc4_)
				{
					if (_loc8_.randomNumber() <= 0.5)
					{
						break;
					}
					_loc10_.flux += 1;
					_loc12_++;
				}
				if (_loc10_.flux == _loc6_)
				{
					if (_loc8_.randomNumber() > 0.5)
					{
						_loc10_.flux = _loc4_;
					}
				}
				_loc10_.artifactAmount = _loc11_.artifactAmount;
				_loc10_.artifactLevel = _loc11_.artifactLevel;
			}
			else
			{
				_loc10_.flux = _loc11_.fluxMin + _loc8_.random(_loc11_.fluxMax - _loc11_.fluxMin + 1);
			}
			_loc10_.xp = _loc11_.xpMin + _loc8_.random(_loc11_.xpMax - _loc11_.xpMin + 1);
			if (_loc11_.reputation)
			{
				_loc10_.reputation = _loc11_.reputation;
			}
			else
			{
				_loc10_.reputation = 0;
			}
			for each (var _loc9_:* in _loc11_.dropItems)
			{
				_loc7_ = getDropItem(_loc9_, _loc8_);
				if (_loc7_ != null)
				{
					_loc10_.items.push(_loc7_);
				}
			}
			return _loc10_;
		}
		
		public function getDropItem(param1:Object, param2:Random):DropItem
		{
			var _loc6_:DropItem = null;
			var _loc3_:int = 0;
			var _loc5_:int = 0;
			var _loc8_:int = 0;
			var _loc4_:Object = null;
			var _loc7_:Object = null;
			if (param2.randomNumber() <= param1.chance)
			{
				_loc6_ = new DropItem();
				_loc3_ = 0;
				_loc5_ = 0;
				if (param1.min && param1.max)
				{
					_loc3_ = int(param1.min);
					_loc5_ = int(param1.max);
				}
				_loc8_ = _loc5_ - _loc3_;
				_loc6_.quantity = _loc3_ + param2.random(_loc8_);
				_loc6_.item = param1.item;
				_loc6_.table = param1.table;
				if (_loc6_.quantity == 0)
				{
					return null;
				}
				_loc4_ = DataLocator.getService().loadKey(_loc6_.table, _loc6_.item);
				_loc6_.name = _loc4_.name;
				_loc6_.hasTechTree = _loc4_.hasTechTree;
				if (_loc6_.table == "Weapons")
				{
					_loc6_.bitmapKey = _loc4_.techIcon;
				}
				else if (_loc6_.table == "Skins")
				{
					_loc7_ = DataLocator.getService().loadKey("Ships", _loc4_.ship);
					_loc6_.bitmapKey = _loc7_.bitmap;
				}
				else
				{
					_loc6_.bitmapKey = _loc4_.bitmap;
				}
				return _loc6_;
			}
			return null;
		}
		
		private function createSetDrop(param1:Drop, param2:Message, param3:int):void
		{
			var _loc4_:Drop = null;
			if (param1 == null)
			{
				return;
			}
			param1.id = param2.getInt(param3 + 1);
			param1.x = 0.01 * param2.getInt(param3 + 3);
			param1.y = 0.01 * param2.getInt(param3 + 4);
			param1.speed.x = 0.01 * param2.getInt(param3 + 5);
			param1.speed.y = 0.01 * param2.getInt(param3 + 6);
			param1.expireTime = param2.getNumber(param3 + 7);
			param1.quantity = param2.getInt(param3 + 8);
			if (dropsById[param1.id.toString()] != null)
			{
				_loc4_ = dropsById[param1.id.toString()];
				_loc4_.expire();
			}
			dropsById[param1.id.toString()] = param1;
			drops.push(param1);
		}
		
		public function tryBeamPickup(param1:Message, param2:int):void
		{
			var _loc5_:String = param1.getString(param2);
			var _loc4_:int = param1.getInt(param2 + 1);
			var _loc3_:Player = g.playerManager.playersById[_loc5_];
			var _loc6_:Drop = dropsById[_loc4_.toString()];
			if (_loc6_ != null && _loc3_ != null)
			{
				_loc6_.tractorBeamPlayer = _loc3_;
				_loc6_.expireTime = g.time + 2000;
			}
			pickupQueue.push(new PickUpMsg(param1, 3 * 80, param2));
		}
		
		public function tryPickup(param1:Message = null, param2:PickUpMsg = null, param3:int = 0):void
		{
			var _loc9_:int = 0;
			if (param1 == null)
			{
				param1 = param2.msg;
			}
			else if (param1.length < param3 + 2)
			{
				return;
			}
			var _loc8_:int = param1.getInt(param3 - 1);
			var _loc6_:String = param1.getString(param3);
			var _loc5_:String = param1.getInt(param3 + 1).toString();
			var _loc7_:Drop = dropsById[_loc5_];
			if (_loc7_ == null && createdDropIds[_loc5_] != null)
			{
				if (createdDropIds[_loc5_] == true)
				{
					for each (var _loc11_:* in pickupQueue)
					{
						if (_loc11_.msg == param1)
						{
							Console.write("Pickup already queued. dropId: " + _loc5_);
							return;
						}
					}
					Console.write("Pickup queued.");
					pickupQueue.push(new PickUpMsg(param1, 80, param3));
					return;
				}
				_loc9_ = int(pickupQueue.indexOf(param2));
				pickupQueue.splice(_loc9_, 1);
				return;
			}
			if (_loc7_ == null)
			{
				Console.write("FAILED Pickup. No drop with id : " + _loc5_);
				_loc9_ = int(pickupQueue.indexOf(param2));
				if (param2 != null && _loc9_ != -1)
				{
					param2.timeout--;
					if (param2.timeout < 1)
					{
						pickupQueue.splice(_loc9_, 1);
						Console.write("FAILED Pickup. Removed from queue due to timeout.");
					}
				}
				return;
			}
			var _loc4_:Player = g.playerManager.playersById[_loc6_];
			if (_loc4_ == null || _loc4_.ship == null)
			{
				return;
			}
			var _loc10_:Boolean = _loc7_.pickup(_loc4_, param1, param3 + 2);
			if (!_loc10_)
			{
				return;
			}
			delete dropsById[_loc5_];
			_loc9_ = int(pickupQueue.indexOf(param2));
			if (_loc9_ != -1)
			{
				pickupQueue.splice(_loc9_, 1);
			}
		}
		
		private function buyTractorBeam():void
		{
			g.send("buyTractorBeam");
		}
		
		public function dispose():void
		{
			for each (var _loc1_:* in drops)
			{
				_loc1_.removeFromCanvas();
				_loc1_.reset();
			}
			drops = null;
			createdDropIds = null;
			pickupQueue = null;
			dropsById = null;
		}
		
		public function forceUpdate():void
		{
			var _loc1_:Drop = null;
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < drops.length)
			{
				_loc1_ = drops[_loc2_];
				_loc1_.nextDistanceCalculation = -1;
				_loc2_++;
			}
		}
	}
}

import playerio.Message;

class PickUpMsg
{
	public var msg:Message;
	
	public var timeout:int;
	
	public var i:int;
	
	public function PickUpMsg(param1:Message, param2:int, param3:int = 0)
	{
		super();
		this.timeout = param2;
		this.i = param3;
		this.msg = param1;
	}
}
