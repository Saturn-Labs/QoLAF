package core.hud.components {
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
	
	public class HealthAndShield extends DisplayObjectContainer {
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
		
		private var warningOverlay:Quad = new Quad(1,1);
		
		private var inLowHp:Boolean = false;
		
		private var lowHpTween:TweenMax = null;
		
		private var oldTotal:Number = 0;
		
		public function HealthAndShield(g:Game) {
			super();
			this.g = g;
			textureManager = TextureLocator.getService();
		}
		
		public function load() : void {
			warningOverlay.color = 0xff0000;
			warningOverlay.blendMode = "add";
			warningOverlay.width = g.stage.stageWidth;
			warningOverlay.height = g.stage.stageHeight;
			warningOverlay.alpha = 0;
			warningOverlay.touchable = false;
			colorGreen = 0x55ff55;
			colorYellow = 0xffff55;
			colorRed = 0xff5533;
			playerHPBar = new Image(textureManager.getTextureGUIByTextureName("health_bar_white.png"));
			playerHPBar.color = colorGreen;
			playerHPBarBgrGreen = textureManager.getTextureGUIByTextureName("health_bar_green.png");
			playerHPBarBgr = new Image(playerHPBarBgrGreen);
			playerHPBarBgrYellow = textureManager.getTextureGUIByTextureName("health_bar_yellow.png");
			playerHPBarBgrRed = textureManager.getTextureGUIByTextureName("health_bar_red.png");
			playerShieldBar = new Image(textureManager.getTextureGUIByTextureName("health_bar_white.png"));
			playerShieldBar.color = 0x3377ff;
			playerShieldBarBgr = new Image(textureManager.getTextureGUIByTextureName("shield_bar.png"));
			playerHPText = new TextField(60,15,"",new TextFormat("font13",12,0,"right"));
			playerHPText.batchable = true;
			playerHPText.touchable = false;
			playerHP = new Image(textureManager.getTextureGUIByTextureName("text_health"));
			playerShieldText = new TextField(60,15,"",new TextFormat("font13",12,12113919,"right"));
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
			toolTip = new ToolTip(g,this,"",null,"shieldAndHealth");
			g.addResizeListener(resize);
		}
		
		public function update() : void {
			var _local1:Player = g.me;
			var _local3:Ship = _local1.ship;
			if(_local3 == null) {
				return;
			}
			var _local2:Number = _local3.hp + _local3.shieldHp + _local3.armorThreshold + _local3.shieldRegen + _local3.hpMax + _local3.shieldHpMax;
			if(oldTotal == _local2) {
				return;
			}
			oldTotal = _local2;
			if(_local3.hp / _local3.hpMax < 0.25) {
				playerHPBarBgr.texture = playerHPBarBgrRed;
				playerHPBar.color = colorRed;
				playerHPText.format.color = 0xffaa88;
				playerHP.color = 0xffaa88;
			} else if(_local3.hp / _local3.hpMax >= 0.75) {
				playerHPBarBgr.texture = playerHPBarBgrGreen;
				playerHPBar.color = colorGreen;
				playerHPText.format.color = 2311696;
				playerHP.color = 2311696;
			} else {
				playerHPBarBgr.texture = playerHPBarBgrYellow;
				playerHPBar.color = colorYellow;
				playerHPText.format.color = 3355408;
				playerHP.color = 3355408;
			}
			if((_local3.hp + _local3.shieldHp) / (_local3.hpMax + _local3.shieldHpMax) <= 0.25) {
				startLowHpWarningEffect();
			} else if(inLowHp) {
				stopLowHPWarningEffect();
			}
			var _local6:Number = 2 * 60 * _local3.hp / _local3.hpMax;
			if(_local6 < 0) {
				_local6 = 0;
			}
			if(_local6 > 2 * 60) {
				_local6 = 120;
			}
			playerHPBar.width = _local6;
			playerHPText.text = _local3.hp > 0 ? _local3.hp.toString() : "0";
			var _local4:Number = 2 * 60 * _local3.shieldHp / _local3.shieldHpMax;
			if(_local4 < 0) {
				_local4 = 0;
			}
			if(_local4 > 2 * 60) {
				_local4 = 120;
			}
			playerShieldBar.width = _local4;
			playerShieldText.text = _local3.shieldHp > 0 ? _local3.shieldHp.toString() : "0";
			var _local5:String = "<FONT COLOR=\'#8888ff\'>Shield regen:</FONT> <FONT COLOR=\'#ffffff\'>[regen]</FONT>\n";
			_local5 = _local5 + "Shield is good against high impact damage, if the shield holds it will reduce damage by <FONT COLOR=\'#ffffff\'>[shieldReduction]%</FONT>.\n\n";
			_local5 = _local5 + "<FONT COLOR=\'#44ff44\'>Armor:</FONT> <FONT COLOR=\'#ffffff\'>[armor]</FONT>\n";
			_local5 = _local5 + "Armor is good against rapid fire and low impact damage, the damage will be reduced by the amount of armor (max <FONT COLOR=\'#ffffff\'>[armorCapPvP]%</FONT> of damage in PvP and <FONT COLOR=\'#ffffff\'>[armorCapPvE]%</FONT> in PvE).\n";
			toolTip.text = Localize.t(_local5).replace("[regen]",(1.75 * (_local3.shieldRegen + _local3.shieldRegenBonus)).toFixed(0)).replace("[armor]",_local3.armorThreshold).replace("[shieldReduction]",35).replace("[armorCapPvP]",75).replace("[armorCapPvE]",90);
		}
		
		public function startLowHpWarningEffect() : void {
			if(inLowHp) {
				return;
			}
			inLowHp = true;
			if(lowHpTween != null) {
				lowHpTween.kill();
				lowHpTween = null;
			}
			g.addChildToOverlay(warningOverlay);
			lowHpTween = TweenMax.fromTo(warningOverlay,1,{"alpha":warningOverlay.alpha},{
				"alpha":0.2,
				"onComplete":function():void {
					lowHpTween = TweenMax.fromTo(warningOverlay,1,{"alpha":0.2},{
						"alpha":0.3,
						"yoyo":true,
						"repeat":-1
					});
				}
			});
		}
		
		public function stopLowHPWarningEffect() : void {
			inLowHp = false;
			if(lowHpTween != null) {
				lowHpTween.kill();
				lowHpTween = null;
			}
			lowHpTween = TweenMax.fromTo(warningOverlay,1,{"alpha":warningOverlay.alpha},{
				"alpha":0,
				"onComplete":function():void {
					g.removeChildFromOverlay(warningOverlay);
					lowHpTween.kill();
					lowHpTween = null;
				}
			});
			lowHpTween.resume();
		}
		
		private function resize(e:Event = null) : void {
			warningOverlay.width = g.stage.stageWidth;
			warningOverlay.height = g.stage.stageHeight;
		}
	}
}

