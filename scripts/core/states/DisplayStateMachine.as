package core.states {
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import starling.display.Sprite;
	
	public class DisplayStateMachine {
		public var parent:Sprite;
		
		private var previousState:IDisplayState;
		
		private var currentState:IDisplayState;
		
		public function DisplayStateMachine(parent:Sprite) {
			super();
			previousState = null;
			currentState = null;
			this.parent = parent;
		}
		
		public function changeState(s:IDisplayState) : void {
			if(currentState != null) {
				currentState.exit();
			}
			previousState = currentState;
			if(s == null) {
				currentState = null;
				return;
			}
			currentState = s;
			currentState.stateMachine = this;
			currentState.enter();
		}
		
		public function revertState() : void {
			changeState(previousState);
		}
		
		public function update(time:Number = 0) : void {
			if(currentState != null) {
				currentState.execute();
			}
		}
		
		public function inState(... rest) : Boolean {
			if(rest[0] is String) {
				return currentState.type == rest[0];
			}
			if(rest[0] is IState || rest[0] is Class) {
				return getQualifiedClassName(currentState) == getQualifiedClassName(Class(getDefinitionByName(getQualifiedClassName(rest[0]))));
			}
			return false;
		}
	}
}

