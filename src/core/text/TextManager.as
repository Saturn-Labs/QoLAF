package core.text
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import core.player.Player;
	import core.scene.Game;
	import core.unit.Unit;
	import flash.geom.Point;
	import sound.ISound;
	import sound.SoundLocator;

	public class TextManager
	{
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
		public function TextManager(param1:Game)
		{
			var _loc3_:int = 0;
			var _loc2_:TextParticle = null;
			super();
			this.g = param1;
			inactiveTexts = new Vector.<TextParticle>();
			while (_loc3_ < 40)
			{
				_loc2_ = new TextParticle(_loc3_, param1);
				inactiveTexts.push(_loc2_);
				_loc3_++;
			}
		}

		public function loadHandlers():void
		{
			textHandler = new TextHandler(g);
		}

		public function update():void
		{
			textHandler.update();
		}

		public function createDebuffText(param1:String, param2:Unit):void
		{
		}

		public function createDmgText(param1:int, param2:Unit, param3:Boolean = false):void
		{
			var _loc6_:TextParticle = null;
			var _loc4_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc8_:Point = null;
			if (param2.lastDmgTime > g.time - 250 && param1 > 0)
			{
				param2.lastDmgTime = g.time;
				param2.lastDmg += param1;
				_loc6_ = param2.lastDmgText;
				if (_loc6_ != null)
				{
					_loc4_ = 1 - (1000 - _loc6_.ttl) / 1000;
					_loc6_.ttl = 1000;
					_loc6_.speed.x *= _loc4_;
					_loc6_.speed.y *= _loc4_;
					_loc6_.text = param2.lastDmg.toString();
					if (param2.lastDmg > 1000)
					{
						_loc6_.scaleX = _loc6_.scaleY = 1.2;
					}
					else if (param2.lastDmg > 10000)
					{
						_loc6_.scaleX = _loc6_.scaleY = 1.5;
					}
				}
			}
			else if (param2.lastHealTime > g.time - 250 && param1 < 0)
			{
				param2.lastHealTime = g.time;
				param2.lastHeal -= param1;
				_loc6_ = param2.lastHealText;
				if (_loc6_ != null)
				{
					_loc4_ = 1 - (1000 - _loc6_.ttl) / 1000;
					_loc6_.ttl = 1000;
					_loc6_.speed.x *= _loc4_;
					_loc6_.speed.y *= _loc4_;
					_loc6_.text = param2.lastHeal.toString();
					if (param2.lastHeal > 1000)
					{
						_loc6_.scaleX = _loc6_.scaleY = 1.2;
					}
					else if (param2.lastHeal > 10000)
					{
						_loc6_.scaleX = _loc6_.scaleY = 1.5;
					}
				}
			}
			else
			{
				_loc7_ = 5;
				_loc5_ = -40;
				_loc8_ = param2.pos.clone();
				_loc8_.y = _loc8_.y - 15;
				if (param1 > 0)
				{
					param2.lastDmgTime = g.time;
					param2.lastDmgText = textHandler.add(param1.toString(), _loc8_, new Point(_loc7_, _loc5_), 1000, 16720418, 15);
					param2.lastDmg = param1;
					param2.lastDmgTextOffset = 0;
					_loc6_ = param2.lastDmgText;
					if (param2.lastDmg > 1000)
					{
						_loc6_.scaleX = _loc6_.scaleY = 1.2;
					}
					else if (param2.lastDmg > 10000)
					{
						_loc6_.scaleX = _loc6_.scaleY = 1.5;
					}
				}
				else if (param1 < 0)
				{
					param2.lastHealTime = g.time;
					param2.lastHealText = textHandler.add((-param1).toString(), _loc8_, new Point(_loc7_, _loc5_), 1000, 5890137, 15);
					param2.lastHeal = -param1;
					param2.lastHealTextOffset = 0;
					_loc6_ = param2.lastHealText;
					if (param2.lastHeal > 1000)
					{
						_loc6_.scaleX = _loc6_.scaleY = 1.2;
					}
					else if (param2.lastHeal > 10000)
					{
						_loc6_.scaleX = _loc6_.scaleY = 1.5;
					}
				}
				dmgTextCounter += 1;
			}
		}

		public function createXpText(param1:int):void
		{
			var _loc4_:int = 0;
			var _loc2_:Number = -15 - Math.random() * 8;
			var _loc3_:Number = (Math.random() - 0.5) * 15;
			var _loc5_:Point = new Point(g.stage.stageWidth / 2 - 20 + _loc3_, g.stage.stageHeight / 2 + 200);
			if (param1 > 0)
			{
				_loc4_ = 20;
				if (param1 < 10)
				{
					_loc4_ = 17;
				}
				if (g.me.hasExpBoost)
				{
					textHandler.add("+" + param1.toFixed(0).toString() + " xp", _loc5_, new Point(_loc3_, _loc2_), 3000, 6750054, _loc4_, true);
				}
				else
				{
					textHandler.add("+" + param1.toString() + " xp", _loc5_, new Point(_loc3_, _loc2_), 3000, 11184691, _loc4_, true);
				}
			}
			else
			{
				textHandler.add(param1.toString() + " xp", _loc5_, new Point(_loc3_, _loc2_), 5000, 16724787, _loc4_, true);
			}
		}

		public function createScoreText(param1:int):void
		{
			var _loc2_:Number = -15 - Math.random() * 15;
			var _loc3_:Number = (Math.random() - 0.5) * 15;
			var _loc5_:Point = new Point(g.stage.stageWidth / 2 - 20 + _loc3_, g.stage.stageHeight / 2 + 180);
			var _loc4_:int = 26;
			if (param1 < 10)
			{
				_loc4_ = 20;
			}
			textHandler.add("+" + param1.toFixed(0).toString() + " troons", _loc5_, new Point(_loc3_, _loc2_), 3000, 16729258, _loc4_, true);
		}

		public function createPvpText(param1:String, param2:int = 0, param3:int = 40, param4:uint = 5635925):void
		{
			var _loc6_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 3 + param2);
			var _loc5_:Number = -5;
			textHandler.add(param1, _loc6_, new Point(0, _loc5_), 5000, param4, param3, true);
		}

		public function createLevelUpText(param1:int):void
		{
			var _loc3_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 180);
			var _loc2_:Number = -20;
			textHandler.add("You reached level " + param1 + "!", _loc3_, new Point(0, _loc2_), 7000, 14211288, 40, true);
			SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
		}

		public function createTroonsText(param1:int):void
		{
			var _loc3_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 180);
			var _loc2_:Number = -25;
			textHandler.add("You gained " + param1 + " troons!", _loc3_, new Point(0, _loc2_), 7000, 8947967, 20, true);
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
		}

		public function createBonusXpText(param1:int):void
		{
			var _loc3_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 180);
			var _loc2_:Number = -20;
			textHandler.add("New Encounter!", _loc3_, new Point(0, _loc2_ + 15), 7000, 4521796, 16, true);
			textHandler.add("+" + param1 + " Bonus XP!", _loc3_, new Point(0, _loc2_), 7000, 11184691, 20, true);
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
		}

		public function createFragScore(param1:int):void
		{
			var _loc3_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 180);
			var _loc2_:Number = -20;
			textHandler.add("+" + param1 + " frag score!", _loc3_, new Point(0, _loc2_), 7000, 16755251, 20, true);
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
		}

		public function createLevelUpDetailsText():void
		{
			var vx:Number = 0;
			var vy:Number = -35;
			var pos1:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 230);
			var pos2:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 260);
			var pos3:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 290);
			var soundManager:ISound = SoundLocator.getService();
			soundManager.preCacheSound("F3RA7-UJ6EKLT6WeJyKq-w");
			TweenMax.delayedCall(2.5, function():void
				{
					soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
					textHandler.add("+8% shield", pos1, new Point(vx, vy), 8000, 98768, 20, true);
				});
			TweenMax.delayedCall(3.5, function():void
				{
					soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
					textHandler.add("+8% health", pos2, new Point(-vx, vy - 6), 8000, 4902913, 20, true);
				});
			TweenMax.delayedCall(4.5, function():void
				{
					soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
					textHandler.add("+8% damage", pos3, new Point(0, vy - 12), 8000, 16729156, 20, true);
				});
			TweenMax.delayedCall(5.5, function():void
				{
					soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
					textHandler.add("+1% shield regen", pos3, new Point(0, vy - 12), 8000, 98768, 20, true);
				});
		}

		public function createMissionCompleteText():void
		{
			var _loc1_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 100);
			missionCompleteText = textHandler.add("Reward claimed!", _loc1_, new Point(0, 0), 8000, 14211288, 40, true);
			missionCompleteText.alpha = 0;
			missionCompleteText.scaleX = 30;
			missionCompleteText.scaleY = 30;
			TweenMax.to(missionCompleteText, 0.7, {
						"alpha": 1,
						"scaleX": 1,
						"scaleY": 1,
						"onComplete": missionCompleteTextStep2,
						"ease": Circ.easeIn
					});
		}

		public function createBossSpawnedText(param1:String):void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 - 150);
			bossSpawnedText = textHandler.add(param1, _loc2_, new Point(0, 0), 8000, 12787744, 40, true);
			bossSpawnedText.alpha = 0;
			TweenMax.to(bossSpawnedText, 3, {
						"alpha": 1,
						"onComplete": bossSpawnedTextStep2,
						"ease": Circ.easeIn
					});
		}

		private function bossSpawnedTextStep2():void
		{
			TweenMax.delayedCall(1.2, function():void
				{
					bossSpawnedText.speed = new Point(0, -20);
				});
		}

		public function createUberRankCompleteText(param1:String):void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 - 50);
			uberRankCompleteText = textHandler.add(param1, _loc2_, new Point(0, 0), 8000, 4521796, 50, true);
			uberRankCompleteText.alpha = 0;
			TweenMax.to(uberRankCompleteText, 3, {
						"alpha": 1,
						"onComplete": uberRankCompleteTextStep2,
						"ease": Circ.easeIn
					});
		}

		private function uberRankCompleteTextStep2():void
		{
			TweenMax.delayedCall(1.2, function():void
				{
					uberRankCompleteText.speed = new Point(0, -20);
				});
		}

		public function createUberExtraLifeText(param1:String):void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 - 50);
			uberRankExtraLifeText = textHandler.add(param1, _loc2_, new Point(0, 0), 6000, 8978312, 40, true);
			uberRankExtraLifeText.alpha = 0;
			TweenMax.to(uberRankExtraLifeText, 3, {
						"alpha": 1,
						"onComplete": uberExtraLifeTextStep2,
						"ease": Circ.easeIn
					});
		}

		private function uberExtraLifeTextStep2():void
		{
			TweenMax.delayedCall(1.2, function():void
				{
					uberRankExtraLifeText.speed = new Point(0, -30);
				});
		}

		public function createUberTaskText(param1:String):void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 - 100);
			uberTaskText = textHandler.add(param1, _loc2_, new Point(0, 0), 5000, 16777096, 30, true);
			uberTaskText.alpha = 0;
			TweenMax.to(uberTaskText, 3, {
						"alpha": 1,
						"onComplete": uberTaskTextStep2,
						"ease": Circ.easeIn
					});
		}

		private function uberTaskTextStep2():void
		{
			TweenMax.delayedCall(1.2, function():void
				{
					uberTaskText.speed = new Point(0, -30);
				});
		}

		private function missionCompleteTextStep2():void
		{
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			TweenMax.delayedCall(1.2, function():void
				{
					missionCompleteText.speed = new Point(0, -20);
				});
		}

		public function createMissionUpdateText(param1:int, param2:int):void
		{
			var count:int = param1;
			var amount:int = param2;
			if (amount == 0)
			{
				return;
			}
			TweenMax.delayedCall(0.5, function():void
				{
					if (latestMissionUpdateText != null)
					{
						latestMissionUpdateText.alive = false;
					}
					var _loc1_:Point = new Point(g.stage.stageWidth - 15, g.hud.missionsButton.y - 20);
					SoundLocator.getService().play("W6_dF1iXYUCWWSU57BhU1Q");
					latestMissionUpdateText = textHandler.add("" + count + " of " + amount, _loc1_, new Point(0, -10), 5000, 14211288, 13, true, "right");
				});
		}

		public function createMissionFinishedText():void
		{
			SoundLocator.getService().preCacheSound("0CELPmI080ujs_ZTFg8iyA");
			TweenMax.delayedCall(1.5, function():void
				{
					var _loc1_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 200);
					textHandler.add("Mission complete!", _loc1_, new Point(0, -10), 7000, 4902913, 20, true);
					SoundLocator.getService().play("0CELPmI080ujs_ZTFg8iyA");
				});
		}

		public function createMissionBestTimeText():void
		{
			SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			TweenMax.delayedCall(4, function():void
				{
					var _loc1_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 200);
					textHandler.add("New time record!", _loc1_, new Point(0, -9), 7000, 14340097, 12, true);
					SoundLocator.getService().play("0CELPmI080ujs_ZTFg8iyA");
				});
		}

		public function createNewMissionArrivedText():void
		{
			if (isPlayingNewMissionArrived)
			{
				return;
			}
			isPlayingNewMissionArrived = true;
			SoundLocator.getService().preCacheSound("6_sJLdnMgEKbvAjTspuOMg", function():void
				{
					SoundLocator.getService().play("6_sJLdnMgEKbvAjTspuOMg");
					TweenMax.delayedCall(2, function():void
						{
							var _loc2_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 200);
							var _loc1_:Number = -20;
							textHandler.add("Incoming mission...", _loc2_, new Point(0, _loc1_), 7000, 16776205, 20, true);
							isPlayingNewMissionArrived = false;
						});
				});
		}

		public function createDailyUpdate(param1:String):void
		{
			var text:String = param1;
			TweenMax.delayedCall(0.5, function():void
				{
					if (latestMissionUpdateText != null)
					{
						latestMissionUpdateText.alive = false;
					}
					SoundLocator.getService().play("W6_dF1iXYUCWWSU57BhU1Q");
					var _loc1_:Point = new Point(g.stage.stageWidth + 15, g.hud.missionsButton.y - 38);
					latestMissionUpdateText = textHandler.add(text, _loc1_, new Point(0, -10), 5000, 11061482, 13, true, "right");
				});
		}

		public function createKillText(param1:String, param2:Number = 15, param3:int = 5000, param4:uint = 11184810):void
		{
			var _loc6_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 - 100);
			var _loc5_:Number = -20;
			textHandler.add(param1, _loc6_, new Point(0, _loc5_), param3, param4, param2, true);
		}

		public function createDropText(param1:String, param2:int = 1, param3:Number = 15, param4:int = 5000, param5:uint = 11184810, param6:int = 0):void
		{
			var _loc9_:int = 0;
			var _loc14_:int = 0;
			var _loc11_:Number = NaN;
			var _loc10_:Point = null;
			var _loc8_:TextParticle = null;
			var _loc13_:Player = g.me;
			var _loc12_:TextParticle = null;
			var _loc7_:* = null;
			_loc9_ = _loc13_.pickUpLog.length - 1;
			while (_loc9_ > -1)
			{
				_loc12_ = _loc13_.pickUpLog[_loc9_];
				if (_loc12_.ttl <= 0)
				{
					_loc13_.pickUpLog.splice(_loc9_, 1);
				}
				else if (contains(_loc12_.text, param1))
				{
					_loc7_ = _loc12_;
					break;
				}
				_loc9_--;
			}
			if (_loc7_ != null)
			{
				_loc14_ = getQuantity(_loc7_.text) + param2;
				_loc7_.text = param1 + " x" + _loc14_;
				_loc7_.ttl = param4;
				_loc7_.alpha = 1;
			}
			else
			{
				_loc11_ = -10;
				_loc10_ = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 175 + _loc13_.pickUpLog.length * 15 - param6);
				_loc8_ = textHandler.add(param1 + " x" + param2, _loc10_, new Point(0, _loc11_), param4, param5, param3, true);
				_loc13_.pickUpLog.push(_loc8_);
			}
		}

		private function contains(param1:String, param2:String):Boolean
		{
			var _loc3_:int = 0;
			while (_loc3_ < param2.length)
			{
				if (param1.charAt(_loc3_) != param2.charAt(_loc3_))
				{
					return false;
				}
				_loc3_++;
			}
			return true;
		}

		private function getQuantity(param1:String):int
		{
			var _loc2_:Array = param1.split(" x");
			return int(_loc2_[1]);
		}

		public function createMapEntryText():void
		{
			var _loc2_:Point = new Point(g.stage.stageWidth / 2, g.stage.stageHeight / 2 + 200);
			var _loc1_:Number = -5;
			textHandler.add("New map entry updated, press [TAB]", _loc2_, new Point(0, _loc1_), 5000, 3407667, 16, true);
		}

		public function createReputationText(param1:int, param2:Unit):void
		{
			if (param2 == null)
			{
				return;
			}
			var _loc4_:Number = 5;
			var _loc3_:Number = -30;
			var _loc5_:Point = new Point(param2.pos.x, param2.pos.y);
			_loc5_.y = _loc5_.y - 15;
			if (param1 > 0)
			{
				textHandler.add("+" + param1.toString() + " police reputation", _loc5_, new Point(_loc4_, _loc3_), 3000, 3103982, 15, true);
			}
			else
			{
				textHandler.add("+" + (-param1).toString() + " pirate reputation", _loc5_, new Point(_loc4_, _loc3_), 3000, 11690209, 15, true);
			}
		}

		public function dispose():void
		{
			textHandler.dispose();
		}
	}
}
