package qolaf.ui 
{
	import core.scene.Game;
	import core.unit.Unit;
	import feathers.controls.Label;
	import generics.Util;
	import qolaf.debuffs.DebuffEffect;
	import qolaf.pooling.ObjectPool;
	import qolaf.ui.elements.ValueTrailAnimatedSlider;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.filters.GlowFilter;
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
		
		private var game:Game;
		public var targetName:Label;
		public var shieldBar:ValueTrailAnimatedSlider;
		public var healthBar:ValueTrailAnimatedSlider;
		public var lastUnit:Unit = null;
		public var lockIcon:Texture;
		public var unlockIcon:Texture;
		public var lockButton:Image;
		public var effects:Sprite;
		public var objPool:ObjectPool;
		
		public function TargetInfoElement(game:Game) 
		{
			this.game = game;
			width = 370;
			height = 90;
			
			objPool = new ObjectPool(function(): Label {
				return new Label();
			});
			
			var manager:ITextureManager = TextureLocator.getService();
			lockIcon = manager.getTextureByTextureName("ti_cargo_protection", "texture_gui1_test.png");
			unlockIcon = manager.getTextureByTextureName("ti_cargo_protection_inactive", "texture_gui1_test.png");
			
			lockButton = new Image(unlockIcon);
			lockButton.alignPivot(Align.LEFT, Align.TOP);
			lockButton.scale = 0.5;
			lockButton.x = -(SH_AND_HP_BAR_WIDTH / 2);
			lockButton.y = -2;
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
			
			shieldBar = new ValueTrailAnimatedSlider(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0x3377ff);
			shieldBar.alignPivot(Align.LEFT, Align.TOP);
			shieldBar.x = -(SH_AND_HP_BAR_WIDTH / 2);
			shieldBar.y = TARGET_INFO_TEXT_HEIGHT;
			addChild(shieldBar);
			
			healthBar = new ValueTrailAnimatedSlider(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0xff0022);
			healthBar.alignPivot(Align.LEFT, Align.TOP);
			healthBar.x = -(SH_AND_HP_BAR_WIDTH / 2);
			healthBar.y = shieldBar.y + SH_AND_HP_BAR_HEIGHT;
			addChild(healthBar);
			
			effects = new Sprite();
			effects.alignPivot(Align.CENTER, Align.TOP);
			effects.width = 370;
			effects.x = 0;
			effects.y = healthBar.y + SH_AND_HP_BAR_HEIGHT;
			addChild(effects);
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
			lastUnit = unit;
			lockButton.texture = Game.instance.targetSystem.lockedTarget ? lockIcon : unlockIcon;
			
			var hasShield:Boolean = unit.shieldHpMax > 0;
			shieldBar.visible = hasShield;
			if (hasShield) {
				shieldBar.y = TARGET_INFO_TEXT_HEIGHT;
				healthBar.y = shieldBar.y + SH_AND_HP_BAR_HEIGHT;
			}
			else {
				healthBar.y = TARGET_INFO_TEXT_HEIGHT;
			}
			
			{
				var currentHeight = 0;
				for (var i:Number = 0; i < effects.numChildren; i++)
					objPool.recicleObject(effects.getChildAt(i));
				effects.removeChildren();
				
				for each (var debuff:DebuffEffect in unit.currentDebuffs) {
					var effectText:Label = objPool.getObject() as Label;
					effectText.width = SH_AND_HP_BAR_WIDTH;
					effectText.height = TARGET_INFO_TEXT_HEIGHT;
					effectText.styleName = "target_info";
					effectText.alignPivot(Align.CENTER, Align.TOP);
					effectText.x = 0;
					effectText.y = currentHeight + 2;
					effectText.text = "Debuff " + debuff.getDebuffId() + ": x" + debuff.getStacks() + " Time: " + (debuff.getEndTime() - game.time);
					effects.addChild(effectText);
					currentHeight += TARGET_INFO_TEXT_HEIGHT;
				}
			}
			
			shieldBar.setValue(unit.shieldHp, unit.shieldHpMax);
			shieldBar.update();
			healthBar.setValue(unit.hp, unit.hpMax);
			healthBar.update();
		}
	}
}