package core.states.AIStates
{
   import core.boss.Boss;
   import core.scene.Game;
   import core.states.IState;
   import core.states.StateMachine;
   import core.turret.Turret;
   import core.unit.Unit;
   import core.weapon.Beam;
   import core.weapon.Weapon;
   import flash.geom.Point;

   public class AIBoss implements IState
   {
      private var b:Boss;

      private var g:Game;

      private var courseSendTime:Number;

      private var courseSendInterval:Number = 3000;

      private var rotationSpeedCurrent:Number = 0;

      private var nextRegen:Number;

      private var sm:StateMachine;

      public function AIBoss(param1:Game, param2:Boss)
      {
         super();
         this.g = param1;
         this.b = param2;
      }

      public function enter():void
      {
         b.course.accelerate = true;
         nextRegen = g.time + 1000;
         courseSendTime = g.time + courseSendInterval;
      }

      public function execute():void
      {
         var _loc1_:Weapon = null;
         var _loc4_:Beam = null;
         if (!b.alive)
         {
            return;
         }
         if (nextRegen < g.time)
         {
            for each (var _loc2_:* in b.allComponents)
            {
               if (_loc2_.alive && _loc2_.active && _loc2_.hp < _loc2_.hpMax && _loc2_.disableHealEndtime < g.time)
               {
                  _loc2_.hp += b.hpRegen;
                  if (_loc2_.hp > _loc2_.hpMax)
                  {
                     _loc2_.hp = _loc2_.hpMax;
                  }
               }
            }
			// QoLAF
            //g.hud.bossHealth.update();
            nextRegen = g.time + 1000;
         }
         if (b.teleportExitTime != 0)
         {
            if (b.teleportExitTime < g.time)
            {
               b.overrideConvergeTarget(b.teleportExitPoint.x, b.teleportExitPoint.y);
               b.teleportExitTime = 0;
               b.endTeleportEffect();
               return;
            }
            b.course.accelerate = false;
            return;
         }
         if (b.bodyTarget != null && b.bodyDestroyStart != 0)
         {
            if (b.bodyDestroyEnd != 0 && b.bodyDestroyEnd < g.time)
            {
               b.bodyTarget.explode();
               b.bodyTarget = null;
               b.bodyDestroyStart = 0;
               b.bodyDestroyEnd = 0;
            }
            for each (var _loc3_:* in b.turrets)
            {
               _loc1_ = _loc3_.weapon;
               if (_loc1_ is Beam)
               {
                  _loc4_ = _loc1_ as Beam;
                  _loc4_.fireAtBody(b.bodyTarget);
               }
            }
         }
         if (b.target == null)
         {
            if (b.currentWaypoint != null)
            {
               b.course.accelerate = true;
               b.angleTargetPos = b.currentWaypoint.pos;
            }
            else
            {
               b.course.accelerate = false;
               b.angleTargetPos = null;
            }
         }
         else
         {
            b.course.accelerate = true;
            b.angleTargetPos = new Point(b.target.pos.x, b.target.pos.y);
         }
         b.updateHeading(b.course);
         if (b.holonomic || b.rotationForced)
         {
            if (b.rotationSpeed > 0 && rotationSpeedCurrent < b.rotationSpeed || b.rotationSpeed < 0 && rotationSpeedCurrent > b.rotationSpeed)
            {
               rotationSpeedCurrent += 0.05 * b.rotationSpeed;
            }
            b.course.rotation += rotationSpeedCurrent * 33 / 1000;
         }
         b.x = b.course.pos.x;
         b.y = b.course.pos.y;
         b.rotation = b.course.rotation;
      }

      public function exit():void
      {
      }

      public function set stateMachine(param1:StateMachine):void
      {
         this.sm = param1;
      }

      public function get type():String
      {
         return "AIChase";
      }
   }
}
