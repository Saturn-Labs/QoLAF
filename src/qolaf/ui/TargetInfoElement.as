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
	import qolaf.ui.debuff.DebuffDisplay;
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
		private static const TARGET_LEVEL_TEXT_TEMPLATE:String = "Lv. [level]"
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
		private var _debuffDisplay:DebuffDisplay;
		
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
		}
		
		private function createLockAndInfoLabel():void {
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
			_targetName.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
				_targetName.filter = _targetNameAuraEffect;
			});
			
			_targetLevel = new TextField(55, SH_AND_HP_BAR_HEIGHT, "", new TextFormat("DAIDRR", 14, 0xffffff, Align.LEFT, Align.CENTER));
			_targetLevel.autoSize = TextFieldAutoSize.HORIZONTAL;
			
			_lockAndInfoLayout.addChild(_targetLevel);
			_lockAndInfoLayout.addChild(_targetName);
			addChild(_lockAndInfoLayout);
		}
		
		private function createShieldAndHealthBar():void {
			_shieldBar = new CustomProgressBar(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0x3377ff);
			addChild(_shieldBar);
			_healthBar = new CustomProgressBar(SH_AND_HP_BAR_WIDTH, SH_AND_HP_BAR_HEIGHT, 0xff0022);
			addChild(_healthBar);
		}
		
		private function createDebuffDisplay():void {
			_debuffDisplay = new DebuffDisplay();
			addChild(_debuffDisplay);
		}
		
		public function onEnterFrame(event:EnterFrameEvent):void {
			var pos:Point = SceneBase.clientSettings.targetInfoPosition;
			
			x = (_game.stage.stageWidth - width) * pos.x;
			y = (_game.stage.stageHeight - height) * pos.y;
			
			var unit:Unit = _game.targetSystem.getCurrentUnit();
			if (unit == null) {
				if (_debuffDisplay.debuffInfoTooltip.visible)
					_debuffDisplay.debuffInfoTooltip.visible = false;
				return;
			}
				
			var level:int = unit.level;
			var name:String = unit.name;
			var shieldMax:int = unit.shieldHpMax;
			var shield:int = unit.shieldHp;
			var hpMax:int = unit.hpMax;
			var hp:int = unit.hp;
			var auraColor:int = 0xffffff;
			var auraAlpha:Number = 0;
			
			if (unit is Spawner) {
				var spawner:Spawner = unit as Spawner;
				if (spawner.factions.length == 0)
					name = spawner.spawnerType.charAt(0).toUpperCase() + spawner.spawnerType.substring(1) + " Spawner";
				else
					name = spawner.factions[0] + " Spawner";
			}
			else if (unit.isBossUnit || unit.parentObj is Boss) {
				var parentObj:GameObject = unit.parentObj;
				while (!(parentObj is Boss))
					parentObj = unit.parentObj;
				if (parentObj is Boss) {
					var boss:Boss = parentObj as Boss;
					shieldMax = 0;
					shield = 0;
					hpMax = boss.hpMax;
					hp = boss.hp;
					name = boss.name;
					level = boss.level;
				}
			}
			
			if (unit is EnemyShip) {
				var enemyShip:EnemyShip = unit as EnemyShip;
				if (enemyShip.rareEmitters.length >= 1) {
					auraColor = enemyShip.rareEmitters[0].startColor;
					auraAlpha = 2;
				}
			}
			
			var willNeedUpdate:Boolean = _shieldBar.visible != shieldMax > 0;
			_shieldBar.visible = shieldMax > 0;
			_shieldBar.maxValue = shieldMax;
			_shieldBar.value = shield;
			_healthBar.maxValue = hpMax;
			_healthBar.value = hp;
			_targetNameAuraEffect.color = auraColor;
			_targetNameAuraEffect.alpha = auraAlpha + Math.sin(_auraEffectGlowAnimDeg) / 2.5;
			_targetLevel.format.color = getColorForLevel(level);
			_targetLevel.text = StringUtils.substitute(TARGET_LEVEL_TEXT_TEMPLATE, {
				"[level]": level
			});
			_debuffDisplay.updateDebuffs(unit.debuffs, unit);

			_targetName.text = getUnitNameWithoutLevel(name);
			_lockButton.texture = Game.instance.targetSystem._lockedTarget ? _lockIcon : _unlockIcon;

			_auraEffectGlowAnimDeg += 8 * event.passedTime;
			_lockAndInfoLayout.readjustLayout();
		}
		
		public function onClickLock(event:TouchEvent):void 
		{
			var touch:Touch = event.getTouch(_lockButton);
			if (touch == null || touch.phase != TouchPhase.BEGAN || Game.instance.targetSystem == null || !Game.instance.targetSystem.isCurrentUnitValid())
				return;
				
			Game.instance.targetSystem._lockedTarget = !Game.instance.targetSystem._lockedTarget;
		}
		
		public static function getColorForLevel(level:int):int {
			if (level >= 100)
				return 0xff0033;
			else if (level >= 75)
				return 0xff8c00;
			else if (level >= 50)
				return 0x00ddff;
			else
				return 0x737373;
		}
		
		public static function getUnitNameWithoutLevel(name:String):String {
			if (name == null)
				return "Unknown";
			return (name.split("lvl")[0] as String).replace(/^\s+|\s+$/g, "");
		}
		
		public static function getUnitTrueName(unit:Unit):String {
			var name:String = "";
			if (unit is Spawner) {
				var spawner:Spawner = unit as Spawner;
				if (spawner.factions.length == 0)
					name = spawner.spawnerType.charAt(0).toUpperCase() + spawner.spawnerType.substring(1) + " Spawner";
				else
					name = spawner.factions[0] + " Spawner";
			}
			else if (unit.isBossUnit || unit.parentObj is Boss) {
				var parentObj:GameObject = unit.parentObj;
				while (!(parentObj is Boss))
					parentObj = unit.parentObj;
				if (parentObj is Boss) {
					var boss:Boss = parentObj as Boss;
					name = boss.name;
				}
			}
			else {
				name = getUnitNameWithoutLevel(unit.name);
			}
			return name;
		}
	}
}