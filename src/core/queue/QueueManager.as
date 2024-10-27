package core.queue
{
   import core.hud.components.dialogs.PopupMessage;
   import core.scene.Game;
   import playerio.Message;
   import starling.events.Event;

   public class QueueManager
   {
      public static const TYPE_PVP:String = "pvp";

      public static const TYPE_PVP_DM:String = "pvp dm";

      public static const TYPE_PVP_DOMINATION:String = "pvp dom";

      public static const TYPE_PVP_ARENA:String = "pvp arena";

      public static const TYPE_PVP_ARENA_RANKED:String = "pvp arena ranked";

      public static const TYPE_PVP_RANDOM:String = "pvp random";

      public static const TYPE_INSTANCE:String = "instance";

      public var g:Game;

      public var queues:Vector.<QueueInfoHolder>;

      public function QueueManager(param1:Game)
      {
         super();
         this.g = param1;
         queues = new Vector.<QueueInfoHolder>();
         queues.push(new QueueInfoHolder(param1, "pvp random"));
         param1.addServiceMessageHandler("QueueJoinSuccess", joinedQueue);
         param1.addServiceMessageHandler("QueueJoinFailed", joinFailed);
         param1.addServiceMessageHandler("QueueLeaveSuccess", leftQueue);
         param1.addServiceMessageHandler("QueueLeaveFailed", leaveFailed);
         param1.addServiceMessageHandler("QueueReady", queueReady);
         param1.addServiceMessageHandler("JoinMatch", joinMatch);
         param1.addServiceMessageHandler("QueueRemoved", removedFromQueue);
         param1.rpcServiceRoom("RequestQueueInfo", handleQueueInfo);
      }

      public function handleQueueInfo(param1:Message):void
      {
         var _loc6_:int = 0;
         var _loc5_:String = null;
         var _loc4_:Boolean = false;
         var _loc2_:Number = NaN;
         var _loc3_:QueueInfoHolder = null;
         _loc6_ = 0;
         while (_loc6_ < param1.length - 2)
         {
            _loc5_ = param1.getString(_loc6_);
            _loc4_ = param1.getBoolean(_loc6_ + 1);
            _loc2_ = param1.getNumber(_loc6_ + 2);
            if (_loc4_)
            {
               _loc3_ = getQueue(_loc5_);
               _loc3_.isInQueue = true;
               _loc3_.isWaiting = false;
               _loc3_.isReady = false;
               _loc3_.accepted = false;
               _loc3_.startTime = _loc2_;
            }
            _loc6_ += 3;
         }
      }

      public function removedFromAllQueues():void
      {
         for each (var _loc1_:* in queues)
         {
            _loc1_.isInQueue = false;
            _loc1_.isWaiting = false;
            _loc1_.isReady = false;
         }
      }

      public function removedFromQueue(param1:Message):void
      {
         var _loc3_:String = param1.getString(0);
         for each (var _loc2_:* in queues)
         {
            if (_loc2_.type == _loc3_)
            {
               _loc2_.isInQueue = false;
               _loc2_.isWaiting = false;
               _loc2_.isReady = false;
            }
         }
      }

      public function queueReady(param1:Message):void
      {
         var _loc2_:int = 0;
         var _loc4_:String = param1.getString(0);
         for each (var _loc3_:* in queues)
         {
            if (_loc3_.type == _loc4_)
            {
               _loc2_ = Math.ceil(0.001 * (g.time - _loc3_.startTime));
               if (_loc2_ > 0 && _loc2_ < 1000000)
               {
                  Game.trackEvent("pvp", "queue", "ready", _loc2_);
               }
               _loc3_.startTime = g.time;
               _loc3_.isInQueue = false;
               _loc3_.isWaiting = false;
               _loc3_.isReady = true;
               _loc3_.createAcceptPopup();
               break;
            }
         }
      }

      public function joinMatch(param1:Message):void
      {
         var _loc3_:String = param1.getString(0);
         var _loc2_:String = param1.getString(1);
         var _loc4_:String = param1.getString(2);
         g.tryJoinMatch(_loc2_, _loc4_);
      }

      public function joinedQueue(param1:Message):void
      {
         var errorPopup:PopupMessage;
         var qi:QueueInfoHolder;
         var m:Message = param1;
         var type:String = m.getString(0);
         var reason:String = m.getString(1);
         var resetOthers:Boolean = m.getBoolean(2);
         if (reason != null && reason != "")
         {
            errorPopup = new PopupMessage();
            errorPopup.text = reason;
            g.addChildToOverlay(errorPopup);
            errorPopup.addEventListener("close", (function():*
                  {
                     var closePopup:Function;
                     return closePopup = function(param1:Event):void
                     {
                        g.removeChildFromOverlay(errorPopup);
                        errorPopup.removeEventListeners();
                     };
                  })());
         }
         for each (qi in queues)
         {
            if (qi.type == type)
            {
               qi.startTime = g.time;
               qi.isInQueue = true;
               qi.isWaiting = false;
               qi.isReady = false;
               qi.accepted = false;
               qi.startTime = g.time;
            }
         }
      }

      public function joinFailed(param1:Message):void
      {
         var errorPopup:PopupMessage;
         var qi:QueueInfoHolder;
         var m:Message = param1;
         var type:String = m.getString(0);
         var reason:String = m.getString(1);
         if (reason != null && reason != "")
         {
            errorPopup = new PopupMessage();
            errorPopup.text = reason;
            g.addChildToOverlay(errorPopup);
            errorPopup.addEventListener("close", (function():*
                  {
                     var closePopup:Function;
                     return closePopup = function(param1:Event):void
                     {
                        g.removeChildFromOverlay(errorPopup);
                        errorPopup.removeEventListeners();
                     };
                  })());
         }
         for each (qi in queues)
         {
            if (qi.type == type)
            {
               qi.isWaiting = false;
               qi.isInQueue = false;
               qi.accepted = false;
               qi.isReady = false;
               qi.update();
            }
         }
      }

      public function update():void
      {
         for each (var _loc1_:* in queues)
         {
            _loc1_.update();
         }
      }

      public function leftQueue(param1:Message):void
      {
         var _loc3_:String = param1.getString(0);
         for each (var _loc2_:* in queues)
         {
            if (_loc2_.type == _loc3_)
            {
               _loc2_.isInQueue = false;
               _loc2_.isWaiting = false;
               _loc2_.isReady = false;
            }
         }
      }

      public function leaveFailed(param1:Message):void
      {
         var _loc3_:String = param1.getString(0);
         for each (var _loc2_:* in queues)
         {
            if (_loc2_.type == _loc3_)
            {
               _loc2_.isInQueue = false;
               _loc2_.isWaiting = false;
               _loc2_.isReady = false;
            }
         }
      }

      public function getQueue(param1:String):QueueInfoHolder
      {
         for each (var _loc2_:* in queues)
         {
            if (_loc2_.type == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }

      private function containsQueue(param1:String):Boolean
      {
         for each (var _loc2_:* in queues)
         {
            if (_loc2_.type == param1)
            {
               return true;
            }
         }
         return false;
      }
   }
}
