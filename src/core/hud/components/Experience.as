package core.hud.components
{
	import com.greensock.TweenMax;
	import core.player.Player;
	import core.scene.Game;
	import generics.Localize;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class Experience extends DisplayObjectContainer
	{
		private var regularXpBarColor:uint = 16777011;
		
		private var boostXpBarColor:uint = 3407667;
		
		private var xpBar:ScaleImage;
		
		private var bgr:ScaleImage;
		
		private var flashBar:ScaleImage;
		
		private var xpText:TextField;
		
		private var g:Game;
		
		private var p:Player;
		
		private var tt:ToolTip;
		
		private var oldXp:int = -1;
		
		private var oldXpBoost:Boolean = false;
		
		private var tw:TweenMax;
		
		public function Experience(param1:Game)
		{
			super();
			this.g = param1;
			xpBar = new ScaleImage();
			xpBar.color = 0;
			xpBar.height = 10;
			bgr = new ScaleImage();
			bgr.color = 0;
			bgr.height = 10;
			flashBar = new ScaleImage();
			bgr.height = 10;
			flashBar.blendMode = "add";
			addEventListener("removedFromStage", clean);
		}
		
		public function load():void
		{
			xpText = new TextField(70, 15, Localize.t("level [level]").replace("[level]", 1), new TextFormat("font13", 10, 13421772));
			xpText.y = -3;
			xpText.batchable = true;
			bgr.x = 0;
			bgr.alpha = 0.8;
			bgr.color = 0;
			xpBar.x = 0;
			xpBar.alpha = 0.8;
			addChild(bgr);
			addChild(xpBar);
			addChild(xpText);
			tt = new ToolTip(g, this, "", null, "experienceBar", 300);
			xpBar.color = regularXpBarColor;
			p = g.playerManager.me;
			resize();
			g.addResizeListener(resize);
		}
		
		public function update():void
		{
			if (!oldXpBoost && g.me.hasExpBoost)
			{
				xpBar.color = boostXpBarColor;
				updateXpText();
			}
			else if (oldXpBoost && !g.me.hasExpBoost)
			{
				xpBar.color = regularXpBarColor;
				updateXpText();
			}
			if (oldXp != p.xp)
			{
				xpText.text = Localize.t("level [level]").replace("[level]", p.level);
				if (p.xp - p.levelXpMin > (p.levelXpMax - p.levelXpMin) / 2)
				{
					xpText.format.color = 0;
				}
				else
				{
					xpText.format.color = 13421772;
				}
				updateXpText();
				flash();
				oldXp = p.xp;
				resize();
			}
			oldXpBoost = g.me.hasExpBoost;
		}
		
		private function updateXpText():void
		{
			tt.text = Localize.t("Experience: <FONT COLOR='#ffffff'>[xp] / [xpMax]</FONT>\nXP Boost: <FONT COLOR='#ffffff'>[xpBoost]</FONT>").replace("[xp]", p.xp).replace("[xpMax]", p.levelXpMax).replace("[xpBoost]", g.me.hasExpBoost.toString());
		}
		
		private function flash():void
		{
			if (tw != null)
			{
				tw.kill();
				addChild(flashBar);
			}
			flashBar.alpha = 1;
			tw = TweenMax.to(flashBar, 3, {"alpha": 0, "onComplete": function():void
			{
				if (contains(flashBar))
				{
					removeChild(flashBar);
				}
			}});
		}
		
		private function clean(param1:Event = null):void
		{
			ToolTip.disposeType("experienceBar");
			removeEventListener("removedFromStage", clean);
		}
		
		private function resize(param1:Event = null):void
		{
			var _loc5_:Number = g.stage.stageWidth;
			var _loc4_:int = p.levelXpMax - p.levelXpMin;
			var _loc3_:int = p.xp - p.levelXpMin;
			var _loc2_:Number = _loc5_ * _loc3_ / _loc4_;
			xpText.x = _loc5_ / 2 - xpText.width / 2;
			xpBar.width = _loc2_;
			bgr.width = _loc5_;
			flashBar.width = _loc5_;
		}
	}
}
