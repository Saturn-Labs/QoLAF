package core.states.menuStates {
	import core.hud.components.Text;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	import core.weapon.Weapon;
	import starling.display.Image;
	import starling.events.TouchEvent;
	
	public class ChangeWeaponState extends DisplayState {
		private var p:Player;
		
		private var slot:int;
		
		public function ChangeWeaponState(g:Game, p:Player, slot:int, isRoot:Boolean = false) {
			super(g,HomeState,isRoot);
			this.p = p;
			this.slot = slot;
		}
		
		override public function enter() : void {
			super.enter();
			var _local1:Text = new Text(60,80);
			_local1.wordWrap = false;
			_local1.size = 12;
			_local1.color = 0xffffff;
			_local1.htmlText = "Assign a weapon to slot <FONT COLOR=\'#fea943\'>" + slot + "</FONT>.";
			addChild(_local1);
			var _local3:int = 0;
			var _local4:int = 0;
			for each(var _local2 in p.ship.weapons) {
				createWeaponBox(_local3,_local4,_local2);
				_local3++;
				if(_local3 == 10) {
					_local4++;
					_local3 = 0;
				}
			}
		}
		
		private function createWeaponBox(i:int, j:int, w:Weapon) : void {
			var weaponBox:Image = new Image(textureManager.getTextureGUIByKey(w.techIconFileName));
			weaponBox.x = i * 50 + 60;
			weaponBox.y = j * 50 + 110;
			weaponBox.useHandCursor = true;
			weaponBox.addEventListener("touch",function(param1:TouchEvent):void {
				if(param1.getTouch(weaponBox,"ended")) {
					g.playerManager.trySetActiveWeapons(p,slot,w.key);
					g.hud.weaponHotkeys.refresh();
					sm.revertState();
				}
			});
			addChild(weaponBox);
		}
		
		override public function execute() : void {
			super.execute();
		}
		
		override public function exit() : void {
			super.exit();
		}
	}
}

