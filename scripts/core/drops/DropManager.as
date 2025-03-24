package core.drops {
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import debug.Console;
	import flash.utils.Dictionary;
	import generics.Random;
	import playerio.Message;
	
	public class DropManager {
		public static const PICKUPINTERVAL:Number = 250;
		
		public static const ATTEMPTS_TO_TIMEOUT:int = 80;
		
		public var dropsById:Dictionary;
		
		public var drops:Vector.<Drop>;
		
		private var createdDropIds:Dictionary;
		
		private var pickupQueue:Vector.<PickUpMsg>;
		
		private var nextPickUpTime:Number;
		
		private var g:Game;
		
		public function DropManager(g:Game) {
			super();
			this.g = g;
			nextPickUpTime = 0;
			drops = new Vector.<Drop>();
			dropsById = new Dictionary();
			createdDropIds = new Dictionary();
			pickupQueue = new Vector.<PickUpMsg>();
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("spawnDrops",onSpawn);
		}
		
		public function initDrops(m:Message) : void {
			spawn(m);
		}
		
		public function update() : void {
			var _local2:int = 0;
			var _local1:Drop = null;
			var _local3:int = int(drops.length);
			_local2 = _local3 - 1;
			while(_local2 > -1) {
				_local1 = drops[_local2];
				_local1.update();
				if(_local1.expired) {
					remove(_local1,_local2);
					g.emitterManager.clean(_local1);
				}
				_local2--;
			}
			if(nextPickUpTime > g.time) {
				return;
			}
			_local3 = int(pickupQueue.length);
			_local2 = _local3 - 1;
			while(_local2 > -1) {
				if(pickupQueue.length > _local2) {
					tryPickup(null,pickupQueue[_local2],pickupQueue[_local2].i);
				}
				_local2--;
			}
			nextPickUpTime = g.time + 250;
		}
		
		public function getDrop() : Drop {
			return new Drop(g);
		}
		
		private function remove(drop:Drop, index:int) : void {
			drops.splice(index,1);
			g.hud.radar.remove(drop);
			createdDropIds[drop.id.toString()] = false;
			dropsById[drop.id.toString()] = null;
			drop.removeFromCanvas();
			drop.reset();
		}
		
		private function onSpawn(m:Message) : void {
			spawn(m);
		}
		
		public function spawn(m:Message, start:int = 0, end:int = 0) : void {
			var _local5:* = 0;
			var _local7:String = null;
			var _local6:int = 0;
			var _local8:Boolean = false;
			var _local4:int = int(end != 0 ? end : m.length - start);
			_local5 = start;
			while(_local5 < start + _local4) {
				_local7 = m.getString(_local5);
				_local6 = m.getInt(_local5 + 1);
				_local8 = m.getBoolean(_local5 + 2);
				if(_local7 == null || _local7 == "") {
					g.showErrorDialog("Init drops didn\'t work correctly! message: " + m.toString(),true);
					return;
				}
				if(_local7 == "empty") {
					return;
				}
				createdDropIds[_local6.toString()] = true;
				if(!_local8) {
					createSetDrop(DropFactory.createDrop(_local7,g),m,_local5);
				} else {
					createSetDrop(DropFactory.createDropFromCargo(_local7,g),m,_local5);
				}
				_local5 += 10;
			}
		}
		
		public function getDropItems(key:String, g:Game, seed:Number) : DropBase {
			var _local7:Boolean = false;
			var _local8:int = 0;
			var _local6:int = 0;
			var _local11:int = 0;
			var _local9:DropItem = null;
			if(key == "" || key == null) {
				return null;
			}
			var _local4:Random = new Random(seed);
			var _local10:Object = DataLocator.getService().loadKey("Drops",key);
			var _local12:DropBase = new DropBase();
			_local12.crate = _local10.crate;
			if(_local12.crate) {
				if(_local4.randomNumber() >= _local10.chance) {
					_local12.crate = false;
					return null;
				}
				_local7 = Boolean(_local10.artifactChance);
				_local12.containsArtifact = _local7 > _local4.randomNumber();
			}
			if(_local10.type == "mission") {
				_local8 = int(_local10.fluxMax);
				_local6 = int(_local10.fluxMin);
				_local12.flux = _local6;
				_local11 = 0;
				while(_local11 < _local8 - _local6) {
					if(_local4.randomNumber() <= 0.5) {
						break;
					}
					_local12.flux += 1;
					_local11++;
				}
				if(_local12.flux == _local8) {
					if(_local4.randomNumber() > 0.5) {
						_local12.flux = _local6;
					}
				}
				_local12.artifactAmount = _local10.artifactAmount;
				_local12.artifactLevel = _local10.artifactLevel;
			} else {
				_local12.flux = _local10.fluxMin + _local4.random(_local10.fluxMax - _local10.fluxMin + 1);
			}
			_local12.xp = _local10.xpMin + _local4.random(_local10.xpMax - _local10.xpMin + 1);
			if(_local10.reputation) {
				_local12.reputation = _local10.reputation;
			} else {
				_local12.reputation = 0;
			}
			for each(var _local5 in _local10.dropItems) {
				_local9 = getDropItem(_local5,_local4);
				if(_local9 != null) {
					_local12.items.push(_local9);
				}
			}
			return _local12;
		}
		
		public function getDropItem(obj:Object, r:Random) : DropItem {
			var _local5:DropItem = null;
			var _local4:int = 0;
			var _local6:int = 0;
			var _local8:int = 0;
			var _local3:Object = null;
			var _local7:Object = null;
			if(r.randomNumber() <= obj.chance) {
				_local5 = new DropItem();
				_local4 = 0;
				_local6 = 0;
				if(obj.min && obj.max) {
					_local4 = int(obj.min);
					_local6 = int(obj.max);
				}
				_local8 = _local6 - _local4;
				_local5.quantity = _local4 + r.random(_local8);
				_local5.item = obj.item;
				_local5.table = obj.table;
				if(_local5.quantity == 0) {
					return null;
				}
				_local3 = DataLocator.getService().loadKey(_local5.table,_local5.item);
				_local5.name = _local3.name;
				_local5.hasTechTree = _local3.hasTechTree;
				if(_local5.table == "Weapons") {
					_local5.bitmapKey = _local3.techIcon;
				} else if(_local5.table == "Skins") {
					_local7 = DataLocator.getService().loadKey("Ships",_local3.ship);
					_local5.bitmapKey = _local7.bitmap;
				} else {
					_local5.bitmapKey = _local3.bitmap;
				}
				return _local5;
			}
			return null;
		}
		
		private function createSetDrop(drop:Drop, m:Message, i:int) : void {
			var _local4:Drop = null;
			if(drop == null) {
				return;
			}
			drop.id = m.getInt(i + 1);
			drop.x = 0.01 * m.getInt(i + 3);
			drop.y = 0.01 * m.getInt(i + 4);
			drop.speed.x = 0.01 * m.getInt(i + 5);
			drop.speed.y = 0.01 * m.getInt(i + 6);
			drop.expireTime = m.getNumber(i + 7);
			drop.quantity = m.getInt(i + 8);
			drop.containsUniqueArtifact = m.getBoolean(i + 9);
			if(dropsById[drop.id.toString()] != null) {
				_local4 = dropsById[drop.id.toString()];
				_local4.expire();
			}
			dropsById[drop.id.toString()] = drop;
			drops.push(drop);
		}
		
		public function tryBeamPickup(m:Message, i:int) : void {
			var _local5:String = m.getString(i);
			var _local4:int = m.getInt(i + 1);
			var _local6:Player = g.playerManager.playersById[_local5];
			var _local3:Drop = dropsById[_local4.toString()];
			if(_local3 != null && _local6 != null) {
				_local3.tractorBeamPlayer = _local6;
				_local3.expireTime = g.time + 2000;
			}
			pickupQueue.push(new PickUpMsg(m,3 * 80,i));
		}
		
		public function tryPickup(m:Message = null, po:PickUpMsg = null, i:int = 0) : void {
			var _local9:int = 0;
			if(m == null) {
				m = po.msg;
			} else if(m.length < i + 2) {
				return;
			}
			var _local8:int = m.getInt(i - 1);
			var _local10:String = m.getString(i);
			var _local5:String = m.getInt(i + 1).toString();
			var _local4:Drop = dropsById[_local5];
			if(_local4 == null && createdDropIds[_local5] != null) {
				if(createdDropIds[_local5] == true) {
					for each(var _local6 in pickupQueue) {
						if(_local6.msg == m) {
							Console.write("Pickup already queued. dropId: " + _local5);
							return;
						}
					}
					Console.write("Pickup queued.");
					pickupQueue.push(new PickUpMsg(m,80,i));
					return;
				}
				_local9 = int(pickupQueue.indexOf(po));
				pickupQueue.splice(_local9,1);
				return;
			}
			if(_local4 == null) {
				Console.write("FAILED Pickup. No drop with id : " + _local5);
				_local9 = int(pickupQueue.indexOf(po));
				if(po != null && _local9 != -1) {
					po.timeout--;
					if(po.timeout < 1) {
						pickupQueue.splice(_local9,1);
						Console.write("FAILED Pickup. Removed from queue due to timeout.");
					}
				}
				return;
			}
			var _local11:Player = g.playerManager.playersById[_local10];
			if(_local11 == null || _local11.ship == null) {
				return;
			}
			var _local7:Boolean = _local4.pickup(_local11,m,i + 2);
			if(!_local7) {
				return;
			}
			delete dropsById[_local5];
			_local9 = int(pickupQueue.indexOf(po));
			if(_local9 != -1) {
				pickupQueue.splice(_local9,1);
			}
		}
		
		private function buyTractorBeam() : void {
			g.send("buyTractorBeam");
		}
		
		public function dispose() : void {
			for each(var _local1 in drops) {
				_local1.removeFromCanvas();
				_local1.reset();
			}
			drops = null;
			createdDropIds = null;
			pickupQueue = null;
			dropsById = null;
		}
		
		public function forceUpdate() : void {
			var _local1:Drop = null;
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < drops.length) {
				_local1 = drops[_local2];
				_local1.nextDistanceCalculation = -1;
				_local2++;
			}
		}
	}
}

import playerio.Message;

class PickUpMsg {
	public var msg:Message;
	
	public var timeout:int;
	
	public var i:int;
	
	public function PickUpMsg(m:Message, timeout:int, i:int = 0) {
		super();
		this.timeout = timeout;
		this.i = i;
		this.msg = m;
	}
}
