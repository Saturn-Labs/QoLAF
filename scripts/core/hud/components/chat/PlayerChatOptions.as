package core.hud.components.chat {
	import core.hud.components.ToolTip;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import feathers.layout.HorizontalLayout;
	import starling.display.Image;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class PlayerChatOptions extends ScrollContainer {
		private var g:Game;
		
		private var obj:Object;
		
		private var muteImage:Image;
		
		private var messageImage:Image;
		
		private var banImage:Image;
		
		public function PlayerChatOptions(g:Game, obj:Object) {
			super();
			this.g = g;
			this.obj = obj;
			var _local3:HorizontalLayout = new HorizontalLayout();
			_local3.paddingLeft = 10;
			_local3.paddingTop = 5;
			_local3.paddingBottom = 10;
			_local3.gap = 15;
			this.layout = _local3;
			var _local4:ITextureManager = TextureLocator.getService();
			muteImage = new Image(_local4.getTextureGUIByTextureName("mute"));
			muteImage.addEventListener("touch",onMute);
			muteImage.useHandCursor = true;
			addChild(muteImage);
			new ToolTip(g,muteImage,"mute player",null,"PlayerChatOptions");
			messageImage = new Image(_local4.getTextureGUIByTextureName("chat_pm"));
			messageImage.addEventListener("touch",onPrivateMessage);
			messageImage.useHandCursor = true;
			addChild(messageImage);
			new ToolTip(g,messageImage,"send private message",null,"PlayerChatOptions");
			if(g.me.isModerator || g.me.isDeveloper) {
				banImage = new Image(_local4.getTextureGUIByTextureName("chat_ban"));
				banImage.addEventListener("touch",onSilence);
				banImage.useHandCursor = true;
				addChild(banImage);
				new ToolTip(g,banImage,"silence player",null,"PlayerChatOptions");
			}
		}
		
		private function onMute(e:TouchEvent) : void {
			if(e.getTouch(muteImage,"ended")) {
				g.sendToServiceRoom("chatMsg","ignore",obj.playerName);
				g.messageLog.removePlayerMessages(obj.playerKey);
			}
		}
		
		private function onPrivateMessage(e:TouchEvent) : void {
			if(e.getTouch(messageImage,"ended")) {
				g.chatInput.setText("/w " + obj.playerName + " ");
			}
		}
		
		private function onSilence(e:TouchEvent) : void {
			if(e.getTouch(banImage,"ended")) {
				g.chatInput.setText("/silence " + obj.playerKey + " ");
			}
		}
		
		override public function dispose() : void {
			muteImage.removeEventListeners();
			messageImage.removeEventListeners();
			if(banImage) {
				banImage.removeEventListeners();
			}
			ToolTip.disposeType("PlayerChatOptions");
			super.dispose();
		}
	}
}

