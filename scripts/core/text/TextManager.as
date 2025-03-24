package core.text {
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import core.player.Player;
	import core.scene.Game;
	import core.unit.Unit;
	import flash.geom.Point;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class TextManager {
		public var inactiveTexts:Vector.<TextParticle>;
		
		public var textHandler:TextHandler;
		
		private var g:Game;
		
		private var dmgTextCounter:int = 0;
		
		private var missionCompleteText:TextParticle;
		
		private var bossSpawnedText:TextParticle;
		
		private var uberRankCompleteText:TextParticle;
		
		private var uberRankExtraLifeText:TextParticle;
		
		private var uberTaskText:TextParticle;
		
		private var latestMissionUpdateText:TextParticle;
		
		private var isPlayingNewMissionArrived:Boolean = false;
		
		public function TextManager(g:Game) {
			var _local3:int = 0;
			var _local2:TextParticle = null;
			super();
			this.g = g;
			inactiveTexts = new Vector.<TextParticle>();
			while(_local3 < 40) {
				_local2 = new TextParticle(_local3,g);
				inactiveTexts.push(_local2);
				_local3++;
			}
		}
		
		public function loadHandlers() : void {
			textHandler = new TextHandler(g);
		}
		
		public function update() : void {
			textHandler.update();
		}
		
		public function createDebuffText(debuffText:String, target:Unit) : void {
		}
		
		public function createDmgText(dmg:int, target:Unit, shieldHeal:Boolean = false) : void {
			var _local7:TextParticle = null;
			var _local8:Number = NaN;
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			var _local4:Point = null;
			if(target.lastDmgTime > g.time - 250 && dmg > 0) {
				target.lastDmgTime = g.time;
				target.lastDmg += dmg;
				_local7 = target.lastDmgText;
				if(_local7 != null) {
					_local8 = 1 - (1000 - _local7.ttl) / 1000;
					_local7.ttl = 1000;
					_local7.speed.x *= _local8;
					_local7.speed.y *= _local8;
					_local7.text = target.lastDmg.toString();
					if(target.lastDmg > 1000) {
						_local7.scaleX = _local7.scaleY = 1.2;
					} else if(target.lastDmg > 10000) {
						_local7.scaleX = _local7.scaleY = 1.5;
					}
				}
			} else if(target.lastHealTime > g.time - 250 && dmg < 0) {
				target.lastHealTime = g.time;
				target.lastHeal -= dmg;
				_local7 = target.lastHealText;
				if(_local7 != null) {
					_local8 = 1 - (1000 - _local7.ttl) / 1000;
					_local7.ttl = 1000;
					_local7.speed.x *= _local8;
					_local7.speed.y *= _local8;
					_local7.text = target.lastHeal.toString();
					if(target.lastHeal > 1000) {
						_local7.scaleX = _local7.scaleY = 1.2;
					} else if(target.lastHeal > 10000) {
						_local7.scaleX = _local7.scaleY = 1.5;
					}
				}
			} else {
				_local5 = 5;
				_local6 = -40;
				_local4 = target.pos.clone();
				_local4.y = _local4.y - 15;
				if(dmg > 0) {
					target.lastDmgTime = g.time;
					target.lastDmgText = textHandler.add(dmg.toString(),_local4,new Point(_local5,_local6),1000,0xff2222,15);
					target.lastDmg = dmg;
					target.lastDmgTextOffset = 0;
					_local7 = target.lastDmgText;
					if(target.lastDmg > 1000) {
						_local7.scaleX = _local7.scaleY = 1.2;
					} else if(target.lastDmg > 10000) {
						_local7.scaleX = _local7.scaleY = 1.5;
					}
				} else if(dmg < 0) {
					target.lastHealTime = g.time;
					target.lastHealText = textHandler.add((-dmg).toString(),_local4,new Point(_local5,_local6),1000,5890137,15);
					target.lastHeal = -dmg;
					target.lastHealTextOffset = 0;
					_local7 = target.lastHealText;
					if(target.lastHeal > 1000) {
						_local7.scaleX = _local7.scaleY = 1.2;
					} else if(target.lastHeal > 10000) {
						_local7.scaleX = _local7.scaleY = 1.5;
					}
				}
				dmgTextCounter += 1;
			}
		}
		
		public function createXpText(xp:int) : void {
			var _local4:int = 0;
			var _local3:Number = -15 - Math.random() * 8;
			var _local2:Number = (Math.random() - 0.5) * 15;
			var _local5:Point = new Point(g.stage.stageWidth / 2 - 20 + _local2,g.stage.stageHeight / 2 + 200);
			if(xp > 0) {
				_local4 = 20;
				if(xp < 10) {
					_local4 = 17;
				}
				if(g.me.hasExpBoost) {
					textHandler.add("+" + xp.toFixed(0).toString() + " xp",_local5,new Point(_local2,_local3),50 * 60,0x66ff66,_local4,true);
				} else {
					textHandler.add("+" + xp.toString() + " xp",_local5,new Point(_local2,_local3),50 * 60,0xaaaa33,_local4,true);
				}
			} else {
				textHandler.add(xp.toString() + " xp",_local5,new Point(_local2,_local3),5000,0xff3333,_local4,true);
			}
		}
		
		public function createScoreText(score:int) : void {
			var _local3:Number = -15 - Math.random() * 15;
			var _local2:Number = (Math.random() - 0.5) * 15;
			var _local5:Point = new Point(g.stage.stageWidth / 2 - 20 + _local2,g.stage.stageHeight / 2 + 3 * 60);
			var _local4:int = 26;
			if(score < 10) {
				_local4 = 20;
			}
			textHandler.add("+" + score.toFixed(0).toString() + " troons",_local5,new Point(_local2,_local3),50 * 60,0xff44aa,_local4,true);
		}
		
		public function createPvpText(txt:String, offset:int = 0, size:int = 40, colour:uint = 5635925) : void {
			var _local6:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 3 + offset);
			var _local5:Number = -5;
			textHandler.add(txt,_local6,new Point(0,_local5),5000,colour,size,true);
		}
		
		public function createLevelUpText(level:int) : void {
			var _local3:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 3 * 60);
			var _local2:Number = -20;
			textHandler.add("You reached level " + level + "!",_local3,new Point(0,_local2),7000,0xd8d8d8,40,true);
			SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
		}
		
		public function createTroonsText(troons:int) : void {
			var _local3:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 3 * 60);
			var _local2:Number = -25;
			textHandler.add("You gained " + troons + " troons!",_local3,new Point(0,_local2),7000,0x8888ff,20,true);
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
		}
		
		public function createBonusXpText(bonusXp:int) : void {
			var _local3:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 3 * 60);
			var _local2:Number = -20;
			textHandler.add("New Encounter!",_local3,new Point(0,_local2 + 15),7000,0x44ff44,16,true);
			textHandler.add("+" + bonusXp + " Bonus XP!",_local3,new Point(0,_local2),7000,0xaaaa33,20,true);
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
		}
		
		public function createFragScore(fragFactor:int) : void {
			var _local3:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 3 * 60);
			var _local2:Number = -20;
			textHandler.add("+" + fragFactor + " frag score!",_local3,new Point(0,_local2),7000,0xffaa33,20,true);
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
		}
		
		public function createLevelUpDetailsText() : void {
			var vx:Number = 0;
			var vy:Number = -35;
			var pos1:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 230);
			var pos2:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 260);
			var pos3:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 290);
			var soundManager:ISound = SoundLocator.getService();
			soundManager.preCacheSound("F3RA7-UJ6EKLT6WeJyKq-w");
			TweenMax.delayedCall(2.5,function():void {
				soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
				textHandler.add("+8% shield",pos1,new Point(vx,vy),0x1f40,98768,20,true);
			});
			TweenMax.delayedCall(3.5,function():void {
				soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
				textHandler.add("+8% health",pos2,new Point(-vx,vy - 6),0x1f40,4902913,20,true);
			});
			TweenMax.delayedCall(4.5,function():void {
				soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
				textHandler.add("+8% damage",pos3,new Point(0,vy - 12),0x1f40,0xff4444,20,true);
			});
			TweenMax.delayedCall(5.5,function():void {
				soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
				textHandler.add("+1% shield regen",pos3,new Point(0,vy - 12),0x1f40,98768,20,true);
			});
		}
		
		public function createMissionCompleteText() : void {
			var _local1:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 100);
			missionCompleteText = textHandler.add("Reward claimed!",_local1,new Point(0,0),0x1f40,0xd8d8d8,40,true);
			missionCompleteText.alpha = 0;
			missionCompleteText.scaleX = 30;
			missionCompleteText.scaleY = 30;
			TweenMax.to(missionCompleteText,0.7,{
				"alpha":1,
				"scaleX":1,
				"scaleY":1,
				"onComplete":missionCompleteTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		public function createBossSpawnedText(s:String) : void {
			var _local2:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 150);
			bossSpawnedText = textHandler.add(s,_local2,new Point(0,0),0x1f40,12787744,40,true);
			bossSpawnedText.alpha = 0;
			TweenMax.to(bossSpawnedText,3,{
				"alpha":1,
				"onComplete":bossSpawnedTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		private function bossSpawnedTextStep2() : void {
			TweenMax.delayedCall(1.2,function():void {
				bossSpawnedText.speed = new Point(0,-20);
			});
		}
		
		public function createUberRankCompleteText(s:String) : void {
			var _local2:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 50);
			uberRankCompleteText = textHandler.add(s,_local2,new Point(0,0),0x1f40,0x44ff44,50,true);
			uberRankCompleteText.alpha = 0;
			TweenMax.to(uberRankCompleteText,3,{
				"alpha":1,
				"onComplete":uberRankCompleteTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		private function uberRankCompleteTextStep2() : void {
			TweenMax.delayedCall(1.2,function():void {
				uberRankCompleteText.speed = new Point(0,-20);
			});
		}
		
		public function createUberExtraLifeText(s:String) : void {
			var _local2:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 50);
			uberRankExtraLifeText = textHandler.add(s,_local2,new Point(0,0),100 * 60,0x88ff88,40,true);
			uberRankExtraLifeText.alpha = 0;
			TweenMax.to(uberRankExtraLifeText,3,{
				"alpha":1,
				"onComplete":uberExtraLifeTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		private function uberExtraLifeTextStep2() : void {
			TweenMax.delayedCall(1.2,function():void {
				uberRankExtraLifeText.speed = new Point(0,-30);
			});
		}
		
		public function createUberTaskText(s:String) : void {
			var _local2:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 100);
			uberTaskText = textHandler.add(s,_local2,new Point(0,0),5000,0xffff88,30,true);
			uberTaskText.alpha = 0;
			TweenMax.to(uberTaskText,3,{
				"alpha":1,
				"onComplete":uberTaskTextStep2,
				"ease":Circ.easeIn
			});
		}
		
		private function uberTaskTextStep2() : void {
			TweenMax.delayedCall(1.2,function():void {
				uberTaskText.speed = new Point(0,-30);
			});
		}
		
		private function missionCompleteTextStep2() : void {
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			TweenMax.delayedCall(1.2,function():void {
				missionCompleteText.speed = new Point(0,-20);
			});
		}
		
		public function createMissionUpdateText(count:int, amount:int) : void {
			if(amount == 0) {
				return;
			}
			TweenMax.delayedCall(0.5,function():void {
				if(latestMissionUpdateText != null) {
					latestMissionUpdateText.alive = false;
				}
				var _local1:Point = new Point(g.stage.stageWidth - 15,g.hud.missionsButton.y - 20);
				SoundLocator.getService().play("W6_dF1iXYUCWWSU57BhU1Q");
				latestMissionUpdateText = textHandler.add("" + count + " of " + amount,_local1,new Point(0,-10),5000,0xd8d8d8,13,true,"right");
			});
		}
		
		public function createMissionFinishedText() : void {
			SoundLocator.getService().preCacheSound("0CELPmI080ujs_ZTFg8iyA");
			TweenMax.delayedCall(1.5,function():void {
				var _local1:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 200);
				textHandler.add("Mission complete!",_local1,new Point(0,-10),7000,4902913,20,true);
				SoundLocator.getService().play("0CELPmI080ujs_ZTFg8iyA");
			});
		}
		
		public function createMissionBestTimeText() : void {
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			TweenMax.delayedCall(4,function():void {
				var _local1:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 200);
				textHandler.add("New time record!",_local1,new Point(0,-9),7000,14340097,12,true);
				SoundLocator.getService().play("0CELPmI080ujs_ZTFg8iyA");
			});
		}
		
		public function createNewMissionArrivedText() : void {
			if(isPlayingNewMissionArrived) {
				return;
			}
			isPlayingNewMissionArrived = true;
			SoundLocator.getService().preCacheSound("6_sJLdnMgEKbvAjTspuOMg",function():void {
				SoundLocator.getService().play("6_sJLdnMgEKbvAjTspuOMg");
				TweenMax.delayedCall(2,function():void {
					var _local2:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 200);
					var _local1:Number = -20;
					textHandler.add("Incoming mission...",_local2,new Point(0,_local1),7000,16776205,20,true);
					isPlayingNewMissionArrived = false;
				});
			});
		}
		
		public function createDailyUpdate(text:String) : void {
			TweenMax.delayedCall(0.5,function():void {
				if(latestMissionUpdateText != null) {
					latestMissionUpdateText.alive = false;
				}
				SoundLocator.getService().play("W6_dF1iXYUCWWSU57BhU1Q");
				var _local1:Point = new Point(g.stage.stageWidth + 15,g.hud.missionsButton.y - 38);
				latestMissionUpdateText = textHandler.add(text,_local1,new Point(0,-10),5000,11061482,13,true,"right");
			});
		}
		
		public function createKillText(s:String, size:Number = 15, ttl:int = 5000, color:uint = 11184810) : void {
			var _local6:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 - 100);
			var _local5:Number = -20;
			textHandler.add(s,_local6,new Point(0,_local5),ttl,color,size,true);
		}
		
		public function createDropText(name:String, amount:int = 1, size:Number = 15, ttl:int = 5000, color:uint = 11184810, offset:int = 0) : void {
			var _local9:int = 0;
			var _local7:int = 0;
			var _local8:Number = NaN;
			var _local12:Point = null;
			var _local14:TextParticle = null;
			var _local10:Player = g.me;
			var _local11:TextParticle = null;
			var _local13:* = null;
			_local9 = _local10.pickUpLog.length - 1;
			while(_local9 > -1) {
				_local11 = _local10.pickUpLog[_local9];
				if(_local11.ttl <= 0) {
					_local10.pickUpLog.splice(_local9,1);
				} else if(contains(_local11.text,name)) {
					_local13 = _local11;
					break;
				}
				_local9--;
			}
			if(_local13 != null) {
				_local7 = getQuantity(_local13.text) + amount;
				_local13.text = name + " x" + _local7;
				_local13.ttl = ttl;
				_local13.alpha = 1;
			} else {
				_local8 = -10;
				_local12 = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 175 + _local10.pickUpLog.length * 15 - offset);
				_local14 = textHandler.add(name + " x" + amount,_local12,new Point(0,_local8),ttl,color,size,true);
				_local10.pickUpLog.push(_local14);
			}
		}
		
		private function contains(t:String, s:String) : Boolean {
			var _local3:int = 0;
			while(_local3 < s.length) {
				if(t.charAt(_local3) != s.charAt(_local3)) {
					return false;
				}
				_local3++;
			}
			return true;
		}
		
		private function getQuantity(s:String) : int {
			var _local2:Array = s.split(" x");
			return int(_local2[1]);
		}
		
		public function createMapEntryText() : void {
			var _local2:Point = new Point(g.stage.stageWidth / 2,g.stage.stageHeight / 2 + 200);
			var _local1:Number = -5;
			textHandler.add("New map entry updated, press [TAB]",_local2,new Point(0,_local1),5000,0x33ff33,16,true);
		}
		
		public function createReputationText(mod:int, target:Unit) : void {
			if(target == null) {
				return;
			}
			var _local4:Number = 5;
			var _local5:Number = -30;
			var _local3:Point = new Point(target.pos.x,target.pos.y);
			_local3.y -= 15;
			if(mod > 0) {
				textHandler.add("+" + mod.toString() + " police reputation",_local3,new Point(_local4,_local5),50 * 60,3103982,15,true);
			} else {
				textHandler.add("+" + (-mod).toString() + " pirate reputation",_local3,new Point(_local4,_local5),50 * 60,11690209,15,true);
			}
		}
		
		public function dispose() : void {
			textHandler.dispose();
		}
	}
}

