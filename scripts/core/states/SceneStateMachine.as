package core.states {
	import flash.utils.getQualifiedClassName;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;
	
	public class SceneStateMachine {
		private var currentRoom:ISceneState;
		
		private var profile:ISceneState;
		
		private var stage:Stage;
		
		public function SceneStateMachine(stage:Stage) {
			super();
			currentRoom = null;
			this.stage = stage;
		}
		
		public function changeRoom(s:ISceneState) : void {
			if(currentRoom != null) {
				currentRoom.exit();
				stage.removeChild(currentRoom as DisplayObjectContainer,true);
				currentRoom = null;
			}
			stage.addChild(s as DisplayObjectContainer);
			currentRoom = s;
			currentRoom.stateMachine = this;
			currentRoom.enter();
		}
		
		public function closeCurrentRoom() : void {
			if(currentRoom != null) {
				currentRoom.exit();
				stage.removeChild(currentRoom as DisplayObjectContainer,true);
				currentRoom = null;
			}
		}
		
		public function update(time:Number = 0) : void {
			if(currentRoom != null) {
				currentRoom.execute();
			}
		}
		
		public function inRoom(state:Class) : Boolean {
			return getQualifiedClassName(currentRoom) == getQualifiedClassName(state);
		}
	}
}

