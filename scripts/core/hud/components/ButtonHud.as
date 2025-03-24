package core.hud.components {
	import com.greensock.TweenMax;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ButtonHud extends DisplayObjectContainer {
		public static const TYPE_MAP:String = "button_map.png";
		
		public static const TYPE_SHIP:String = "button_ship.png";
		
		public static const TYPE_CARGO:String = "button_cargo.png";
		
		public static const TYPE_SETTINGS:String = "button_settings.png";
		
		public static const TYPE_PVP:String = "button_pvp.png";
		
		public static const TYPE_ARTIFACTS:String = "button_artifacts.png";
		
		public static const TYPE_LEADERBOARD:String = "button_leaderboard.png";
		
		public static const TYPE_ENCOUNTERS:String = "button_encounters.png";
		
		public static const TYPE_PAY:String = "button_pay.png";
		
		public static const TYPE_MISSIONS:String = "button_missions.png";
		
		public static const TYPE_NEW_MISSION:String = "button_new_mission.png";
		
		public static const TYPE_SHOP_BG:String = "button_shop_bg";
		
		public static const TYPE_PLAYERS:String = "button_players.png";
		
		public static const TYPE_PVP_MENU:String = "button_pvpmatch.png";
		
		public static const TYPE_HUD_PVP:String = "button_play_pvp.png";
		
		public static const TYPE_JOIN_PVP:String = "button_join_pvp.png";
		
		private var clickCallback:Function;
		
		private var image:Image;
		
		private var hoverImage:Image;
		
		protected var hintNewContainer:Image;
		
		private var _enabled:Boolean = true;
		
		private var tw:TweenMax;
		
		public function ButtonHud(clickCallback:Function, buttonType:String = "button_ship.png", loadCallback:Function = null) {
			super();
			useHandCursor = true;
			this.clickCallback = clickCallback;
			var _local5:ITextureManager = TextureLocator.getService();
			image = new Image(_local5.getTextureGUIByTextureName(buttonType));
			hoverImage = new Image(image.texture);
			hoverImage.blendMode = "add";
			hoverImage.visible = false;
			hoverImage.touchable = false;
			addChild(image);
			addChild(hoverImage);
			var _local4:Texture = _local5.getTextureGUIByTextureName("notification.png");
			hintNewContainer = new Image(_local4);
			hintNewContainer.x = 12;
			hintNewContainer.y = -4;
			hintNewContainer.touchable = false;
			hintNewContainer.visible = false;
			addChild(hintNewContainer);
			addEventListener("touch",onTouch);
			if(loadCallback != null) {
				loadCallback();
			}
		}
		
		protected function mOver(e:TouchEvent) : void {
			hoverImage.visible = true;
		}
		
		protected function set color(value:uint) : void {
			image.color = value;
		}
		
		protected function mOut(e:TouchEvent) : void {
			hoverImage.visible = false;
		}
		
		public function set enabled(value:Boolean) : void {
			useHandCursor = value;
			alpha = value ? 1 : 0.5;
			_enabled = value;
		}
		
		public function flash() : void {
			var flashImage:Image = new Image(image.texture);
			flashImage.blendMode = "screen";
			flashImage.touchable = false;
			flashImage.pivotX = flashImage.width / 2;
			flashImage.pivotY = flashImage.height / 2;
			flashImage.x = image.width / 2;
			flashImage.y = image.height / 2;
			flashImage.scaleX = 2;
			flashImage.scaleY = 2;
			flashImage.alpha = 1;
			addChild(flashImage);
			tw = TweenMax.to(flashImage,3,{
				"alpha":0,
				"scaleX":1,
				"scaleY":1,
				"onComplete":function():void {
					removeChild(flashImage);
				}
			});
		}
		
		public function click(e:TouchEvent = null) : void {
			var _local2:ISound = SoundLocator.getService();
			_local2.play("3hVYqbNNSUWoDGk_pK1BdQ");
			hoverImage.visible = false;
			hintNewContainer.visible = false;
			if(clickCallback != null) {
				clickCallback(e);
			}
		}
		
		public function onTouch(e:TouchEvent) : void {
			if(!_enabled) {
				return;
			}
			if(e.getTouch(this,"ended")) {
				click(e);
			} else if(e.interactsWith(this)) {
				mOver(e);
			} else if(!e.interactsWith(this)) {
				mOut(e);
			}
		}
		
		public function hintNew() : void {
			hintNewContainer.visible = true;
		}
		
		public function hideHintNew() : void {
			hintNewContainer.visible = false;
		}
	}
}

