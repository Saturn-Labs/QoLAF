package core.hud.components
{
	import com.greensock.TweenMax;
	import core.friend.Friend;
	import core.hud.components.starMap.StarMap;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class WarpGateFriendLocationSelector extends Sprite
	{
		protected var box:Box;
		
		protected var closeButton:Button;
		
		protected var bgr:Quad;
		
		private var callback:Function;
		
		public function WarpGateFriendLocationSelector(param1:Function)
		{
			box = new Box(300, 200, "highlight", 18);
			bgr = new Quad(100, 100, 570425344);
			super();
			this.callback = param1;
			closeButton = new Button(close, "Back");
			bgr.alpha = 0.5;
			addChild(bgr);
			addChild(box);
			box.addChild(closeButton);
			addEventListener("addedToStage", stageAddHandler);
		}
		
		private function stageAddHandler(param1:Event):void
		{
			addEventListener("removedFromStage", clean);
			stage.addEventListener("resize", resize);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
			draw();
		}
		
		protected function close(param1:TouchEvent = null):void
		{
			closeAndWarp(false);
		}
		
		protected function draw(param1:Event = null):void
		{
			if (stage == null)
			{
				return;
			}
			closeButton.x = Math.round(115);
			var _loc2_:int = 0;
			var _loc4_:int = 47;
			var _loc5_:WarpToFriendRow = new WarpToFriendRow("friendly", null, closeAndWarp);
			_loc5_.y = 3 + _loc4_ * _loc2_++;
			box.addChild(_loc5_);
			_loc5_ = new WarpToFriendRow("hostile", null, closeAndWarp);
			_loc5_.y = 3 + _loc4_ * _loc2_++;
			box.addChild(_loc5_);
			_loc5_ = new WarpToFriendRow("clan", null, closeAndWarp);
			_loc5_.y = 3 + _loc4_ * _loc2_++;
			box.addChild(_loc5_);
			for each (var _loc3_:* in StarMap.friendsInSelectedSystem)
			{
				_loc5_ = new WarpToFriendRow("", _loc3_, closeAndWarp);
				_loc5_.y = 3 + _loc4_ * _loc2_++;
				box.addChild(_loc5_);
			}
			box.height = 50 + _loc2_ * _loc4_;
			closeButton.y = box.height - 60;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
		
		private function closeAndWarp(param1:Boolean = true):void
		{
			var doit:Boolean = param1;
			TweenMax.to(this, 0.3, {"height": 0, "alpha": 0, "onComplete": function():void
			{
				callback(doit);
			}});
		}
		
		private function resize(param1:Event):void
		{
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
		}
		
		protected function clean(param1:Event):void
		{
			stage.removeEventListener("resize", resize);
			removeEventListener("removedFromStage", clean);
			removeEventListener("addedToStage", stageAddHandler);
		}
	}
}

import com.adobe.crypto.MD5;
import core.friend.Friend;
import core.hud.components.starMap.StarMap;
import core.scene.Game;
import joinRoom.IJoinRoomManager;
import joinRoom.JoinRoomLocator;
import starling.display.Sprite;
import core.hud.components.Style;
import core.hud.components.Text;
import core.hud.components.Button;

class WarpToFriendRow extends Sprite
{
	public function WarpToFriendRow(param1:String, param2:Friend, param3:Function)
	{
		var playerInSystem:Text;
		var description:Text;
		var buttonText:String;
		var warpToFriendButton:Button;
		var type:String = param1;
		var friend:Friend = param2;
		var callback:Function = param3;
		super();
		playerInSystem = new Text();
		description = new Text();
		playerInSystem.color = Style.COLOR_H2;
		if (friend == null)
		{
			playerInSystem.color = 11184810;
		}
		playerInSystem.size = 14;
		description.size = 11;
		description.font = "Verdana";
		description.y = playerInSystem.y + 19;
		description.color = 16777215;
		buttonText = "Warp";
		if (type == "friendly")
		{
			playerInSystem.text = "Friendly";
			playerInSystem.color = Style.COLOR_FRIENDLY;
			description.text = "Other players are friendly";
		}
		else if (type == "hostile")
		{
			playerInSystem.size = 13;
			playerInSystem.text = "Hostile (+5 artifact levels)";
			playerInSystem.color = Style.COLOR_HOSTILE;
			description.text = "Other players may attack";
		}
		else if (type == "clan")
		{
			playerInSystem.size = 13;
			playerInSystem.text = "Clan Instance (-20% loot)";
			playerInSystem.color = Style.COLOR_HIGHLIGHT;
			description.text = "Only for clan members";
		}
		else
		{
			playerInSystem.text = friend.name;
			buttonText = "Warp";
		}
		warpToFriendButton = new Button(function():void
		{
			setDesiredRoom(type, friend);
			callback();
		}, buttonText, "positive");
		if (type == "clan" && !Game.instance.me.clanId)
		{
			warpToFriendButton.enabled = false;
		}
		warpToFriendButton.x = 225;
		warpToFriendButton.y = playerInSystem.y;
		addChild(playerInSystem);
		addChild(description);
		addChild(warpToFriendButton);
	}
	
	private function setDesiredRoom(param1:String, param2:Friend):void
	{
		var _loc3_:String = null;
		var _loc4_:IJoinRoomManager = JoinRoomLocator.getService();
		_loc4_.desiredRoomId = null;
		_loc4_.desiredSystemType = "friendly";
		if (param1 == "friendly")
		{
			_loc4_.desiredSystemType = "friendly";
		}
		else if (param1 == "hostile")
		{
			_loc4_.desiredSystemType = "hostile";
		}
		else if (param1 == "clan")
		{
			if (Game.instance.me.clanId)
			{
				_loc3_ = MD5.hash(StarMap.selectedSolarSystem.key + Game.instance.me.clanId);
				_loc4_.desiredRoomId = _loc3_;
				_loc4_.desiredSystemType = "clan";
			}
		}
		else
		{
			_loc4_.desiredRoomId = param2.currentRoom;
		}
	}
}
