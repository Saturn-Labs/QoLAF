package core.states
{
   import Clock;
   import debug.Console;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import io.IInput;
   import io.InputLocator;

   public class GameStateMachine
   {
      private var previousState:IGameState;

      private var currentState:IGameState;

      private var currentTime:Number;

      private var newTime:Number;

      private var frameTime:Number;

      private var accumulator:Number = 0;

      private var _clock:Clock;

      private var inputManager:IInput;

      public function GameStateMachine()
      {
         super();
         previousState = null;
         currentState = null;
         inputManager = InputLocator.getService();
      }

      public function changeState(param1:IGameState):void
      {
         var s:IGameState = param1;
         if (currentState == null)
         {
            enterState(s);
            return;
         }
         currentState.exit(function():void
            {
               enterState(s);
            });
      }

      private function enterState(param1:IGameState):void
      {
         previousState = currentState;
         currentState = param1 as IGameState;
         currentState.stateMachine = this;
         currentState.enter();
      }

      public function revertState():void
      {
         changeState(previousState);
      }

      public function update(param1:Number = 0):void
      {
         if (_clock == null)
         {
            return;
         }
         newTime = _clock.time;
         frameTime = newTime - currentTime;
         currentTime = newTime;
         if (frameTime > 10000)
         {
            frameTime = 10000;
         }
         accumulator += frameTime;
         while (accumulator >= 33)
         {
            if (currentState != null)
            {
               currentState.tickUpdate();
            }
            accumulator -= 33;
         }
         if (currentState != null && currentState.loaded)
         {
            if (previousState == null || previousState.unloaded)
            {
               currentState.execute();
            }
         }
         inputManager.reset();
      }

      public function set clock(param1:Clock):void
      {
         this._clock = param1;
         currentTime = param1.time;
      }

      public function inState(...rest):Boolean
      {
         if (rest[0] is IGameState || rest[0] is Class)
         {
            return getQualifiedClassName(currentState) == getQualifiedClassName(Class(getDefinitionByName(getQualifiedClassName(rest[0]))));
         }
         return false;
      }

      public function dispose():void
      {
         previousState = null;
         if (currentState == null)
         {
            Console.write("no state to clean");
            return;
         }
         currentState.exit(function():void
            {
            });
         currentState = null;
      }
   }
}
