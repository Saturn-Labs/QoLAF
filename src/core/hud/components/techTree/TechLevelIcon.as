package core.hud.components.techTree
{
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.player.TechSkill;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class TechLevelIcon extends Sprite
	{
		public static var ICON_WIDTH:int = 40;
		public static var ICON_PADDING:int = 5;
		public static const STATE_UPGRADED:String = "upgraded";

		public static const STATE_CAN_BE_UPGRADED:String = "can be upgraded";

		public static const STATE_CANT_BE_UPGRADED:String = "can't be upgraded";

		public static const STATE_LOCKED:String = "locked";

		public static const STATE_SELECTED:String = "selected";

		public static const STATE_SKIN_LOCKED:String = "skin locked";

		public var level:int;
		public var playerLevel:int;
		public var mineralType1:String;
		public var mineralType2:String;
		public var table:String;
		public var tech:String;
		public var upgradeName:String;
		public var description:String;
		private var bitmap:Image;
		private var bitmapHover:Image;
		private var bitmapNotAvailable:Image;
		private var bitmapAvailable:Image;
		private var bitmapSelected:Image;
		private var bitmapMax:Image;
		private var bitmapLocked:Image;
		private var bitmapSkinLocked:Image;
		private var textureManager:ITextureManager;
		private var dataManager:IDataManager;
		private var number:TextBitmap;
		private var techItemObject:Object;
		private var state:String;
		private var tb:TechBar;
		private var showTooltip:Boolean;
		public function TechLevelIcon(param1:TechBar, param2:String, param3:int, param4:TechSkill, param5:Boolean)
		{
			var _loc8_:Object = null;
			super();
			this.tb = param1;
			this.table = param4.table;
			this.tech = param4.tech;
			this.showTooltip = param5;
			textureManager = TextureLocator.getService();
			dataManager = DataLocator.getService();
			techItemObject = dataManager.loadKey(table, tech);
			var _loc6_:Object = dataManager.loadKey("Images", techItemObject.techIcon);
			var _loc7_:String = param3 > 0 ? _loc6_.textureName + "_levels.png" : _loc6_.textureName;
			upgradeName = Localize.t(techItemObject.name);
			description = Localize.t(techItemObject.description);
			this.level = param3;
			this.state = param2;
			if (param3 > 0)
			{
				_loc8_ = techItemObject.techLevels[param3 - 1];
				description = _loc8_.description;
				mineralType1 = _loc8_.mineralType1;
				if (_loc8_.hasOwnProperty("mineralType2") && _loc8_.mineralType2 != null)
				{
					mineralType2 = _loc8_.mineralType2;
				}
				else
				{
					mineralType2 = null;
				}
			}
			this.playerLevel = param4.level;
			bitmap = new Image(textureManager.getTextureGUIByTextureName(_loc7_));
			addChild(bitmap);
			bitmapHover = new Image(textureManager.getTextureGUIByTextureName(_loc7_));
			bitmapHover.touchable = false;
			bitmapHover.blendMode = "add";
			addChild(bitmapHover);
			number = new TextBitmap();
			number.batchable = true;
			if (param3 > 0)
			{
				number.text = param3.toString();
				number.x = ICON_WIDTH / 2 - 1;
				if (param3 == 6)
				{
					number.y = ICON_WIDTH / 2 - 3;
				}
				else
				{
					number.y = ICON_WIDTH / 2 - 4;
				}
				number.center();
				addChild(number);
			}
			bitmapNotAvailable = new Image(textureManager.getTextureGUIByTextureName("ti_na.png"));
			bitmapNotAvailable.touchable = false;
			bitmapNotAvailable.visible = false;
			bitmapAvailable = new Image(textureManager.getTextureGUIByTextureName("ti_a.png"));
			bitmapAvailable.touchable = false;
			bitmapAvailable.color = 65280;
			bitmapAvailable.visible = false;
			addChild(bitmapAvailable);
			bitmapSelected = new Image(textureManager.getTextureGUIByTextureName("ti_a.png"));
			bitmapSelected.touchable = false;
			bitmapSelected.color = 16777215;
			bitmapSelected.visible = false;
			addChild(bitmapSelected);
			bitmapMax = new Image(textureManager.getTextureGUIByTextureName("ti_a.png"));
			bitmapMax.color = 16777215;
			bitmapMax.visible = false;
			bitmapLocked = new Image(textureManager.getTextureByTextureName("lock.png", "texture_gui1_test.png"));
			bitmapLocked.touchable = false;
			bitmapLocked.visible = false;
			bitmapLocked.x = 10;
			bitmapLocked.y = 5;
			addChild(bitmapLocked);
			bitmapSkinLocked = new Image(textureManager.getTextureByTextureName("radar_player.png", "texture_gui1_test.png"));
			bitmapSkinLocked.touchable = false;
			bitmapSkinLocked.visible = false;
			bitmapSkinLocked.x = 6;
			bitmapSkinLocked.y = 26;
			bitmapSkinLocked.alpha = 0.3;
			addChild(bitmapSkinLocked);
			this.addEventListener("touch", onTouch);
			updateState(param2);
			if (param5)
			{
				new ToolTip(Game.instance, this, "<font color='#ffffff'>" + description + "</font>");
			}
		}

		public function updateState(param1:String):void
		{
			this.state = param1;
			bitmap.alpha = bitmapHover.alpha = 1;
			useHandCursor = false;
			bitmapAvailable.visible = false;
			bitmapHover.visible = false;
			bitmapMax.visible = false;
			bitmapNotAvailable.visible = false;
			bitmapSelected.visible = false;
			bitmapLocked.visible = false;
			bitmapSkinLocked.visible = false;
			number.visible = true;
			switch (param1)
			{
				case "locked":
					bitmap.alpha = bitmapHover.alpha = 0.3;
					bitmapLocked.visible = true;
					number.visible = false;
					useHandCursor = false;
					break;
				case "selected":
					useHandCursor = true;
					bitmapHover.visible = true;
					bitmapSelected.visible = true;
					break;
				case "can be upgraded":
					bitmap.alpha = bitmapHover.alpha = 0.5;
					useHandCursor = true;
					bitmapAvailable.visible = true;
					break;
				case "can't be upgraded":
					bitmap.alpha = bitmapHover.alpha = 0.3;
					useHandCursor = false;
					bitmapAvailable.visible = false;
					break;
				case "skin locked":
					bitmapSkinLocked.visible = true;
			}
		}

		private function mouseOver(param1:TouchEvent = null):void
		{
			if (state == "selected")
			{
				return;
			}
			bitmapHover.visible = true;
			if (!showTooltip)
			{
				this.dispatchEventWith("mOver", true);
			}
		}

		private function mouseOut(param1:TouchEvent):void
		{
			if (state == "selected")
			{
				return;
			}
			bitmapHover.visible = false;
			if (!showTooltip)
			{
				this.dispatchEventWith("mOut", true);
			}
		}

		private function mouseClick(param1:TouchEvent):void
		{
			if (state == "upgraded" || state == "locked" || state == "can't be upgraded" || state == "skin locked")
			{
				bitmapHover.visible = false;
				return;
			}
			if (state == "selected")
			{
				updateState("can be upgraded");
			}
			else if (state == "can be upgraded")
			{
				updateState("selected");
			}
			this.dispatchEventWith("mClick", true);
		}

		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "ended"))
			{
				mouseClick(param1);
			}
			else if (param1.interactsWith(this))
			{
				mouseOver(param1);
			}
			else
			{
				mouseOut(param1);
			}
		}

		public function upgrade():void
		{
			tb.upgrade(this);
		}

		override public function dispose():void
		{
			removeEventListeners();
			super.dispose();
		}

		private function getDescription(param1:Object):void
		{
		}
	}
}
