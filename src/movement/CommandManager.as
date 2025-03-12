package movement
{
	import core.hud.components.hotkeys.AbilityHotkey;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import flash.utils.Dictionary;
	import playerio.Message;
	
	public class CommandManager
	{
		public var commands:Vector.<Command>;
		
		private var sendBuffer:Vector.<Command>;
		
		private var g:Game;
		
		public function CommandManager(param1:Game)
		{
			commands = new Vector.<Command>();
			sendBuffer = new Vector.<Command>();
			super();
			this.g = param1;
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("command", commandReceived);
		}
		
		public function flush():void
		{
			if (sendBuffer.length == 0)
			{
				return;
			}
			var _loc1_:Message = g.createMessage("command");
			for each (var _loc2_:* in sendBuffer)
			{
				_loc1_.add(_loc2_.type);
				_loc1_.add(_loc2_.active);
				_loc1_.add(_loc2_.time);
			}
			g.sendMessage(_loc1_);
			sendBuffer = new Vector.<Command>();
		}
		
		public function addCommand(param1:int, param2:Boolean):void
		{
			var _loc4_:PlayerShip = g.playerManager.me.ship;
			var _loc3_:Heading = _loc4_.course;
			var _loc5_:Command = new Command();
			_loc5_.type = param1;
			_loc5_.active = param2;
			while (_loc3_.time < g.time - 2 * 33)
			{
				_loc4_.convergerUpdateHeading(_loc3_);
			}
			_loc5_.time = _loc3_.time;
			commands.push(_loc5_);
			sendCommand(_loc5_);
			_loc4_.clearConvergeTarget();
			_loc4_.runCommand(_loc5_);
		}
		
		private function sendCommand(param1:Command):void
		{
			var _loc2_:Message = g.createMessage("command");
			_loc2_.add(param1.type);
			_loc2_.add(param1.active);
			_loc2_.add(param1.time);
			g.sendMessage(_loc2_);
		}
		
		public function commandReceived(param1:Message):void
		{
			var _loc5_:Dictionary = g.playerManager.playersById;
			var _loc4_:String = param1.getString(0);
			var _loc2_:Command = new Command();
			_loc2_.type = param1.getInt(1);
			_loc2_.active = param1.getBoolean(2);
			_loc2_.time = param1.getNumber(3);
			var _loc3_:Player = _loc5_[_loc4_];
			if (_loc3_ != null && _loc3_.ship != null)
			{
				_loc3_.ship.runCommand(_loc2_);
			}
		}
		
		public function runCommand(param1:Heading, param2:Number):void
		{
			var _loc4_:int = 0;
			var _loc3_:Command = null;
			_loc4_ = 0;
			while (_loc4_ < commands.length)
			{
				_loc3_ = commands[_loc4_];
				if (_loc3_.time >= param2)
				{
					if (_loc3_.time != param2)
					{
						break;
					}
					param1.runCommand(_loc3_);
				}
				_loc4_++;
			}
		}
		
		public function clearCommands(param1:Number):void
		{
			var _loc3_:int = 0;
			var _loc2_:int = 0;
			_loc3_ = 0;
			while (_loc3_ < commands.length)
			{
				if (commands[_loc3_].time >= param1)
				{
					break;
				}
				_loc2_++;
				_loc3_++;
			}
			if (_loc2_ != 0)
			{
				commands.splice(0, _loc2_);
			}
		}
		
		public function addBoostCommand(param1:AbilityHotkey = null):void
		{
			var _loc2_:PlayerShip = g.me.ship;
			if (_loc2_.boostNextRdy < g.time && _loc2_.hasBoost)
			{
				g.hud.abilities.initiateCooldown("Engine");
				_loc2_.boost();
				addCommand(4, true);
			}
		}
		
		public function addDmgBoostCommand(param1:AbilityHotkey = null):void
		{
			var _loc2_:PlayerShip = g.me.ship;
			if (_loc2_.hasDmgBoost && _loc2_.dmgBoostNextRdy < g.time)
			{
				g.hud.abilities.initiateCooldown("Power");
				_loc2_.dmgBoost();
				addCommand(7, true);
			}
		}
		
		public function addShieldConvertCommand(param1:AbilityHotkey = null):void
		{
			var _loc2_:PlayerShip = g.me.ship;
			if (_loc2_.hasArmorConverter && _loc2_.convNextRdy < g.time)
			{
				g.hud.abilities.initiateCooldown("Armor");
				_loc2_.convertShield();
				addCommand(6, true);
			}
		}
		
		public function addHardenedShieldCommand(param1:AbilityHotkey = null):void
		{
			var _loc2_:PlayerShip = g.me.ship;
			if (_loc2_.hardenNextRdy < g.time && _loc2_.hasHardenedShield)
			{
				g.hud.abilities.initiateCooldown("Shield");
				_loc2_.hardenShield();
				addCommand(5, true);
			}
		}
	}
}
