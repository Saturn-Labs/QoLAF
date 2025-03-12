package core.states
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class StateMachine
	{
		private var previousState:IState;
		
		private var currentState:IState;
		
		public function StateMachine()
		{
			super();
			previousState = null;
			currentState = null;
		}
		
		public function changeState(param1:IState):void
		{
			if (currentState != null)
			{
				currentState.exit();
			}
			previousState = currentState;
			if (param1 == null)
			{
				return;
			}
			currentState = param1;
			currentState.stateMachine = this;
			currentState.enter();
		}
		
		public function exitCurrent():void
		{
			if (currentState != null)
			{
				currentState.exit();
			}
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
			if (currentState == null)
			{
				return false;
			}
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
