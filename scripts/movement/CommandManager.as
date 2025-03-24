package movement {
	import core.hud.components.hotkeys.AbilityHotkey;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import flash.utils.Dictionary;
	import playerio.Message;
	
	public class CommandManager {
		public var commands:Vector.<Command> = new Vector.<Command>();
		
		private var sendBuffer:Vector.<Command> = new Vector.<Command>();
		
		private var g:Game;
		
		public function CommandManager(g:Game) {
			super();
			this.g = g;
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("command",commandReceived);
		}
		
		public function flush() : void {
			if(sendBuffer.length == 0) {
				return;
			}
			var _local2:Message = g.createMessage("command");
			for each(var _local1 in sendBuffer) {
				_local2.add(_local1.type);
				_local2.add(_local1.active);
				_local2.add(_local1.time);
			}
			g.sendMessage(_local2);
			sendBuffer = new Vector.<Command>();
		}
		
		public function addCommand(type:int, active:Boolean) : void {
			var _local3:PlayerShip = g.playerManager.me.ship;
			var _local4:Heading = _local3.course;
			var _local5:Command = new Command();
			_local5.type = type;
			_local5.active = active;
			while(_local4.time < g.time - 2 * 33) {
				_local3.convergerUpdateHeading(_local4);
			}
			_local5.time = _local4.time;
			commands.push(_local5);
			sendCommand(_local5);
			_local3.clearConvergeTarget();
			_local3.runCommand(_local5);
		}
		
		private function sendCommand(cmd:Command) : void {
			var _local2:Message = g.createMessage("command");
			_local2.add(cmd.type);
			_local2.add(cmd.active);
			_local2.add(cmd.time);
			g.sendMessage(_local2);
		}
		
		public function commandReceived(m:Message) : void {
			var _local2:Dictionary = g.playerManager.playersById;
			var _local3:String = m.getString(0);
			var _local4:Command = new Command();
			_local4.type = m.getInt(1);
			_local4.active = m.getBoolean(2);
			_local4.time = m.getNumber(3);
			var _local5:Player = _local2[_local3];
			if(_local5 != null && _local5.ship != null) {
				_local5.ship.runCommand(_local4);
			}
		}
		
		public function runCommand(heading:Heading, cmdTime:Number) : void {
			var _local3:int = 0;
			var _local4:Command = null;
			_local3 = 0;
			while(_local3 < commands.length) {
				_local4 = commands[_local3];
				if(_local4.time >= cmdTime) {
					if(_local4.time != cmdTime) {
						break;
					}
					heading.runCommand(_local4);
				}
				_local3++;
			}
		}
		
		public function clearCommands(time:Number) : void {
			var _local2:int = 0;
			var _local3:int = 0;
			_local2 = 0;
			while(_local2 < commands.length) {
				if(commands[_local2].time >= time) {
					break;
				}
				_local3++;
				_local2++;
			}
			if(_local3 != 0) {
				commands.splice(0,_local3);
			}
		}
		
		public function addBoostCommand(ab:AbilityHotkey = null) : void {
			var _local2:PlayerShip = g.me.ship;
			if(_local2.boostNextRdy < g.time && _local2.hasBoost) {
				g.hud.abilities.initiateCooldown("Engine");
				_local2.boost();
				addCommand(4,true);
			}
		}
		
		public function addDmgBoostCommand(ab:AbilityHotkey = null) : void {
			var _local2:PlayerShip = g.me.ship;
			if(_local2.hasDmgBoost && _local2.dmgBoostNextRdy < g.time) {
				g.hud.abilities.initiateCooldown("Power");
				_local2.dmgBoost();
				addCommand(7,true);
			}
		}
		
		public function addShieldConvertCommand(ab:AbilityHotkey = null) : void {
			var _local2:PlayerShip = g.me.ship;
			if(_local2.hasArmorConverter && _local2.convNextRdy < g.time) {
				g.hud.abilities.initiateCooldown("Armor");
				_local2.convertShield();
				addCommand(6,true);
			}
		}
		
		public function addHardenedShieldCommand(ab:AbilityHotkey = null) : void {
			var _local2:PlayerShip = g.me.ship;
			if(_local2.hardenNextRdy < g.time && _local2.hasHardenedShield) {
				g.hud.abilities.initiateCooldown("Shield");
				_local2.hardenShield();
				addCommand(5,true);
			}
		}
	}
}

