package core.hud.components.pvp
{
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.Text;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	
	public class PvpScoreScreen extends PvpScreen
	{
		private var leaveButton:Button;
		
		private var addedItems:Vector.<PvpScoreHolder>;
		
		private var scrollArea:ScrollContainer;
		
		private var mainBody:Sprite;
		
		private var infoBox:Box;
		
		private var rewardBox:Box;
		
		private var contentBody:Sprite;
		
		public function PvpScoreScreen(param1:Game)
		{
			super(param1);
		}
		
		override public function load():void
		{
			super.load();
			if (g.pvpManager != null)
			{
				g.pvpManager.scoreListUpdated = true;
			}
			leaveButton = new Button(showConfirmDialog, Localize.t("Leave Match"), "negative");
			leaveButton.x = 560;
			leaveButton.y = 520;
			addChild(leaveButton);
		}
		
		private function leaveMatch():void
		{
			g.send("leavePvpMatch");
		}
		
		private function showConfirmDialog(param1:TouchEvent):void
		{
			var _loc2_:String = null;
			if (g.pvpManager.matchEnded == false)
			{
				_loc2_ = "Are you sure you want to leave? You will lose rating as if you lost the match!";
				g.showConfirmDialog(_loc2_, leaveMatch);
			}
			else
			{
				leaveMatch();
			}
		}
		
		override public function unload():void
		{
			for each (var _loc1_:* in addedItems)
			{
				if (mainBody.contains(_loc1_.img))
				{
					mainBody.removeChild(_loc1_.img);
				}
			}
			addedItems = new Vector.<PvpScoreHolder>();
		}
		
		override public function update():void
		{
			var _loc6_:* = undefined;
			if (!g.pvpManager.scoreListUpdated)
			{
				return;
			}
			g.pvpManager.scoreListUpdated = false;
			if (contentBody != null && contains(contentBody))
			{
				removeChild(contentBody);
			}
			addedItems = new Vector.<PvpScoreHolder>();
			contentBody = new Sprite();
			mainBody = new Sprite();
			addChild(contentBody);
			var _loc7_:int = 70;
			var _loc5_:int = 0;
			if (g.pvpManager != null && g.pvpManager.matchEnded)
			{
				addInfoBox(_loc7_, _loc5_);
				addRewardBox(_loc7_, _loc5_);
				_loc5_ = 220;
			}
			else
			{
				_loc5_ = 40;
			}
			var _loc1_:Text = new Text();
			if (g.solarSystem.type == "pvp dom")
			{
				_loc1_.text = Localize.t("Team");
			}
			else
			{
				_loc1_.text = Localize.t("Rank");
			}
			_loc1_.x = _loc7_;
			_loc1_.y = _loc5_;
			_loc1_.color = 5635925;
			_loc1_.size = 12;
			contentBody.addChild(_loc1_);
			_loc7_ += 60;
			_loc1_ = new Text();
			_loc1_.text = Localize.t("Name");
			_loc1_.x = _loc7_;
			_loc1_.y = _loc5_;
			_loc1_.color = 5635925;
			_loc1_.size = 12;
			contentBody.addChild(_loc1_);
			_loc7_ += 160;
			if (g.solarSystem.type == "pvp dom")
			{
				_loc7_ -= 20;
				_loc1_ = new Text();
				_loc1_.text = Localize.t("Score");
				_loc1_.x = _loc7_;
				_loc1_.y = _loc5_;
				_loc1_.color = 5635925;
				_loc1_.size = 12;
				contentBody.addChild(_loc1_);
				_loc7_ += 50;
				_loc1_ = new Text();
				_loc1_.text = Localize.t("Kills");
				_loc1_.x = _loc7_;
				_loc1_.y = _loc5_;
				_loc1_.color = 5635925;
				_loc1_.size = 12;
				contentBody.addChild(_loc1_);
				_loc7_ += 50;
			}
			else
			{
				_loc1_ = new Text();
				_loc1_.text = Localize.t("Kills");
				_loc1_.x = _loc7_;
				_loc1_.y = _loc5_;
				_loc1_.color = 5635925;
				_loc1_.size = 12;
				contentBody.addChild(_loc1_);
				_loc7_ += 50;
			}
			_loc1_ = new Text();
			_loc1_.text = Localize.t("Deaths");
			_loc1_.x = _loc7_;
			_loc1_.y = _loc5_;
			_loc1_.color = 5635925;
			_loc1_.size = 12;
			contentBody.addChild(_loc1_);
			if (g.solarSystem.type == "pvp dom")
			{
				_loc7_ += 50;
			}
			else
			{
				_loc7_ += 70;
			}
			_loc1_ = new Text();
			_loc1_.text = Localize.t("Damage");
			_loc1_.x = _loc7_;
			_loc1_.y = _loc5_;
			_loc1_.color = 5635925;
			_loc1_.size = 12;
			contentBody.addChild(_loc1_);
			_loc7_ += 80;
			_loc1_ = new Text();
			_loc1_.text = Localize.t("Reward Bonus");
			_loc1_.x = _loc7_;
			_loc1_.y = _loc5_;
			_loc1_.color = 5592575;
			_loc1_.size = 12;
			contentBody.addChild(_loc1_);
			_loc7_ += 110;
			_loc1_ = new Text();
			_loc1_.text = Localize.t("Rating");
			_loc1_.x = _loc7_;
			_loc1_.y = _loc5_;
			_loc1_.color = 5592575;
			_loc1_.size = 12;
			contentBody.addChild(_loc1_);
			_loc7_ += 60;
			_loc5_ += 30;
			scrollArea = new ScrollContainer();
			scrollArea.y = _loc5_;
			scrollArea.x = 4;
			scrollArea.width = 700;
			if (g.pvpManager != null && g.pvpManager.matchEnded)
			{
				scrollArea.height = 250;
			}
			else
			{
				scrollArea.height = 430;
			}
			_loc6_ = g.pvpManager.getScoreList();
			if (_loc6_ == null || _loc6_.length == 0)
			{
				return;
			}
			_loc5_ = 10;
			var _loc4_:Boolean = false;
			var _loc3_:Boolean = false;
			if (g.pvpManager is DominationManager)
			{
				_loc4_ = true;
			}
			for each (var _loc2_:* in _loc6_)
			{
				_loc2_.load();
				_loc2_.img.x = 60;
				_loc2_.img.y = _loc5_;
				if (_loc4_)
				{
					if (g.me.team == _loc2_.team)
					{
						_loc3_ = true;
					}
					else
					{
						_loc3_ = false;
					}
				}
				_loc2_.update(_loc4_, _loc3_);
				mainBody.addChild(_loc2_.img);
				addedItems.push(_loc2_);
				_loc5_ = _loc5_ + _loc2_.img.height + 5;
			}
			contentBody.addChild(scrollArea);
			scrollArea.addChild(mainBody);
		}
		
		private function addInfoBox(param1:int, param2:int):void
		{
			var _loc4_:PvpScoreHolder = g.pvpManager.getScoreItem(g.me.id);
			if (infoBox != null && contains(infoBox))
			{
				removeChild(infoBox);
			}
			infoBox = new Box(280, 140, "highlight", 0.5, 10);
			infoBox.x = param1 - 10;
			infoBox.y = param2 + 60;
			addChild(infoBox);
			var _loc3_:Text = new Text();
			_loc3_.text = Localize.t("Achievement");
			_loc3_.x = 0;
			_loc3_.y = 0;
			_loc3_.color = 5592575;
			_loc3_.size = 14;
			infoBox.addChild(_loc3_);
			_loc3_ = new Text();
			_loc3_.text = Localize.t("Bonus");
			_loc3_.x = 100;
			_loc3_.y = 0;
			_loc3_.color = 5592575;
			_loc3_.size = 14;
			infoBox.addChild(_loc3_);
			if (_loc4_ == null)
			{
				return;
			}
			var _loc5_:int = 20;
			if (_loc4_.afk == true)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Inactive/Afk") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = "-100%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
				Game.trackEvent("pvp", "afk", g.me.name);
				return;
			}
			if (_loc4_.first > 0)
			{
				_loc3_ = new Text();
				if (g.pvpManager is DominationManager)
				{
					_loc3_.text = Localize.t("Victory") + ":";
				}
				else
				{
					_loc3_.text = Localize.t("First place") + ":";
				}
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.first.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.second > 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Second place") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.second.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.third > 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Third place") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.third.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.hotStreak3 > 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Hot Streak x3") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.hotStreak3.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.hotStreak10 > 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Hot Streak x10") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.hotStreak10.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.noDeaths > 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Undying") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.noDeaths.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.capZone > 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Successful Assult") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.capZone.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.defZone > 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Dedicated Defence") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.defZone.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.brokeKillingSpree > 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Broke a Spree") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.brokeKillingSpree.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.pickups > 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Pickup Bonus") + ":";
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc3_ = new Text();
				_loc3_.text = _loc4_.pickups.toString() + "%";
				_loc3_.x = 220;
				_loc3_.y = _loc5_;
				_loc3_.color = 5592575;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
			if (_loc4_.dailyBonus >= 0)
			{
				_loc3_ = new Text();
				_loc3_.text = Localize.t("Daily Bonus Reward!");
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 3407667;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
				_loc3_ = new Text();
				_loc3_.text = "(" + _loc4_.dailyBonus + Localize.t("x matches left today)");
				_loc3_.x = 5;
				_loc3_.y = _loc5_;
				_loc3_.color = 3407667;
				_loc3_.size = 12;
				infoBox.addChild(_loc3_);
				_loc5_ += 16;
			}
		}
		
		private function addRewardBox(param1:int, param2:int):void
		{
			var _loc7_:Number = NaN;
			var _loc4_:PvpScoreHolder = g.pvpManager.getScoreItem(g.me.id);
			if (rewardBox != null && contains(rewardBox))
			{
				removeChild(rewardBox);
			}
			var _loc8_:Number = 0.5;
			if (g.solarSystem.type == "pvp dm")
			{
				_loc8_ = 2;
			}
			else if (g.solarSystem.type == "pvp dom")
			{
				_loc8_ = 2;
			}
			rewardBox = new Box(280, 140, "highlight", 0.5, 10);
			rewardBox.x = param1 + 320;
			rewardBox.y = param2 + 60;
			addChild(rewardBox);
			var _loc3_:Text = new Text();
			_loc3_.y = 0;
			_loc3_.color = 5592575;
			_loc3_.size = 14;
			if (_loc4_.dailyBonus >= 0)
			{
				_loc3_.x = 10;
				_loc3_.htmlText = Localize.t("Reward <font color='#33ff33'>(Daily Bonus)</font>");
				_loc7_ = 0;
				if (g.solarSystem.type == "pvp dm")
				{
					_loc7_ = 2;
				}
				else if (g.solarSystem.type == "pvp dom")
				{
					_loc7_ = 2;
				}
				else
				{
					_loc7_ = 0.5;
				}
			}
			else
			{
				_loc3_.x = 50;
				_loc3_.htmlText = Localize.t("Reward");
			}
			rewardBox.addChild(_loc3_);
			if (_loc4_ == null)
			{
				return;
			}
			if (_loc4_.afk == true)
			{
				return;
			}
			var _loc6_:int = 20;
			_loc3_ = new Text();
			_loc3_.text = Localize.t("XP") + ":";
			_loc3_.x = 5;
			_loc3_.y = _loc6_;
			_loc3_.color = 5592575;
			_loc3_.size = 12;
			rewardBox.addChild(_loc3_);
			_loc3_ = new Text();
			_loc3_.color = 5592575;
			_loc3_.alignRight();
			_loc3_.x = 285;
			_loc3_.y = _loc6_;
			_loc3_.size = 12;
			var _loc9_:int = Math.ceil(0.01 * _loc4_.bonusPercent * _loc8_ * (32 * g.me.level + 158 + _loc4_.xpSum));
			var _loc5_:int = Math.ceil(0.01 * _loc4_.bonusPercent * _loc7_ * (32 * g.me.level + 158 + _loc4_.xpSum));
			_loc9_ = Math.ceil(_loc9_ * (0.2 + 8 / (10 + (g.me.level - 1))));
			_loc5_ = Math.ceil(_loc5_ * (0.2 + 8 / (10 + (g.me.level - 1))));
			if (g.me.hasExpBoost)
			{
				_loc9_ = Math.ceil(_loc9_ * (1 + 0.3));
				_loc5_ = Math.ceil(_loc5_ * (1 + 0.3));
			}
			if (_loc4_.dailyBonus >= 0)
			{
				_loc3_.htmlText = _loc9_ + " <font color='#33ff33'>(" + _loc5_ + ")</font>";
			}
			else
			{
				_loc3_.htmlText = _loc9_.toString();
			}
			rewardBox.addChild(_loc3_);
			_loc6_ += 16;
			_loc3_ = new Text();
			_loc3_.text = Localize.t("Steel") + ":";
			_loc3_.x = 5;
			_loc3_.y = _loc6_;
			_loc3_.color = 5592575;
			_loc3_.size = 12;
			rewardBox.addChild(_loc3_);
			_loc3_ = new Text();
			_loc3_.color = 5592575;
			_loc3_.alignRight();
			_loc3_.x = 285;
			_loc3_.y = _loc6_;
			_loc3_.size = 12;
			if (_loc4_.dailyBonus >= 0)
			{
				_loc3_.htmlText = int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc8_ * (12 * g.me.level + 138 + _loc4_.steelSum))).toString() + " <font color='#33ff33'>(" + int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc7_ * (12 * g.me.level + 138 + _loc4_.steelSum))) + ")</font>";
			}
			else
			{
				_loc3_.htmlText = int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc8_ * (12 * g.me.level + 138 + _loc4_.steelSum))).toString();
			}
			rewardBox.addChild(_loc3_);
			_loc6_ += 16;
			_loc3_ = new Text();
			_loc3_.text = Localize.t("Hyrdogen Crystals") + ":";
			_loc3_.x = 5;
			_loc3_.y = _loc6_;
			_loc3_.color = 5592575;
			_loc3_.size = 12;
			rewardBox.addChild(_loc3_);
			_loc3_ = new Text();
			_loc3_.color = 5592575;
			_loc3_.alignRight();
			_loc3_.x = 285;
			_loc3_.y = _loc6_;
			_loc3_.size = 12;
			if (_loc4_.dailyBonus >= 0)
			{
				_loc3_.htmlText = int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc8_ * (3 * g.me.level + 52 + _loc4_.hydrogenSum))).toString() + " <font color='#33ff33'>(" + int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc7_ * (3 * g.me.level + 52 + _loc4_.hydrogenSum))) + ")</font>";
			}
			else
			{
				_loc3_.htmlText = int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc8_ * (3 * g.me.level + 52 + _loc4_.hydrogenSum))).toString();
			}
			rewardBox.addChild(_loc3_);
			_loc6_ += 16;
			_loc3_ = new Text();
			_loc3_.text = Localize.t("Plasma Fluid") + ":";
			_loc3_.x = 5;
			_loc3_.y = _loc6_;
			_loc3_.color = 5592575;
			_loc3_.size = 12;
			rewardBox.addChild(_loc3_);
			_loc3_ = new Text();
			_loc3_.color = 5592575;
			_loc3_.alignRight();
			_loc3_.x = 285;
			_loc3_.y = _loc6_;
			_loc3_.size = 12;
			if (_loc4_.dailyBonus >= 0)
			{
				_loc3_.htmlText = int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc8_ * (2.5 * g.me.level + 40 + _loc4_.plasmaSum))).toString() + " <font color='#33ff33'>(" + int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc7_ * (2.5 * g.me.level + 40 + _loc4_.plasmaSum))) + ")</font>";
			}
			else
			{
				_loc3_.htmlText = int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc8_ * (2.5 * g.me.level + 40 + _loc4_.plasmaSum))).toString();
			}
			rewardBox.addChild(_loc3_);
			_loc6_ += 16;
			_loc3_ = new Text();
			_loc3_.text = Localize.t("Iridium") + ":";
			_loc3_.x = 5;
			_loc3_.y = _loc6_;
			_loc3_.color = 5592575;
			_loc3_.size = 12;
			rewardBox.addChild(_loc3_);
			_loc3_ = new Text();
			_loc3_.color = 5592575;
			_loc3_.alignRight();
			_loc3_.x = 285;
			_loc3_.y = _loc6_;
			_loc3_.size = 12;
			if (_loc4_.dailyBonus >= 0)
			{
				_loc3_.htmlText = int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc8_ * (2 * g.me.level + 28 + _loc4_.iridiumSum))).toString() + " <font color='#33ff33'>(" + int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc7_ * (2 * g.me.level + 28 + _loc4_.iridiumSum))) + ")</font>";
			}
			else
			{
				_loc3_.htmlText = int(Math.ceil(0.01 * _loc4_.bonusPercent * _loc8_ * (2 * g.me.level + 28 + _loc4_.iridiumSum))).toString();
			}
			rewardBox.addChild(_loc3_);
			_loc6_ += 16;
		}
	}
}
