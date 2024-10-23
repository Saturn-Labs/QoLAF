package qolaf.ui 
{
	import core.scene.Game;
	import core.unit.Unit;
	import feathers.controls.Label;
	import generics.Util;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.DisplayObject;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * @author rydev
	 */
	public class TargetInfoElement extends DisplayObjectContainer 
	{
		private static var TARGET_INFO_TEXT_HEIGHT = 20;
		private static var SH_AND_HP_BAR_HEIGHT = 14;
		private static var SH_AND_HP_BAR_WIDTH = 300;
		private static var TRAILS_ALPHA = 0.6;
		
		private var game:Game;
		public var targetName:Label;
		public var shieldBar:Quad;
		public var shieldBarTrail:Quad;
		public var healthBar:Quad;
		public var healthBarTrail:Quad;
		public var lastUnit:Unit = null;
		public var lockIcon:Texture;
		public var unlockIcon:Texture;
		
		public var lockButton:Image;
		
		public var shieldTextAmount:Label;
		public var healthTextAmount:Label;
		
		public var currentShield:Number = 1.0;
		public var lerpShield:Number = 1.0;
		
		public var currentHealth:Number = 1.0;
		public var lerpHealth:Number = 1.0;
		
		public function TargetInfoElement(game:Game) 
		{
			this.game = game;
			width = 370;
			height = 90;
			
			var manager:ITextureManager = TextureLocator.getService();
			lockIcon = manager.getTextureByTextureName("ti_supporter", "texture_gui1_test.png");
			unlockIcon = manager.getTextureByTextureName("ti_supporter_inactive", "texture_gui1_test.png");
			
			lockButton = new Image(unlockIcon);
			lockButton.alignPivot(Align.LEFT, Align.TOP);
			lockButton.scale = 0.5;
			lockButton.x = -(SH_AND_HP_BAR_WIDTH / 2);
			lockButton.touchable = true;
			lockButton.addEventListener(TouchEvent.TOUCH, OnClickLock);
			addChild(lockButton);
			
			targetName = new Label();
			targetName.width = SH_AND_HP_BAR_WIDTH;
			targetName.height = TARGET_INFO_TEXT_HEIGHT;
			targetName.styleName = "target_info";
			targetName.alignPivot(Align.CENTER, Align.TOP);
			targetName.x = targetName.y = 0;
			addChild(targetName);
			
			shieldBar = new Quad(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0x0099ff);
			shieldBar.alignPivot(Align.LEFT, Align.TOP);
			addChild(shieldBar);
			
			shieldBarTrail = new Quad(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0x0099ff);
			shieldBarTrail.alpha = TRAILS_ALPHA;
			shieldBarTrail.alignPivot(Align.LEFT, Align.TOP);
			addChild(shieldBarTrail);
			
			healthBar = new Quad(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0xff0000);
			healthBar.alignPivot(Align.LEFT, Align.TOP);
			addChild(healthBar);
			
			healthBarTrail = new Quad(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0xff0000);
			healthBarTrail.alpha = TRAILS_ALPHA;
			healthBarTrail.alignPivot(Align.LEFT, Align.TOP);
			addChild(healthBarTrail);
			
			shieldTextAmount = new Label();
			shieldTextAmount.width = SH_AND_HP_BAR_WIDTH;
			shieldTextAmount.height = SH_AND_HP_BAR_HEIGHT;
			shieldTextAmount.styleName = "target_info";
			shieldTextAmount.alignPivot(Align.CENTER, Align.CENTER);
			shieldTextAmount.text = "0 / 0";
			addChild(shieldTextAmount);
			
			healthTextAmount = new Label();
			healthTextAmount.width = SH_AND_HP_BAR_WIDTH;
			healthTextAmount.height = SH_AND_HP_BAR_HEIGHT;
			healthTextAmount.styleName = "target_info";
			healthTextAmount.alignPivot(Align.CENTER, Align.CENTER);
			healthTextAmount.text = "0 / 0";
			addChild(healthTextAmount);
		}
		
		public function OnClickLock(event:TouchEvent):void 
		{
			var touch:Touch = event.getTouch(lockButton);
			if (touch == null || touch.phase != TouchPhase.BEGAN || Game.instance.targetSystem == null || !Game.instance.targetSystem.CurrentUnitValid())
				return;
				
			Game.instance.targetSystem.lockedTarget = !Game.instance.targetSystem.lockedTarget;
		}
		
		public function Update():void 
		{
			var unit:Unit = game.targetSystem.GetCurrentUnit();
			x = game.stage.stageWidth / 2.0;
			y = 60;
			if (unit == null)
				return;
			currentShield = (unit.shieldHp / unit.shieldHpMax);
			currentHealth = (unit.hp / unit.hpMax);
			
			if (lastUnit != unit) {
				lerpShield = currentShield;
				lerpHealth = currentHealth;
			}
			lastUnit = unit;
			lockButton.texture = Game.instance.targetSystem.lockedTarget ? lockIcon : unlockIcon;
			
			var hasShield:Boolean = unit.shieldHpMax > 0;
			shieldBar.visible = hasShield;
			shieldBarTrail.visible = hasShield;
			shieldTextAmount.visible = hasShield;
			if (hasShield) {
				shieldBar.x = -(SH_AND_HP_BAR_WIDTH / 2);
				shieldBar.y = TARGET_INFO_TEXT_HEIGHT + 2;
				shieldBarTrail.x = -(SH_AND_HP_BAR_WIDTH / 2);
				shieldBarTrail.y = TARGET_INFO_TEXT_HEIGHT + 2;
				shieldTextAmount.y = shieldBar.y + SH_AND_HP_BAR_HEIGHT / 3;
				healthBar.x = -(SH_AND_HP_BAR_WIDTH / 2);
				healthBar.y = shieldBar.y + SH_AND_HP_BAR_HEIGHT;
				healthBarTrail.x = -(SH_AND_HP_BAR_WIDTH / 2);
				healthBarTrail.y = shieldBar.y + SH_AND_HP_BAR_HEIGHT;
				healthTextAmount.y = healthBar.y + SH_AND_HP_BAR_HEIGHT / 3;
			}
			else {
				healthBar.x = -(SH_AND_HP_BAR_WIDTH / 2);
				healthBar.y = TARGET_INFO_TEXT_HEIGHT + 2;
				healthBarTrail.x = -(SH_AND_HP_BAR_WIDTH / 2);
				healthBarTrail.y = TARGET_INFO_TEXT_HEIGHT + 2;
				healthTextAmount.y = healthBar.y + SH_AND_HP_BAR_HEIGHT / 3;
			}
			
			lerpShield = Util.lerp(lerpShield, currentShield, game.deltaTime * 2);
			lerpHealth = Util.lerp(lerpHealth, currentHealth, game.deltaTime * 2);
			shieldBar.width = SH_AND_HP_BAR_WIDTH * currentShield;
			healthBar.width = SH_AND_HP_BAR_WIDTH * currentHealth;
			shieldBarTrail.width = SH_AND_HP_BAR_WIDTH * lerpShield;
			healthBarTrail.width = SH_AND_HP_BAR_WIDTH * lerpHealth;
			shieldTextAmount.text = Math.floor(unit.shieldHp) + " / " + Math.floor(unit.shieldHpMax);
			healthTextAmount.text = Math.floor(unit.hp) + " / " + Math.floor(unit.hpMax);
		}
	}
}