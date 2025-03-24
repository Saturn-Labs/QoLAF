package startSetup {
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class StartShipBaseStats extends Sprite {
		private var skinObj:Object;
		
		private var speed:int;
		
		private var tweenDelay:Number = 0.7;
		
		public function StartShipBaseStats(skinObj:Object, speed:int) {
			super();
			this.skinObj = skinObj;
			this.speed = speed;
			var _local3:int = 7;
			var _local4:int = 27;
			addStat("statHealth","Health",_local3);
			_local3 += _local4;
			addStat("statArmor","Armor",_local3);
			_local3 += _local4;
			addStat("statShield","Shield",_local3);
			_local3 += _local4;
			addStat("statShieldRegen","Speed",_local3);
			_local3 += _local4;
			addWeapon(_local3);
		}
		
		private function addWeapon(yPos:int) : void {
			var _local4:int = 0;
			var _local3:Object = null;
			var _local2:Text = null;
			var _local5:Text = null;
			_local4 = 0;
			while(_local4 < skinObj.upgrades.length - 1) {
				_local3 = skinObj.upgrades[_local4];
				if(_local3.table == "Weapons") {
					_local2 = new Text();
					_local2.y = yPos;
					_local2.text = "WEAPON:";
					_local2.size = 12;
					_local2.color = 16689475;
					addChild(_local2);
					_local5 = new Text();
					_local5.y = yPos;
					_local5.x = 114;
					_local5.text = _local3.name.toUpperCase();
					_local5.size = 12;
					_local5.color = 54271;
					addChild(_local5);
					return;
				}
				_local4++;
			}
		}
		
		private function addStat(type:String, name:String, yPos:int) : void {
			var _local7:int = 0;
			var _local6:int = 0;
			var _local4:Quad = null;
			var _local5:Text = new Text();
			_local5.y = yPos;
			_local5.text = name.toUpperCase() + ":";
			_local5.size = 12;
			_local5.color = 16689475;
			addChild(_local5);
			if(name == "Speed") {
				_local7 = speed;
			} else {
				_local7 = int(skinObj[type]);
			}
			_local6 = 0;
			while(_local6 < 10) {
				_local4 = new Quad(12,12,54271);
				_local4.alpha = 0.2;
				if(_local7 > _local6) {
					TweenMax.to(_local4,1,{
						"alpha":0.7,
						"delay":tweenDelay,
						"ease":Elastic.easeInOut
					});
					tweenDelay += 0.07;
				}
				_local4.y = yPos + 3;
				_local4.x = 114 + _local6 * 16;
				addChild(_local4);
				_local6++;
			}
		}
	}
}

