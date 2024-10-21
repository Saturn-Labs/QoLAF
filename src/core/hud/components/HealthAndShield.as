package core.hud.components
{
	import com.greensock.TweenMax;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.Ship;
	import generics.Localize;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class HealthAndShield extends DisplayObjectContainer
	{
		private static const HP_WIDTH:Number = 120;
		
		private static const SHIELD_WIDTH:Number = 120;
		
		private var playerHPBar:Image;
		
		private var colorGreen:uint;
		
		private var colorYellow:uint;
		
		private var colorRed:uint;
		
		private var playerHPText:TextField;
		
		private var playerHP:Image;
		
		private var playerHPBarBgr:Image;
		
		private var playerHPBarBgrGreen:Texture;
		
		private var playerHPBarBgrYellow:Texture;
		
		private var playerHPBarBgrRed:Texture;
		
		private var playerShieldBar:Image;
		
		private var playerShieldBarBgr:Image;
		
		private var colorBlue:uint;
		
		private var playerShieldText:TextField;
		
		private var playerShield:Image;
		
		private var textureManager:ITextureManager;
		
		private var toolTip:ToolTip;
		
		private var g:Game;
		
		private var warningOverlay:Quad;
		
		private var inLowHp:Boolean = false;
		
		private var lowHpTween:TweenMax = null;
		
		private var oldTotal:Number = 0;
		
		public function HealthAndShield(param1:Game)
		{
			warningOverlay = new Quad(1, 1);
			super();
			this.g = param1;
			textureManager = TextureLocator.getService();
		}
		
		public function load():void
		{
			warningOverlay.color = 16711680;
			warningOverlay.blendMode = "add";
			warningOverlay.width = g.stage.stageWidth;
			warningOverlay.height = g.stage.stageHeight;
			warningOverlay.alpha = 0;
			warningOverlay.touchable = false;
			colorGreen = 5635925;
			colorYellow = 16777045;
			colorRed = 16733491;
			playerHPBar = new Image(textureManager.getTextureGUIByTextureName("health_bar_white.png"));
			playerHPBar.color = colorGreen;
			playerHPBarBgrGreen = textureManager.getTextureGUIByTextureName("health_bar_green.png");
			playerHPBarBgr = new Image(playerHPBarBgrGreen);
			playerHPBarBgrYellow = textureManager.getTextureGUIByTextureName("health_bar_yellow.png");
			playerHPBarBgrRed = textureManager.getTextureGUIByTextureName("health_bar_red.png");
			playerShieldBar = new Image(textureManager.getTextureGUIByTextureName("health_bar_white.png"));
			playerShieldBar.color = 3373055;
			playerShieldBarBgr = new Image(textureManager.getTextureGUIByTextureName("shield_bar.png"));
			playerHPText = new TextField(60, 15, "", new TextFormat("font13", 12, 0, "right"));
			playerHPText.batchable = true;
			playerHPText.touchable = false;
			playerHP = new Image(textureManager.getTextureGUIByTextureName("text_health"));
			playerShieldText = new TextField(60, 15, "", new TextFormat("font13", 12, 12113919, "right"));
			playerShieldText.batchable = true;
			playerShieldText.touchable = false;
			playerShield = new Image(textureManager.getTextureGUIByTextureName("text_shield"));
			playerShield.color = 12113919;
			playerHPBar.y = 18;
			playerHPBar.x = 2;
			playerHPBarBgr.y = 16;
			playerHPBarBgr.x = 0;
			playerHPText.y = 16;
			playerHP.y = 20;
			playerHP.x = 6;
			playerShieldBar.y = 2;
			playerShieldBar.x = 2;
			playerShieldBarBgr.y = 0;
			playerShieldBarBgr.x = 0;
			playerShieldText.y = 0;
			playerShield.y = 4;
			playerShield.x = 6;
			playerHPBar.x = 2;
			playerShieldBar.x = 2;
			playerHPText.x = 59;
			playerShieldText.x = 59;
			addChild(playerHPBarBgr);
			addChild(playerShieldBarBgr);
			addChild(playerHPBar);
			addChild(playerShieldBar);
			addChild(playerHP);
			addChild(playerShield);
			addChild(playerHPText);
			addChild(playerShieldText);
			toolTip = new ToolTip(g, this, "", null, "shieldAndHealth");
			g.addResizeListener(resize);
		}
		
		public function update():void
		{
			var _loc5_:Player = g.me;
			var _loc3_:Ship = _loc5_.ship;
			if (_loc3_ == null)
			{
				return;
			}
			var _loc1_:Number = _loc3_.hp + _loc3_.shieldHp + _loc3_.armorThreshold + _loc3_.shieldRegen + _loc3_.hpMax + _loc3_.shieldHpMax;
			if (oldTotal == _loc1_)
			{
				return;
			}
			oldTotal = _loc1_;
			if (_loc3_.hp / _loc3_.hpMax < 0.25)
			{
				playerHPBarBgr.texture = playerHPBarBgrRed;
				playerHPBar.color = colorRed;
				playerHPText.format.color = 16755336;
				playerHP.color = 16755336;
			}
			else if (_loc3_.hp / _loc3_.hpMax >= 0.75)
			{
				playerHPBarBgr.texture = playerHPBarBgrGreen;
				playerHPBar.color = colorGreen;
				playerHPText.format.color = 2311696;
				playerHP.color = 2311696;
			}
			else
			{
				playerHPBarBgr.texture = playerHPBarBgrYellow;
				playerHPBar.color = colorYellow;
				playerHPText.format.color = 3355408;
				playerHP.color = 3355408;
			}
			if ((_loc3_.hp + _loc3_.shieldHp) / (_loc3_.hpMax + _loc3_.shieldHpMax) <= 0.25)
			{
				startLowHpWarningEffect();
			}
			else if (inLowHp)
			{
				stopLowHPWarningEffect();
			}
			var _loc6_:Number = 120 * _loc3_.hp / _loc3_.hpMax;
			if (_loc6_ < 0)
			{
				_loc6_ = 0;
			}
			if (_loc6_ > 120)
			{
				_loc6_ = 120;
			}
			playerHPBar.width = _loc6_;
			playerHPText.text = _loc3_.hp > 0 ? _loc3_.hp.toString() : "0";
			var _loc4_:Number = 120 * _loc3_.shieldHp / _loc3_.shieldHpMax;
			if (_loc4_ < 0)
			{
				_loc4_ = 0;
			}
			if (_loc4_ > 120)
			{
				_loc4_ = 120;
			}
			playerShieldBar.width = _loc4_;
			playerShieldText.text = _loc3_.shieldHp > 0 ? _loc3_.shieldHp.toString() : "0";
			var _loc2_:String = "<FONT COLOR='#8888ff'>Shield regen:</FONT> <FONT COLOR='#ffffff'>[regen]</FONT>\n";
			_loc2_ += "Shield is good against high impact damage, if the shield holds it will reduce damage by <FONT COLOR='#ffffff'>[shieldReduction]%</FONT>.\n\n";
			_loc2_ += "<FONT COLOR='#44ff44'>Armor:</FONT> <FONT COLOR='#ffffff'>[armor]</FONT>\n";
			_loc2_ += "Armor is good against rapid fire and low impact damage, the damage will be reduced by the amount of armor (max <FONT COLOR='#ffffff'>[armorCapPvP]%</FONT> of damage in PvP and <FONT COLOR='#ffffff'>[armorCapPvE]%</FONT> in PvE).\n";
			toolTip.text = Localize.t(_loc2_).replace("[regen]", (1.75 * (_loc3_.shieldRegen + _loc3_.shieldRegenBonus)).toFixed(0)).replace("[armor]", _loc3_.armorThreshold).replace("[shieldReduction]", 35).replace("[armorCapPvP]", 75).replace("[armorCapPvE]", 90);
		}
		
		public function startLowHpWarningEffect():void
		{
			if (inLowHp)
			{
				return;
			}
			inLowHp = true;
			if (lowHpTween != null)
			{
				lowHpTween.kill();
				lowHpTween = null;
			}
			g.addChildToOverlay(warningOverlay);
			lowHpTween = TweenMax.fromTo(warningOverlay, 1, {"alpha": warningOverlay.alpha}, {"alpha": 0.2, "onComplete": function():void
			{
				lowHpTween = TweenMax.fromTo(warningOverlay, 1, {"alpha": 0.2}, {"alpha": 0.3, "yoyo": true, "repeat": -1});
			}});
		}
		
		public function stopLowHPWarningEffect():void
		{
			inLowHp = false;
			if (lowHpTween != null)
			{
				lowHpTween.kill();
				lowHpTween = null;
			}
			lowHpTween = TweenMax.fromTo(warningOverlay, 1, {"alpha": warningOverlay.alpha}, {"alpha": 0, "onComplete": function():void
			{
				g.removeChildFromOverlay(warningOverlay);
				lowHpTween.kill();
				lowHpTween = null;
			}});
			lowHpTween.resume();
		}
		
		private function resize(param1:Event = null):void
		{
			warningOverlay.width = g.stage.stageWidth;
			warningOverlay.height = g.stage.stageHeight;
		}
	}
}
