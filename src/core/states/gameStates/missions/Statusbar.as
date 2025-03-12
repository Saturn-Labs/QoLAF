package core.states.gameStates.missions
{
	import com.greensock.TweenMax;
	import core.scene.Game;
	import generics.Util;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.TouchEvent;
	import starling.filters.GlowFilter;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class Statusbar extends Sprite
	{
		private var label:TextField;
		
		private var g:Game;
		
		private var daily:Daily;
		
		private var bg:Image;
		
		private var front:Image;
		
		public function Statusbar(param1:Game, param2:Daily)
		{
			var _loc4_:ISound = null;
			super();
			this.g = param1;
			this.daily = param2;
			var _loc3_:String = "";
			if (param2.level > param1.me.level)
			{
				bg = new Image(param1.textureManager.getTextureGUIByTextureName("daily_ongoing_bg"));
				_loc3_ = "Unlocks at level " + param2.level;
			}
			else if (param2.status == 0)
			{
				bg = new Image(param1.textureManager.getTextureGUIByTextureName("daily_ongoing_bg"));
				front = new Image(param1.textureManager.getTextureGUIByTextureName("daily_ongoing_front"));
			}
			else if (param2.status == 1)
			{
				bg = new Image(param1.textureManager.getTextureGUIByTextureName("daily_completed"));
				_loc3_ = "Complete - Click to collect reward!";
				bg.addEventListener("touch", onClaim);
				bg.useHandCursor = true;
				_loc4_ = SoundLocator.getService();
				_loc4_.preCacheSound("daily_claim");
				_loc4_.preCacheSound("daily_reward");
			}
			else
			{
				bg = new Image(param1.textureManager.getTextureGUIByTextureName("daily_waiting"));
				addEventListener("enterFrame", update);
			}
			addChild(bg);
			if (front)
			{
				addChild(front);
			}
			label = new TextField(this.width, this.height, _loc3_, new TextFormat("Verdana", 11, 16777215));
			label.touchable = false;
			addChild(label);
			setRatio();
		}
		
		private function setRatio():void
		{
			if (!front)
			{
				return;
			}
			var _loc2_:Number = daily.progress / daily.missionGoal;
			var _loc1_:Number = Math.max(0, Math.min(1, _loc2_));
			front.scaleX = _loc1_;
			front.setTexCoords(1, _loc1_, 0);
			front.setTexCoords(3, _loc1_, 1);
			label.text = Math.floor(_loc1_ * 100).toFixed().toString() + "% complete";
		}
		
		private function onClaim(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "ended"))
			{
				label.text = "waiting ...";
				bg.removeEventListener("touch", onClaim);
				daily.status = 2;
				g.rpc("dailyMissionClaim", onClaimResponse, daily.key);
			}
		}
		
		private function onClaimResponse(param1:Message):void
		{
			var soundManager:ISound;
			var m:Message = param1;
			g.dailyManager.addReward(m);
			Game.trackEvent("missions", "daily", daily.name, g.me.level);
			dispatchEventWith("dailyMissionClaiming");
			bg.filter = new GlowFilter();
			soundManager = SoundLocator.getService();
			soundManager.play("daily_claim");
			TweenMax.to(bg.filter, 0.3, {"repeat": 5, "yoyo": true, "blur": 15, "onCompleteListener": function():void
			{
				var reward:DailyReward;
				var xpos:int;
				removeChild(label);
				bg.filter.dispose();
				bg.filter = null;
				TweenMax.to(bg, 0.8, {"width": 0, "onCompleteListener": function():void
				{
					removeChild(bg);
					dispatchEventWith("dailyMissionClaimed");
					soundManager.stop("daily_claim");
					soundManager.play("daily_reward");
				}});
				reward = new DailyReward(g, daily);
				addChild(reward);
				reward.x = width;
				xpos = width / 2 - reward.width;
				TweenMax.to(reward, 0.8, {"x": xpos});
			}});
		}
		
		public function update(param1:EnterFrameEvent):void
		{
			if (daily.status != 2)
			{
				return;
			}
			var _loc2_:Number = g.dailyManager.resetTime - g.time;
			if (_loc2_ <= 0)
			{
				daily.status = 0;
				daily.progress = 0;
				removeEventListener("enterFrame", update);
				dispatchEventWith("dailyMissionReset");
			}
			else
			{
				label.text = "Available again in " + Util.getFormattedTime(_loc2_);
			}
		}
		
		override public function dispose():void
		{
			bg.removeEventListeners();
			removeEventListener("enterFrame", update);
			super.dispose();
		}
	}
}
