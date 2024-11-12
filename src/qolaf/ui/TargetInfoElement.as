package qolaf.ui
{
	import core.GameObject;
	import core.boss.Boss;
	import core.scene.Game;
	import core.scene.SceneBase;
	import core.ship.EnemyShip;
	import core.spawner.Spawner;
	import core.unit.Unit;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import flash.geom.Point;
	import generics.Util;
	import qolaf.data.IDataHandler;
	import qolaf.data.ISharedSettings;
	import qolaf.modifiers.IModifierTarget;
	import qolaf.modifiers.Modifier;
	import qolaf.events.ModifierAddedEvent;
	import qolaf.events.ModifierRemovedEvent;
	import qolaf.events.ModifierStackedEvent;
	import qolaf.events.TargetUpdatedEvent;
	import qolaf.target.ITarget;
	import qolaf.ui.elements.ModifierIcon;
	import qolaf.ui.modifiers.IModifierDisplay;
	import qolaf.ui.modifiers.TargetModifierDisplay;
	import qolaf.ui.elements.CustomProgressBar;
	import qolaf.utils.StringUtils;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.DisplayObject;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.filters.GlowFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
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
	public class TargetInfoElement extends LayoutGroup
	{
		private static const TARGET_LEVEL_TEXT_TEMPLATE:String = "Lv. [level]";
		private static const TARGET_INFO_TEXT_HEIGHT:Number = 20;
		private static const SH_AND_HP_BAR_HEIGHT:Number = 14;
		private static const SH_AND_HP_BAR_WIDTH:Number = 300;

		private var _game:Game;
		private var _lockAndInfoLayout:LayoutGroup;
		private var _targetLevel:TextField;
		private var _targetName:TextField;
		private var _targetNameAuraEffect:GlowFilter;
		private var _shieldBar:CustomProgressBar;
		private var _healthBar:CustomProgressBar;
		private var _lockButton:Image;
		private var _modifierDisplay:IModifierDisplay;
		private var _lockIcon:Texture;
		private var _unlockIcon:Texture;
		private var _auraEffectGlowAnimDeg:Number = 0.0;
		public function TargetInfoElement(game:Game)
		{
			this._game = game;
			var verticalLayout:VerticalLayout = new VerticalLayout();
			verticalLayout.horizontalAlign = HorizontalAlign.CENTER;
			verticalLayout.verticalAlign = VerticalAlign.MIDDLE;
			layout = verticalLayout;
			createLockAndInfoLabel();
			createShieldAndHealthBar();
			createDebuffDisplay();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			game.targetSystem.addEventListener(TargetUpdatedEvent.EVENT, onTargetUpdated);
		}

		private function createLockAndInfoLabel():void
		{
			_lockAndInfoLayout = new LayoutGroup();
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			horizontalLayout.verticalAlign = VerticalAlign.MIDDLE;
			horizontalLayout.gap = 3.5;
			_lockAndInfoLayout.layout = horizontalLayout;
			_lockAndInfoLayout.width = SH_AND_HP_BAR_WIDTH;
			_lockAndInfoLayout.height = 24.5;

			var manager:ITextureManager = TextureLocator.getService();
			_lockIcon = manager.getTextureByTextureName("ti_cargo_protection", "texture_gui1_test.png");
			_unlockIcon = manager.getTextureByTextureName("ti_cargo_protection_inactive", "texture_gui1_test.png");

			_lockButton = new Image(_unlockIcon);
			_lockButton.scale = 0.5;
			_lockButton.touchable = true;
			_lockButton.addEventListener(TouchEvent.TOUCH, onClickLock);
			_lockAndInfoLayout.addChild(_lockButton);

			_targetName = new TextField(SH_AND_HP_BAR_WIDTH - 30, SH_AND_HP_BAR_HEIGHT, "", new TextFormat("DAIDRR", 14, 0xffffff, Align.LEFT, Align.CENTER));
			_targetName.isHtmlText = true;
			_targetNameAuraEffect = new GlowFilter(0x000000, 0, 10, 1);
			_targetName.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
				{
					_targetName.filter = _targetNameAuraEffect;
				});

			_targetLevel = new TextField(55, SH_AND_HP_BAR_HEIGHT, "", new TextFormat("DAIDRR", 14, 0xffffff, Align.LEFT, Align.CENTER));
			_targetLevel.autoSize = TextFieldAutoSize.HORIZONTAL;

			_lockAndInfoLayout.addChild(_targetLevel);
			_lockAndInfoLayout.addChild(_targetName);
			addChild(_lockAndInfoLayout);
		}

		private function onTargetUpdated(e:TargetUpdatedEvent):void
		{
			_modifierDisplay.setTarget(e.updatedTarget as IModifierTarget);
		}

		private function createShieldAndHealthBar():void
		{
			_shieldBar = new CustomProgressBar(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0x3377ff);
			addChild(_shieldBar);
			_healthBar = new CustomProgressBar(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0xff0022);
			addChild(_healthBar);
		}

		private function createDebuffDisplay():void
		{
			_modifierDisplay = new TargetModifierDisplay();
			addChild(_modifierDisplay as TargetModifierDisplay);
		}

		public function onEnterFrame(event:EnterFrameEvent):void
		{
			var pos:Point = new Point(0.5, 0.1);
			if (SceneBase.sharedSettings != null) {
				pos = SceneBase.sharedSettings.getValue(function(handler:IDataHandler):Point {
					return handler.getSettingOr("target_info_position", new Point(0.5, 0.1)) as Point;
				}) as Point;
			}
			
			
			x = (_game.stage.stageWidth - width) * pos.x;
			y = (_game.stage.stageHeight - height) * pos.y;

			var target:ITarget = _game.targetSystem.target;
			if (target == null)
			{
				return;
			}

			var level:int = target.getLevel();
			var name:String = target.getTrueName();
			var shieldMax:int = target.getMaxShield();
			var shield:int = target.getShield();
			var hpMax:int = target.getMaxHealth();
			var hp:int = target.getHealth();
			var auraColor:int = target.getAuraColor();
			var auraAlpha:Number = target.hasAura() ? 2 : 0;
			var willNeedUpdate:Boolean = _shieldBar.visible != shieldMax > 0;
			_shieldBar.visible = shieldMax > 0;
			_shieldBar.maxValue = shieldMax;
			_shieldBar.value = shield;
			_healthBar.maxValue = hpMax;
			_healthBar.value = hp;
			_targetNameAuraEffect.color = auraColor;
			_targetNameAuraEffect.alpha = auraAlpha + Math.sin(_auraEffectGlowAnimDeg) / 2.0;
			_targetLevel.format.color = getColorForLevel(level);
			_targetLevel.text = StringUtils.substitute(TARGET_LEVEL_TEXT_TEMPLATE, {
				"[level]": level
			});

			_targetName.text = name;
			_lockButton.texture = Game.instance.targetSystem._lockedTarget ? _lockIcon : _unlockIcon;

			_auraEffectGlowAnimDeg += 8 * event.passedTime;
			_lockAndInfoLayout.readjustLayout();
		}

		public function onClickLock(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_lockButton);
			if (touch == null || touch.phase != TouchPhase.BEGAN || Game.instance.targetSystem == null || !Game.instance.targetSystem.isTargetValid())
				return;

			Game.instance.targetSystem._lockedTarget = !Game.instance.targetSystem._lockedTarget;
		}

		public static function getColorForLevel(level:int):int
		{
			if (level >= 100)
				return 0xff0033;
			else if (level >= 75)
				return 0xff8c00;
			else if (level >= 50)
				return 0x00ddff;
			else
				return 0x737373;
		}
	}
}