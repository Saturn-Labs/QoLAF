package core.states.menuStates
{
	import core.hud.components.Text;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	import core.weapon.Weapon;
	import starling.display.Image;
	import starling.events.TouchEvent;
	
	public class ChangeWeaponState extends DisplayState
	{
		private var p:Player;
		
		private var slot:int;
		
		public function ChangeWeaponState(param1:Game, param2:Player, param3:int, param4:Boolean = false)
		{
			super(param1, HomeState, param4);
			this.p = param2;
			this.slot = param3;
		}
		
		override public function enter():void
		{
			super.enter();
			var _loc2_:Text = new Text(60, 80);
			_loc2_.wordWrap = false;
			_loc2_.size = 12;
			_loc2_.color = 16777215;
			_loc2_.htmlText = "Assign a weapon to slot <FONT COLOR='#fea943'>" + slot + "</FONT>.";
			addChild(_loc2_);
			var _loc4_:int = 0;
			var _loc3_:int = 0;
			for each (var _loc1_:* in p.ship.weapons)
			{
				createWeaponBox(_loc4_, _loc3_, _loc1_);
				_loc4_++;
				if (_loc4_ == 10)
				{
					_loc3_++;
					_loc4_ = 0;
				}
			}
		}
		
		private function createWeaponBox(param1:int, param2:int, param3:Weapon):void
		{
			var i:int = param1;
			var j:int = param2;
			var w:Weapon = param3;
			var weaponBox:Image = new Image(textureManager.getTextureGUIByKey(w.techIconFileName));
			weaponBox.x = i * 50 + 60;
			weaponBox.y = j * 50 + 110;
			weaponBox.useHandCursor = true;
			weaponBox.addEventListener("touch", function(param1:TouchEvent):void
			{
				if (param1.getTouch(weaponBox, "ended"))
				{
					g.playerManager.trySetActiveWeapons(p, slot, w.key);
					g.hud.weaponHotkeys.refresh();
					sm.revertState();
				}
			});
			addChild(weaponBox);
		}
		
		override public function execute():void
		{
			super.execute();
		}
		
		override public function exit():void
		{
			super.exit();
		}
	}
}
