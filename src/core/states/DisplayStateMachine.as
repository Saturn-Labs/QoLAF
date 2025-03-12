package core.states
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import starling.display.Sprite;
	
	public class DisplayStateMachine
	{
		public var parent:Sprite;
		
		private var previousState:IDisplayState;
		
		private var currentState:IDisplayState;
		
		public function DisplayStateMachine(param1:Sprite)
		{
			super();
			previousState = null;
			currentState = null;
			this.parent = param1;
		}
		
		public function changeState(param1:IDisplayState):void
		{
			if (currentState != null)
			{
				currentState.exit();
			}
			previousState = currentState;
			if (param1 == null)
			{
				currentState = null;
				return;
			}
			currentState = param1;
			currentState.stateMachine = this;
			currentState.enter();
		}
		
		public function revertState():void
		{
			changeState(previousState);
		}
		
		public function update(param1:Number = 0):void
		{
			if (currentState != null)
			{
				currentState.execute();
			}
		}
		
		public function inState(... rest):Boolean
		{
			if (rest[0] is String)
			{
				return currentState.type == rest[0];
			}
			if (rest[0] is IState || rest[0] is Class)
			{
				return getQualifiedClassName(currentState) == getQualifiedClassName(Class(getDefinitionByName(getQualifiedClassName(rest[0]))));
			}
			return false;
		}
	}
}
