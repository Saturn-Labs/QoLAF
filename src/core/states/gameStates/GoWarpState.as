package core.states.gameStates
{
	import core.hud.components.TextBitmap;
	import core.scene.Game;
	import debug.Console;
	import joinRoom.JoinRoomLocator;
	import playerio.PlayerIOError;
	import playerio.RoomInfo;
	import starling.display.DisplayObject;
	import starling.events.TouchEvent;
	
	public class GoWarpState extends PlayState
	{
		public function GoWarpState(param1:Game)
		{
			super(param1);
		}
		
		override public function enter():void
		{
			super.enter();
			g.hud.show = false;
			g.client.multiplayer.listRooms("game", {}, 150, 0, handleRooms, function(param1:PlayerIOError):void
			{
				Console.write("Error: " + param1);
			});
		}
		
		private function handleRooms(param1:Array):void
		{
			var roomInfoText:TextBitmap;
			var ri:RoomInfo;
			var rooms:Array = param1;
			var maxLimit:int = 15;
			var i:int = 0;
			var j:int = 0;
			var k:int = 1;
			rooms.sort(function(param1:Object, param2:Object):int
			{
				var _loc3_:int = 0;
				if (param1.data.Name > param2.data.Name)
				{
					_loc3_ = 1;
				}
				else
				{
					_loc3_ = -1;
				}
				if (param1.data.version > param2.data.version)
				{
					_loc3_ = -1;
				}
				else if (param1.data.version < param2.data.version)
				{
					_loc3_ = 1;
				}
				return _loc3_;
			});
			for each (ri in rooms)
			{
				if (!(ri.data.version != 1379 && !g.me.isDeveloper))
				{
					if (!(ri.data.clanInstance == "true" && !g.me.isDeveloper))
					{
						roomInfoText = new TextBitmap();
						roomInfoText.text += k + ". ";
						roomInfoText.text += ri.data.version + ", ";
						roomInfoText.text += ri.data.Name + ", ";
						roomInfoText.text += ri.onlineUsers + ", ";
						roomInfoText.text += ri.data.systemType;
						roomInfoText.format.font = "Verdana";
						roomInfoText.size = 10;
						roomInfoText.x = 80 + j * 200;
						roomInfoText.y = 100 + i * 20;
						roomInfoText.useHandCursor = true;
						roomInfoText.addEventListener("touch", createOnTouch(ri));
						addChild(roomInfoText);
						i++;
						k++;
						if (i % 20 == 0)
						{
							j++;
							i = 0;
						}
					}
				}
			}
			loadCompleted();
		}
		
		public function createOnTouch(param1:RoomInfo):Function
		{
			var ri:RoomInfo = param1;
			return function(param1:TouchEvent):void
			{
				if (param1.getTouch(param1.currentTarget as DisplayObject, "began"))
				{
					JoinRoomLocator.getService().desiredRoomId = ri.id;
					g.send("modWarp", ri.data.Name);
				}
			};
		}
		
		override public function execute():void
		{
			if (loaded)
			{
				if (keybinds.isEscPressed)
				{
					sm.changeState(new RoamingState(g));
				}
				updateCommands();
			}
			super.execute();
		}
		
		override public function exit(param1:Function):void
		{
			container.removeChildren(0, -1, true);
			super.exit(param1);
		}
	}
}
