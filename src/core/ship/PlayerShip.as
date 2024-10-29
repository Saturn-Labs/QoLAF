package core.ship
{
   import core.deathLine.DeathLine;
   import core.hud.components.Style;
   import core.hud.components.TextBitmap;
   import core.particle.Emitter;
   import core.particle.EmitterFactory;
   import core.player.Player;
   import core.scene.Game;
   import core.scene.SceneBase;
   import core.states.ship.Intro;
   import core.states.ship.Roaming;
   import core.states.ship.WarpJump;
   import core.weapon.Heat;
   import core.weapon.Weapon;
   import debug.Console;
   import movement.Command;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.filters.DropShadowFilter;
   import starling.textures.Texture;
   import textures.ITextureManager;
   import textures.TextureLocator;

   public class PlayerShip extends Ship
   {
      public var player:Player;

      public var weaponIsChanging:Boolean;

      public var weaponHeat:Heat;

      public var hasBoost:Boolean;

      public var boostCD:int;

      public var boostDuration:int;

      public var boostNextRdy:Number;

      public var ticksOfBoost:int;

      public var totalTicksOfBoost:int;

      public var boostEndedLastTick:Boolean;

      private var _landed:Boolean;

      public var maxPower:Number;

      public var powerRegBonus:Number;

      private var boostEndTime:Number;

      private var regenerateNextTime:Number;

      public var channelingEnd:Number;

      public var hasArmorConverter:Boolean;

      public var convCost:int;

      public var convGain:int;

      public var convCD:int;

      public var convNextRdy:Number;

      public var hasHardenedShield:Boolean;

      public var hardenMaxDmg:int;

      public var hardenCD:int;

      public var hardenDuration:int;

      public var hardenNextRdy:Number;

      public var hardenEndTimer:Number;

      public var usingHardenedShield:Boolean;

      public var hpBase:int;

      public var shieldHpBase:int;

      public var activeWeapons:int;

      public var unlockedWeaponSlots:int;

      private var quadEndTime:Number;

      private var quadEffect:Vector.<Emitter>;

      private var speedBoostEffect:Vector.<Emitter>;

      private var dmgBoostEffect:Vector.<Emitter>;

      private var hardenedShieldEffect:Vector.<Emitter>;

      private var killingSpreeEffect:Vector.<Emitter>;

      private var chargeUpEffect:Vector.<Emitter>;

      private var pvpPositionText:TextBitmap;

      private var nameText:TextBitmap;

      private var levelText:TextBitmap;

      private var supporterIcon:Image;

      private var aritfact_hp_base:int;

      private var aritfact_shield_base:int;

      private var aritfact_regen_base:int;

      public var aritfact_convAmount:Number;

      public var aritfact_cooldownReduction:Number;

      public var aritfact_speed:Number;

      public var aritfact_poweReg:Number;

      public var aritfact_powerMax:Number;

      public var aritfact_refire:Number;

      private var shadowImage:Image;

      public var hideShadow:Boolean = false;

      private var lastSafeY:Number = 0;

      private var lastSafeX:Number = 0;

      private var isInMelee:Boolean = false;

      private var tryMelee:Boolean = false;

      private var meleeDuration:Number = 0;

      public function PlayerShip(param1:Game)
      {
         quadEffect = new Vector.<Emitter>();
         speedBoostEffect = new Vector.<Emitter>();
         dmgBoostEffect = new Vector.<Emitter>();
         hardenedShieldEffect = new Vector.<Emitter>();
         killingSpreeEffect = new Vector.<Emitter>();
         chargeUpEffect = new Vector.<Emitter>();
         canvas = param1.canvasPlayerShips;
         weapons = new Vector.<Weapon>();
         weaponIsChanging = false;
         weaponHeat = new Heat(param1, this);
         super(param1);
         nameText = new TextBitmap(0, 0, "", 13);
         nameText.alpha = 0.8;
         nameText.format.color = 4491519;
         nameText.format.horizontalAlign = "left";
         nameText.batchable = true;
         nameText.blendMode = "add";
         levelText = new TextBitmap(0, 0, "", 13);
         levelText.alpha = 0.8;
         levelText.format.horizontalAlign = "left";
         levelText.batchable = true;
         levelText.blendMode = "add";
         pvpPositionText = new TextBitmap(0, 0, "", 16);
         pvpPositionText.alpha = 0.8;
         pvpPositionText.format.horizontalAlign = "left";
         pvpPositionText.batchable = true;
         pvpPositionText.blendMode = "add";
         var _loc2_:ITextureManager = TextureLocator.getService();
         supporterIcon = new Image(_loc2_.getTextureGUIByTextureName("icon_supporter"));
         aritfact_hp_base = 0;
         aritfact_shield_base = 0;
         aritfact_regen_base = 0;
      }

      override public function regenerateShield():void
      {
         if (alive)
         {
            if (shieldRegenCounter >= shieldRegenDuration)
            {
               shieldRegenCounter = 0;
               shieldHp += int(1.75 * (shieldRegen + shieldRegenBonus));
               if (shieldHp > _shieldHpMax)
               {
                  shieldHp = _shieldHpMax;
               }
               if (player.isMe)
               {
                  g.hud.healthAndShield.update();
               }
            }
            shieldRegenCounter += 33;
         }
      }

      override public function regenerateHP():void
      {
         if (alive && disableHealEndtime < g.time)
         {
            if (hpRegenCounter >= hpRegenDuration)
            {
               hpRegenCounter = 0;
               hp += int(hpRegen * hpMax + 0.5);
               if (hp > hpMax)
               {
                  hp = hpMax;
               }
               if (player.isMe)
               {
                  g.hud.healthAndShield.update();
               }
            }
            hpRegenCounter += 33;
         }
      }

      public function removeConvert():void
      {
         if (aritfact_convAmount != 0)
         {
            hpMax = aritfact_hp_base;
            hp = hpMax;
            _shieldHpMax = aritfact_shield_base;
            shieldHp = _shieldHpMax;
            shieldRegenBonus = 0;
         }
      }

      public function addConvert():void
      {
         aritfact_hp_base = hpMax;
         aritfact_shield_base = _shieldHpMax;
         aritfact_regen_base = shieldRegen;
         var _loc1_:Number = aritfact_convAmount;
         if (_loc1_ > 1)
         {
            _loc1_ = 0.99;
         }
         else if (_loc1_ < -1)
         {
            _loc1_ = -0.99;
         }
         if (_loc1_ > 0)
         {
            hpMax += int(shieldHpMax * (1.5 * _loc1_));
            if (hpMax < 1)
            {
               hpMax = 1;
               hp = 1;
            }
            if (player.inSafeZone || hp > hpMax)
            {
               hp = hpMax;
            }
            shieldHpMax *= 1 - _loc1_;
            if (shieldHpMax < 1)
            {
               shieldHpMax = 1;
            }
            if (player.inSafeZone || shieldHp > shieldHpMax)
            {
               shieldHp = shieldHpMax;
            }
         }
         else
         {
            shieldHpMax -= int(hpMax * (1.5 * _loc1_));
            shieldRegenBonus = -(int(0.01 * hpMax * _loc1_ * shieldRegen / shieldRegenBase));
            if (shieldHpMax <= 0)
            {
               shieldHpMax = 1;
            }
            if (player.inSafeZone || shieldHp > shieldHpMax)
            {
               shieldHp = shieldHpMax;
            }
            hpMax *= 1 + _loc1_;
            if (hpMax < 1)
            {
               hpMax = 1;
               hp = 1;
            }
            if (player.inSafeZone || hp > hpMax)
            {
               hp = hpMax;
            }
         }
      }

      override public function switchTexturesByObj(param1:Object, param2:String = "texture_main_NEW.png"):void
      {
         super.switchTexturesByObj(param1, param2);
         if (!SceneBase.settings.showEffects)
         {
            return;
         }
         if (hideShadow)
         {
            return;
         }
         shadowImage = new Image(movieClip.texture);
         shadowImage.color = 0;
         shadowImage.pivotX = shadowImage.texture.width / 2;
         shadowImage.pivotY = shadowImage.texture.height / 2;
         shadowImage.filter = new DropShadowFilter(3, 0.785, 0, 0.7, 4);
         shadowImage.filter.cache();
      }

      override public function update():void
      {
         if (!alive || landed || player.isLanded)
         {
            return;
         }
         weaponHeat.update();
         if (hardenEndTimer < g.time && usingHardenedShield)
         {
            usingHardenedShield = false;
            for each (var _loc1_:* in hardenedShieldEffect)
            {
               _loc1_.killEmitter();
            }
         }
         if (quadEndTime < g.time && quadEndTime != 0)
         {
            quadEndTime = 0;
            for each (_loc1_ in quadEffect)
            {
               _loc1_.killEmitter();
            }
            quadEffect.splice(0, quadEffect.length);
         }
         if (dmgBoostEndTime < g.time && usingDmgBoost)
         {
            usingDmgBoost = false;
            for each (_loc1_ in dmgBoostEffect)
            {
               _loc1_.killEmitter();
            }
         }
         safeZoneRegeneration();
         super.update();
      }

      private function safeZoneRegeneration():void
      {
         var _loc1_:Number = NaN;
         if (player.inSafeZone && regenerateNextTime < g.time)
         {
            shieldHp += Math.ceil(shieldHpMax / 10);
            if (shieldHp > shieldHpMax)
            {
               shieldHp = shieldHpMax;
            }
            hp += Math.ceil(hpMax / 10);
            if (hp > hpMax)
            {
               hp = hpMax;
            }
            regenerateNextTime = g.time + 1000;
         }
      }

      public function updateHeading():void
      {
         var _loc4_:* = undefined;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:DeathLine = null;
         if (alive && course != null)
         {
            if (_usingBoost && g.time > boostEndTime)
            {
               for each (var _loc1_:* in speedBoostEffect)
               {
                  _loc1_.killEmitter();
               }
               Console.write("Stopped boost");
               _usingBoost = false;
               boostEndedLastTick = true;
            }
            runConverger();
            if (lastSafeX == 0 && lastSafeY == 0)
            {
               lastSafeX = pos.x;
               lastSafeY = pos.y;
            }
            if (course.accelerate)
            {
               engine.accelerate();
            }
            else
            {
               engine.idle();
            }
            if (player.isWarpJumping == false)
            {
               _loc4_ = g.deathLineManager.lines;
               _loc2_ = int(_loc4_.length);
               _loc5_ = 0;
               while (_loc5_ < _loc2_)
               {
                  _loc3_ = _loc4_[_loc5_];
                  if (_loc3_.lineIntersection2(course.pos.x, course.pos.y, lastSafeX, lastSafeY, collisionRadius))
                  {
                     course.pos.x = lastSafeX;
                     course.pos.y = lastSafeY;
                     course.speed.x = 0;
                     course.speed.y = 0;
                     return;
                  }
                  _loc5_++;
               }
               lastSafeX = course.pos.x;
               lastSafeY = course.pos.y;
            }
         }
      }

      public function damageBoostEffect():void
      {
         dmgBoostEffect = EmitterFactory.create("PI3sUBPqwESqkJ2LBoTRJA", g, pos.x, pos.y, this, true);
      }

      private function boostEffect():void
      {
         speedBoostEffect = EmitterFactory.create("FWSygsW1x0q2sKlULeGZMA", g, pos.x, pos.y, this, true);
      }

      public function dmgBoost():void
      {
         usingDmgBoost = true;
         if (aritfact_cooldownReduction > 0.4)
         {
            dmgBoostNextRdy = g.time + dmgBoostCD * 0.6;
         }
         else
         {
            dmgBoostNextRdy = g.time + dmgBoostCD * (1 - aritfact_cooldownReduction);
         }
         dmgBoostEndTime = g.time + dmgBoostDuration;
         damageBoostEffect();
      }

      public function boost():void
      {
         Console.write("-BOOST-");
         _usingBoost = true;
         if (aritfact_cooldownReduction > 0.4)
         {
            boostNextRdy = g.time + boostCD * 0.6;
         }
         else
         {
            boostNextRdy = g.time + boostCD * (1 - aritfact_cooldownReduction);
         }
         Console.write("boostDuration: " + boostDuration);
         boostEndTime = g.time + boostDuration;
         Console.write("boostEndTime: " + boostEndTime);
         boostEffect();
      }

      public function startKillingSpreeEffect():void
      {
         killingSpreeEffect = EmitterFactory.create("Go4yOCnz40u-tQvx7g9wNg", g, pos.x, pos.y, this, true);
      }

      public function hardenShieldEffect():void
      {
         hardenedShieldEffect = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw", g, pos.x, pos.y, this, true);
      }

      public function startQuadEffect():void
      {
         var _loc1_:* = null;
         if (quadEffect.length > 0)
         {
            for each (_loc1_ in quadEffect)
            {
               _loc1_.killEmitter();
            }
         }
         quadEffect = EmitterFactory.create("uRAuUGfT40SlGCU7X8w3uQ", g, pos.x, pos.y, this, true);
      }

      public function startChargeUpEffect(param1:String = "uWIxfxRAgUm6ThgrRFnixw"):void
      {
         chargeUpEffect = EmitterFactory.create(param1, g, pos.x, pos.y, this, true);
      }

      public function killChargeUpEffect():void
      {
         for each (var _loc1_:* in chargeUpEffect)
         {
            _loc1_.killEmitter();
         }
      }

      public function useQuad(param1:Number):void
      {
         quadEndTime = param1;
         startQuadEffect();
      }

      public function hardenShield():void
      {
         usingHardenedShield = true;
         hardenEndTimer = g.time + hardenDuration;
         if (aritfact_cooldownReduction > 0.4)
         {
            hardenNextRdy = g.time + hardenCD * 0.6;
         }
         else
         {
            hardenNextRdy = g.time + hardenCD * (1 - aritfact_cooldownReduction);
         }
         hardenShieldEffect();
      }

      public function converShieldEffect():void
      {
         EmitterFactory.create("4QGYSaBeX0ytftBD9hs4bg", g, pos.x, pos.y, this, true);
      }

      public function convertShield():void
      {
         if (aritfact_cooldownReduction > 0.4)
         {
            convNextRdy = g.time + convCD * 0.6;
         }
         else
         {
            convNextRdy = g.time + convCD * (1 - aritfact_cooldownReduction);
         }
      }

      override public function reset():void
      {
         removeMeleeTextures();
         weapons = new Vector.<Weapon>();
         weaponHeat = new Heat(g, this);
         hasBoost = false;
         boostCD = 0;
         boostDuration = 0;
         boostNextRdy = 0;
         ticksOfBoost = 0;
         totalTicksOfBoost = 0;
         isAddedToCanvas = false;
         hideShadow = false;
         hasArmorConverter = false;
         convCost = 0;
         convGain = 0;
         convCD = 0;
         convNextRdy = 0;
         quadEndTime = 0;
         hasHardenedShield = false;
         usingHardenedShield = false;
         hardenMaxDmg = 0;
         hardenCD = 0;
         hardenDuration = 0;
         hardenNextRdy = 0;
         hardenEndTimer = 0;
         nameText.text = "";
         _landed = false;
         regenerateNextTime = 0;
         if (shadowImage)
         {
            if (shadowImage.filter)
            {
               shadowImage.filter.dispose();
            }
            shadowImage.filter = null;
            shadowImage = null;
         }
         isInMelee = false;
         tryMelee = false;
         meleeDuration = 0;
         pvpPositionText.text = "";
         super.reset();
      }

      public function enterRoaming():void
      {
         updateLabel();
         if (!stateMachine.inState(Roaming))
         {
            stateMachine.changeState(new Roaming(this));
         }
      }

      public function enterWarpJump():void
      {
         if (!stateMachine.inState(WarpJump))
         {
            stateMachine.changeState(new WarpJump(g, this));
         }
      }

      public function enterIntro(param1:Number, param2:Number):void
      {
         if (!stateMachine.inState(Intro))
         {
            stateMachine.changeState(new Intro(g, this, param1, param2));
         }
      }

      override public function destroy(param1:Boolean = true):void
      {
         super.destroy(param1);
         for each (var _loc2_:* in weapons)
         {
            _loc2_.destroy();
         }
      }

      public function land():void
      {
         _landed = true;
         engine.destroy();
      }

      public function get landed():Boolean
      {
         return _landed;
      }

      override public function draw():void
      {
         if (landed)
         {
            return;
         }
         super.draw();
         nameText.x = _mc.x - nameText.width * 0.5;
         nameText.y = _mc.y - _mc.pivotY - 20;
         levelText.x = nameText.x + nameText.width;
         levelText.y = nameText.y;
         supporterIcon.x = nameText.x - 15;
         supporterIcon.y = nameText.y + 3;
         if (shadowImage != null)
         {
            shadowImage.x = _mc.x;
            shadowImage.y = _mc.y;
            shadowImage.rotation = _mc.rotation;
            shadowImage.scaleX = _mc.scaleX;
            shadowImage.scaleY = _mc.scaleY;
         }
         if (pvpPositionText != null)
         {
            pvpPositionText.x = _mc.x;
            pvpPositionText.y = _mc.y - _mc.pivotY - 50;
         }
      }

      public function runCommand(param1:Command):void
      {
         switch (param1.type - 3)
         {
            case 0:
               if (weapon != null)
               {
                  this.weapon.fire = param1.active;
               }
               break;
            default:
               course.runCommand(param1);
         }
      }

      public function get weapon():Weapon
      {
         if (player == null || weapons == null)
         {
            return null;
         }
         if (player.selectedWeaponIndex > -1 && player.selectedWeaponIndex < weapons.length)
         {
            return weapons[player.selectedWeaponIndex];
         }
         return null;
      }

      public function get isShooting():Boolean
      {
         for each (var _loc1_:* in weapons)
         {
            if (_loc1_.fire)
            {
               return true;
            }
         }
         return false;
      }

      public function hideStats():void
      {
         nameText.visible = false;
      }

      override public function get type():String
      {
         return "playerShip";
      }

      public function setIsHostile(param1:Boolean):void
      {
         isHostile = param1;
         updateLabel();
      }

      override public function set name(param1:String):void
      {
         super.name = param1;
         updateLabel();
      }

      public function updateLabel():void
      {
         if (g.me == null || player == null)
         {
            return;
         }
         if (player == g.me)
         {
            nameText.format.color = Style.COLOR_LIGHT_GREEN;
         }
         else if (g.isSystemTypeDeathMatch())
         {
            nameText.format.color = Style.COLOR_HOSTILE;
         }
         else if (g.isSystemTypeDomination())
         {
            nameText.format.color = player.team == g.me.team ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
         }
         else if (g.isSystemPvPEnabled())
         {
            nameText.format.color = player.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
         }
         else
         {
            nameText.format.color = player.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_FRIENDLY;
         }
         nameText.text = name;
         levelText.text = level.toString();
         if (player && player.isDeveloper)
         {
            levelText.text = "dev";
         }
      }

      override public function addToCanvas():void
      {
         if (landed)
         {
            return;
         }
         if (shadowImage != null)
         {
            g.canvasPlayerShips.addChild(shadowImage);
         }
         super.addToCanvas();
         updateLabel();
         if (g.me == this.player)
         {
            hpBar.visible = false;
            shieldBar.visible = false;
            return;
         }
         if (player.hasSupporter())
         {
            g.canvasPlayerShips.addChild(supporterIcon);
         }
         g.canvasTexts.addChild(nameText);
         g.canvasTexts.addChild(levelText);
      }

      override public function addToCanvasForReal():void
      {
         if (landed)
         {
            return;
         }
         if (shadowImage != null)
         {
            g.canvasPlayerShips.addChild(shadowImage);
         }
         super.addToCanvasForReal();
         updateLabel();
         if (g.me == this.player)
         {
            return;
         }
         if (player.hasSupporter())
         {
            g.canvasPlayerShips.addChild(supporterIcon);
         }
         g.canvasTexts.addChild(nameText);
         g.canvasTexts.addChild(levelText);
      }

      override public function removeFromCanvas():void
      {
         super.removeFromCanvas();
         if (shadowImage != null)
         {
            g.canvasPlayerShips.removeChild(shadowImage);
         }
         if (g.me == this.player)
         {
            return;
         }
         g.canvasPlayerShips.removeChild(supporterIcon);
         g.canvasTexts.removeChild(nameText);
         g.canvasTexts.removeChild(levelText);
      }

      public function triggerMeleeTextures(param1:Number):void
      {
         tryMelee = true;
         if (isInMelee || !alive)
         {
            return;
         }
         Starling.juggler.remove(_mc);
         var _loc2_:Vector.<Texture> = TextureLocator.getService().getTexturesMainByTextureName(imgObj.textureName.replace("normal", "melee"));
         swapFrames(_mc, _loc2_);
         _mc.fps = 1 / param1 * _loc2_.length;
         _mc.readjustSize();
         Starling.juggler.add(_mc);
         _mc.pivotX = _mc.texture.width / 2;
         _mc.pivotY = _mc.texture.height / 2;
         meleeDuration = param1;
         Starling.juggler.delayCall(removeMeleeTextures, meleeDuration);
         tryMelee = false;
         isInMelee = true;
      }

      private function removeMeleeTextures():void
      {
         if (!isInMelee)
         {
            return;
         }
         if (tryMelee)
         {
            Starling.juggler.delayCall(removeMeleeTextures, meleeDuration);
            tryMelee = false;
            return;
         }
         isInMelee = false;
         Starling.juggler.remove(_mc);
         var _loc1_:Vector.<Texture> = TextureLocator.getService().getTexturesMainByTextureName(imgObj.textureName);
         swapFrames(_mc, _loc1_);
         _mc.fps = 33 / imgObj.animationDelay;
         _mc.readjustSize();
         Starling.juggler.add(_mc);
         _mc.pivotX = _mc.texture.width / 2;
         _mc.pivotY = _mc.texture.height / 2;
      }
   }
}
