package core.hud.components.playerList {
	import core.friend.Friend;
	import core.group.Group;
	import core.hud.components.ButtonExpandableHud;
	import core.hud.components.friends.FriendDisplayBox;
	import core.player.Player;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class PlayerList extends Sprite {
		public static var WIDTH:Number = 658;
		
		public static var HEIGHT:Number = 500;
		
		public static var PADDING:Number = 50;
		
		public static var GROUP_MARGIN:Number = 10;
		
		private var g:Game;
		
		private var groups:Vector.<Group>;
		
		private var mapBgr:Image;
		
		private var closeButton:ButtonExpandableHud;
		
		private var listContainer:ScrollContainer;
		
		private var groupListItems:Vector.<GroupListItem>;
		
		private var onlineFriends:Sprite;
		
		private var friendBoxes:Vector.<FriendDisplayBox> = new Vector.<FriendDisplayBox>();
		
		private var isViewingOnlineFriends:Boolean = false;
		
		public function PlayerList(g:Game) {
			super();
			this.g = g;
			groups = g.groupManager.groups;
		}
		
		public function load() : void {
			var textureManager:ITextureManager = TextureLocator.getService();
			mapBgr = new Image(textureManager.getTextureByTextureName("map_bgr.png","texture_gui1_test.png"));
			addChildAt(mapBgr,0);
			closeButton = new ButtonExpandableHud(function():void {
				dispatchEventWith("close");
			},Localize.t("close"));
			closeButton.x = 713 - closeButton.width;
			closeButton.y = 21 - closeButton.height;
			addChild(closeButton);
			drawSystemPlayerList();
			if(!g.groupManager.hasEventListener("update")) {
				g.groupManager.addEventListener("update",drawSystemPlayerList);
			}
		}
		
		public function drawOnlineFriends() : void {
			isViewingOnlineFriends = true;
			renewListContainer();
			g.friendManager.updateOnlineFriends(function():void {
				var _local1:FriendDisplayBox = null;
				var _local3:int = 0;
				onlineFriends = new Sprite();
				for each(var _local2 in Player.onlineFriends) {
					_local1 = new FriendDisplayBox(g,_local2);
					_local1.x = 50;
					_local1.y = _local3 * 40 + 20;
					_local3++;
					friendBoxes.push(_local1);
					onlineFriends.addChild(_local1);
				}
				listContainer.addChild(onlineFriends);
			});
		}
		
		public function drawSystemPlayerList(e:Event = null) : void {
			var i:int;
			var group:Group;
			var groupListItem:GroupListItem;
			var yy:Number;
			var previousGroupListItem:GroupListItem;
			if(e != null && isViewingOnlineFriends) {
				return;
			}
			groupListItems = new Vector.<GroupListItem>();
			renewListContainer();
			groups.sort(function(param1:Group, param2:Group):int {
				if(g.me.group == param1) {
					return -1;
				}
				if(g.me.group == param2) {
					return 1;
				}
				if(param1.id < param2.id) {
					return -1;
				}
				if(param1.id > param2.id) {
					return 1;
				}
				return 0;
			});
			i = 0;
			while(i < groups.length) {
				group = groups[i];
				groupListItem = new GroupListItem(g,group);
				groupListItem.x = 0;
				yy = 0;
				if(i > 0) {
					previousGroupListItem = groupListItems[i - 1];
					yy = previousGroupListItem.y + previousGroupListItem.height + GROUP_MARGIN;
				}
				groupListItem.y = yy;
				groupListItems.push(groupListItem);
				listContainer.addChild(groupListItem);
				i++;
			}
		}
		
		private function renewListContainer() : void {
			if(listContainer != null && contains(listContainer)) {
				removeChild(listContainer);
			}
			listContainer = new ScrollContainer();
			listContainer.width = 675;
			listContainer.height = 520;
			listContainer.y = 50;
			listContainer.x = 50;
			addChild(listContainer);
		}
		
		override public function dispose() : void {
			removeChildren(0,-1,true);
			removeEventListeners();
			g.groupManager.removeEventListener("update",drawSystemPlayerList);
		}
	}
}

