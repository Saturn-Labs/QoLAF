package core.hud.components.hangar {
	import com.greensock.TweenMax;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class SkinItemBaseStats extends Sprite {
		private var skinObj:Object;
		
		private var tweenDelay:Number = 0;
		
		public function SkinItemBaseStats(skinObj:Object) {
			super();
			this.skinObj = skinObj;
			addStat("statHealth","Health",23);
			addStat("statArmor","Armor",43);
			addStat("statShield","Shield",63);
			addStat("statShieldRegen","S. regen",83);
		}
		
		private function addStat(type:String, name:String, yPos:int) : void {
			var _local6:int = 0;
			var _local4:Quad = null;
			var _local5:Text = new Text(0,yPos,true,"Verdana");
			_local5.text = name + ":";
			_local5.size = 13;
			_local5.color = 0xffffff;
			addChild(_local5);
			var _local7:int = int(skinObj[type]);
			_local6 = 0;
			while(_local6 < 10) {
				_local4 = new Quad(8,8,111062);
				_local4.alpha = 0.3;
				if(_local7 > _local6) {
					TweenMax.to(_local4,0.2,{
						"alpha":1,
						"delay":tweenDelay
					});
					tweenDelay += 0.05;
				}
				_local4.y = yPos + 8;
				_local4.x = 84 + _local6 * 11;
				addChild(_local4);
				_local6++;
			}
		}
	}
}

