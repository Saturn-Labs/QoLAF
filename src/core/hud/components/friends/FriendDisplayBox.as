package core.hud.components.friends
{
	import core.friend.Friend;
	import core.hud.components.Button;
	import core.hud.components.Style;
	import core.hud.components.TextBitmap;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class FriendDisplayBox extends Sprite
	{
		private var friend:Friend;
		
		private var reputationIcon:Image;
		
		public function FriendDisplayBox(param1:Game, param2:Friend)
		{
			var dataManager:IDataManager;
			var textureManager:ITextureManager;
			var skinObj:Object;
			var obj:Object;
			var obj2:Object;
			var preview:MovieClip;
			var name:TextBitmap;
			var level:TextBitmap;
			var that:Sprite;
			var objSolar:Object;
			var b:Button;
			var g:Game = param1;
			var friend:Friend = param2;
			super();
			this.friend = friend;
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			skinObj = dataManager.loadKey("Skins", friend.skin);
			obj = dataManager.loadKey("Ships", skinObj.ship);
			obj2 = dataManager.loadKey("Images", obj.bitmap);
			preview = new MovieClip(textureManager.getTexturesMainByKey(obj.bitmap));
			preview.x = -preview.width / 2;
			addChild(preview);
			name = new TextBitmap();
			name.text = friend.name;
			name.x = 50;
			name.y = 4;
			name.size = 20;
			name.format.color = friend.isOnline ? Style.COLOR_ONLINE : 6710886;
			addChild(name);
			level = new TextBitmap();
			level.text = "level " + friend.level;
			level.x = 380;
			level.y = 7;
			level.size = 16;
			level.format.color = 6710886;
			addChild(level);
			that = this;
			objSolar = dataManager.loadKey("SolarSystems", friend.currentSolarSystem);
			if (friend.isOnline)
			{
				useHandCursor = true;
				addEventListener("touch", function(param1:TouchEvent):void
				{
					if (param1.getTouch(that, "ended"))
					{
						dispatchEventWith("friendSelected", false, friend.currentSolarSystem);
					}
				});
			}
			b = new Button(function():void
			{
				g.friendManager.sendRemoveFriendById(friend.id);
				that.parent.visible = false;
				g.showErrorDialog("Friend removed.", false);
			}, "remove");
			b.x = 490;
			b.y = 4;
			addChild(b);
		}
	}
}
