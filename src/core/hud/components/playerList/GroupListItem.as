package core.hud.components.playerList
{
	import core.group.Group;
	import core.player.Player;
	import core.scene.Game;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class GroupListItem extends Sprite
	{
		private var g:Game;
		
		private var group:Group;
		
		private var playerListItems:Vector.<PlayerListItem>;
		
		private var separator:Quad;
		
		public function GroupListItem(param1:Game, param2:Group)
		{
			var _loc5_:int = 0;
			var _loc4_:Player = null;
			var _loc3_:PlayerListItem = null;
			playerListItems = new Vector.<PlayerListItem>();
			separator = new Quad(620, 2, 6710886);
			super();
			this.g = param1;
			this.group = param2;
			_loc5_ = 0;
			while (_loc5_ < param2.length)
			{
				_loc4_ = param2.players[_loc5_];
				_loc3_ = new PlayerListItem(param1, _loc4_, 640, 60);
				_loc3_.x = 0;
				_loc3_.y = 5 + _loc5_ * 60;
				addChild(_loc3_);
				playerListItems.push(_loc3_);
				_loc5_++;
			}
			if (param2.length > 0)
			{
				separator.x = 0;
				separator.y = height;
				separator.alpha = 0.7;
				addChild(separator);
			}
			else
			{
				removeChild(separator);
			}
		}
		
		override public function get height():Number
		{
			return group.length * 60 + 5;
		}
		
		override public function dispose():void
		{
			removeChildren(0, -1, true);
			playerListItems = null;
		}
	}
}
