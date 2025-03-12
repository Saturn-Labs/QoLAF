package core.states
{
	import flash.utils.getQualifiedClassName;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	
	public class SceneStateMachine
	{
		private var currentRoom:ISceneState;
		
		private var profile:ISceneState;
		
		private var stage:Stage;
		
		public function SceneStateMachine(param1:Stage)
		{
			super();
			currentRoom = null;
			this.stage = param1;
		}
		
		public function changeRoom(param1:ISceneState):void
		{
			if (currentRoom != null)
			{
				currentRoom.exit();
				stage.removeChild(currentRoom as DisplayObjectContainer, true);
				currentRoom = null;
			}
			stage.addChild(param1 as DisplayObjectContainer);
			currentRoom = param1;
			currentRoom.stateMachine = this;
			currentRoom.enter();
		}
		
		public function closeCurrentRoom():void
		{
			if (currentRoom != null)
			{
				currentRoom.exit();
				stage.removeChild(currentRoom as DisplayObjectContainer, true);
				currentRoom = null;
			}
		}
		
		public function update(param1:Number = 0):void
		{
			if (currentRoom != null)
			{
				currentRoom.execute();
			}
		}
		
		public function inRoom(param1:Class):Boolean
		{
			return getQualifiedClassName(currentRoom) == getQualifiedClassName(param1);
		}
	}
}
