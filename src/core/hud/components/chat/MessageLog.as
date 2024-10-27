package core.hud.components.chat
{
   import com.adobe.utils.StringUtil;
   import core.hud.components.ImageButton;
   import core.player.Player;
   import core.scene.Game;
   import core.scene.SceneBase;
   import starling.display.DisplayObjectContainer;
   import starling.events.Event;
   import starling.textures.Texture;
   import textures.ITextureManager;
   import textures.TextureLocator;

   public class MessageLog extends DisplayObjectContainer
   {
      private static var g:Game;

      public static var extendedMaxLines:int = 60;

      public static var textQueue:Vector.<Object> = new Vector.<Object>();

      private static var profanities:Object = {
            "4r5e": 1,
            "5h1t": 1,
            "5hit": 1,
            "a55": 1,
            "anal": 1,
            "anus": 1,
            "ar5e": 1,
            "arrse": 1,
            "arse": 1,
            "ass-fucker": 1,
            "asses": 1,
            "assfucker": 1,
            "assfukka": 1,
            "asshole": 1,
            "assholes": 1,
            "asswhole": 1,
            "a_s_s": 1,
            "b!tch": 1,
            "b00bs": 1,
            "b17ch": 1,
            "b1tch": 1,
            "ballbag": 1,
            "ballsack": 1,
            "bastard": 1,
            "beastial": 1,
            "beastiality": 1,
            "bellend": 1,
            "bestial": 1,
            "bestiality": 1,
            "biatch": 1,
            "bitch": 1,
            "bitcher": 1,
            "bitchers": 1,
            "bitches": 1,
            "bitchin": 1,
            "bitching": 1,
            "blow job": 1,
            "blowjob": 1,
            "blowjobs": 1,
            "boiolas": 1,
            "bollock": 1,
            "bollok": 1,
            "boner": 1,
            "boob": 1,
            "boobs": 1,
            "booobs": 1,
            "boooobs": 1,
            "booooobs": 1,
            "booooooobs": 1,
            "breasts": 1,
            "buceta": 1,
            "bunny fucker": 1,
            "butthole": 1,
            "buttmuch": 1,
            "buttplug": 1,
            "c0ck": 1,
            "c0cksucker": 1,
            "carpet muncher": 1,
            "cawk": 1,
            "chink": 1,
            "cipa ": 1,
            "cl1t": 1,
            "clit": 1,
            "clitoris": 1,
            "clits": 1,
            "cnut": 1,
            "cock": 1,
            "cock-sucker": 1,
            "cockface": 1,
            "cockhead": 1,
            "cockmunch": 1,
            "cockmuncher": 1,
            "cocks": 1,
            "cocksuck ": 1,
            "cocksucked ": 1,
            "cocksucker": 1,
            "cocksucking": 1,
            "cocksucks ": 1,
            "cocksuka": 1,
            "cocksukka": 1,
            "cokmuncher": 1,
            "coksucka": 1,
            "cox": 1,
            " cum ": 1,
            "cummer": 1,
            "cumming": 1,
            "cums": 1,
            "cumshot": 1,
            "cunilingus": 1,
            "cunillingus": 1,
            "cunnilingus": 1,
            "cunt": 1,
            "cuntlick ": 1,
            "cuntlicker ": 1,
            "cuntlicking ": 1,
            "cunts": 1,
            "cyalis": 1,
            "cyberfuc": 1,
            "cyberfuck ": 1,
            "cyberfucked ": 1,
            "cyberfucker": 1,
            "cyberfuckers": 1,
            "cyberfucking ": 1,
            "d1ck": 1,
            "dick": 1,
            "dickhead": 1,
            "dildo": 1,
            "dildos": 1,
            "dink": 1,
            "dinks": 1,
            "dirsa": 1,
            "dlck": 1,
            "dog-fucker": 1,
            "doggin": 1,
            "dogging": 1,
            "donkeyribber": 1,
            "dyke": 1,
            "ejaculate": 1,
            "ejaculated": 1,
            "ejaculates ": 1,
            "ejaculating ": 1,
            "ejaculatings": 1,
            "ejaculation": 1,
            "ejakulate": 1,
            "f u c k": 1,
            "f u c k e r": 1,
            "f4nny": 1,
            "fag": 1,
            "fagging": 1,
            "faggitt": 1,
            "faggot": 1,
            "faggs": 1,
            "fagot": 1,
            "fagots": 1,
            "fags": 1,
            "fanny": 1,
            "fannyflaps": 1,
            "fannyfucker": 1,
            "fanyy": 1,
            "fatass": 1,
            "fcuk": 1,
            "fcuker": 1,
            "fcuking": 1,
            "feck": 1,
            "fecker": 1,
            "felching": 1,
            "fellate": 1,
            "fellatio": 1,
            "fingerfuck ": 1,
            "fingerfucked ": 1,
            "fingerfucker ": 1,
            "fingerfuckers": 1,
            "fingerfucking ": 1,
            "fingerfucks ": 1,
            "fistfuck": 1,
            "fistfucked ": 1,
            "fistfucker ": 1,
            "fistfuckers ": 1,
            "fistfucking ": 1,
            "fistfuckings ": 1,
            "fistfucks ": 1,
            "flange": 1,
            "fook": 1,
            "fooker": 1,
            " fu ": 1,
            " f u ": 1,
            "fuck": 1,
            "fwck": 1,
            "fvck": 1,
            "fucka": 1,
            "fucked": 1,
            "fucker": 1,
            "fuckers": 1,
            "fuckhead": 1,
            "fuckheads": 1,
            "fuckin": 1,
            "fucking": 1,
            "fuckings": 1,
            "fuckingshitmotherfucker": 1,
            "fuckme ": 1,
            "fucks": 1,
            "fuckwhit": 1,
            "fuckwit": 1,
            "fudgepacker": 1,
            "fuk": 1,
            "fuker": 1,
            "fukker": 1,
            "fukkin": 1,
            "fuks": 1,
            "fukwhit": 1,
            "fukwit": 1,
            "fux": 1,
            "fux0r": 1,
            "f_u_c_k": 1,
            "gangbang": 1,
            "gangbanged ": 1,
            "gangbangs ": 1,
            "gaylord": 1,
            "gaysex": 1,
            "goatse": 1,
            "hardcoresex ": 1,
            "heshe": 1,
            "hoar": 1,
            "hoare": 1,
            "hoer": 1,
            "homo": 1,
            "hore": 1,
            "horniest": 1,
            "horny": 1,
            "hotsex": 1,
            "jack-off ": 1,
            "jackoff": 1,
            "jerk-off ": 1,
            "jism": 1,
            "jiz ": 1,
            "jizm ": 1,
            "jizz": 1,
            "kawk": 1,
            "knob": 1,
            "knobead": 1,
            "knobed": 1,
            "knobend": 1,
            "knobhead": 1,
            "knobjocky": 1,
            "knobjokey": 1,
            "kock": 1,
            "kondum": 1,
            "kondums": 1,
            "kummer": 1,
            "kumming": 1,
            "kums": 1,
            "kunilingus": 1,
            "l3i+ch": 1,
            "l3itch": 1,
            "labia": 1,
            "lmfao": 1,
            "m0f0": 1,
            "m0fo": 1,
            "m45terbate": 1,
            "ma5terb8": 1,
            "ma5terbate": 1,
            "masochist": 1,
            "master-bate": 1,
            "masterb8": 1,
            "masterbat*": 1,
            "masterbat3": 1,
            "masterbate": 1,
            "masterbation": 1,
            "masterbations": 1,
            "masturbate": 1,
            "mo-fo": 1,
            "mof0": 1,
            "mofo": 1,
            "mothafuck": 1,
            "mothafucka": 1,
            "mothafuckas": 1,
            "mothafuckaz": 1,
            "mothafucked ": 1,
            "mothafucker": 1,
            "mothafuckers": 1,
            "mothafuckin": 1,
            "mothafucking ": 1,
            "mothafuckings": 1,
            "mothafucks": 1,
            "mother fucker": 1,
            "motherfuck": 1,
            "motherfucked": 1,
            "motherfucker": 1,
            "motherfuckers": 1,
            "motherfuckin": 1,
            "motherfucking": 1,
            "motherfuckings": 1,
            "motherfuckka": 1,
            "motherfucks": 1,
            "muff": 1,
            "mutha": 1,
            "muthafecker": 1,
            "muthafuckker": 1,
            "muther": 1,
            "mutherfucker": 1,
            "n1gga": 1,
            "n1gger": 1,
            "nazi": 1,
            "nigg3r": 1,
            "nigg4h": 1,
            "nigga": 1,
            "niggah": 1,
            "niggas": 1,
            "niggaz": 1,
            "nigger": 1,
            "niggers ": 1,
            "nob jokey": 1,
            "nobhead": 1,
            "nobjocky": 1,
            "nobjokey": 1,
            "numbnuts": 1,
            "nutsack": 1,
            "orgasim ": 1,
            "orgasims ": 1,
            "orgasm": 1,
            "orgasms ": 1,
            "p0rn": 1,
            "pecker": 1,
            "penis": 1,
            "penisfucker": 1,
            "phonesex": 1,
            "phuck": 1,
            "phuk": 1,
            "phuked": 1,
            "phuking": 1,
            "phukked": 1,
            "phukking": 1,
            "phuks": 1,
            "phuq": 1,
            "pigfucker": 1,
            "pimpis": 1,
            "piss": 1,
            "pissed": 1,
            "pisser": 1,
            "pissers": 1,
            "pisses ": 1,
            "pissflaps": 1,
            "pissin ": 1,
            "pissing": 1,
            "pissoff ": 1,
            "poop": 1,
            "porn": 1,
            "porno": 1,
            "pornography": 1,
            "pornos": 1,
            "pricks ": 1,
            "pron": 1,
            "pusse": 1,
            "pussi": 1,
            "pussies": 1,
            "pussy": 1,
            "pussys ": 1,
            "rape": 1,
            "rectum": 1,
            "retard": 1,
            "rimjaw": 1,
            "rimming": 1,
            "sadist": 1,
            "schlong": 1,
            "screwing": 1,
            "scroat": 1,
            "scrote": 1,
            "scrotum": 1,
            "semen": 1,
            "sh!t": 1,
            "sh1t": 1,
            "shag": 1,
            "shagger": 1,
            "shaggin": 1,
            "shagging": 1,
            "shemale": 1,
            "shit": 1,
            "shitdick": 1,
            "shite": 1,
            "shited": 1,
            "shitey": 1,
            "shitfuck": 1,
            "shitfull": 1,
            "shithead": 1,
            "shiting": 1,
            "shitings": 1,
            "shits": 1,
            "shitted": 1,
            "shitter": 1,
            "shitters ": 1,
            "shitting": 1,
            "shittings": 1,
            "shitty ": 1,
            "skank": 1,
            "slut": 1,
            "sluts": 1,
            "smegma": 1,
            "smut": 1,
            "snatch": 1,
            "son-of-a-bitch": 1,
            "spunk": 1,
            "s_h_i_t": 1,
            "t1tt1e5": 1,
            "t1tties": 1,
            "teets": 1,
            "teez": 1,
            "testical": 1,
            "testicle": 1,
            "titfuck": 1,
            "tits": 1,
            "titt": 1,
            "tittie5": 1,
            "tittiefucker": 1,
            "titties": 1,
            "tittyfuck": 1,
            "tittywank": 1,
            "titwank": 1,
            "tosser": 1,
            "tw4t": 1,
            "twat": 1,
            "twathead": 1,
            "twatty": 1,
            "twunt": 1,
            "twunter": 1,
            "v14gra": 1,
            "v1gra": 1,
            "vagina": 1,
            "viagra": 1,
            "vulva": 1,
            "w00se": 1,
            "wang": 1,
            "wank": 1,
            "wanker": 1,
            "wanky": 1,
            "whoar": 1,
            "whore": 1,
            "willies": 1,
            "willy": 1,
            "xrated": 1,
            "xxx": 1
         };

      public var nextTimeout:Number = 0;

      private var textureManager:ITextureManager;

      private var activeView:String;

      private var simple:ChatSimple;

      private var advanced:ChatAdvanced;

      public function MessageLog(param1:Game)
      {
         var txt:Texture;
         var txt2:Texture;
         var toggleAdvanced:ImageButton;
         var g:Game = param1;
         textureManager = TextureLocator.getService();
         super();
         MessageLog.g = g;
         nextTimeout = 0;
         simple = new ChatSimple(g);
         addChild(simple);
         advanced = new ChatAdvanced(g);
         simple.y = advanced.y = 20;
         addEventListener("enterFrame", update);
         txt = textureManager.getTextureGUIByTextureName("button_chat_down");
         txt2 = textureManager.getTextureGUIByTextureName("button_chat_up");
         toggleAdvanced = new ImageButton(function():void
            {
               toggleView("advanced");
            }, txt, null, null, txt2);
         addChild(toggleAdvanced);
      }

      public static function writeSysInfo(param1:String):void
      {
         write(param1);
      }

      public static function writeChatMsg(param1:String, param2:String, param3:String = null, param4:String = null, param5:String = "", param6:Boolean = false):void
      {
         var _loc9_:Object = null;
         var _loc13_:Player = null;
         var _loc7_:String = null;
         var _loc12_:int = 0;
         var _loc11_:RegExp = null;
         if (g == null)
         {
            return;
         }
         if (param2.length > 250)
         {
            _loc9_ = {};
            _loc9_.length = param2.length;
            _loc9_.msg = param2;
            g.client.errorLog.writeError("Very long chat message, over 1000 chars: ", "", "", _loc9_);
            return;
         }
         if (g.solarSystem.type == "pvp dom" && param1 == "local")
         {
            _loc13_ = g.playerManager.playersById[param3];
            if (g.me != null && _loc13_ != null && _loc13_.team != -1 && g.me.team != -1)
            {
               if (_loc13_.team != g.me.team)
               {
                  return;
               }
               param1 = "team";
            }
         }
         for (var _loc10_:* in profanities)
         {
            _loc7_ = "";
            _loc12_ = 0;
            while (_loc12_ < _loc10_.length)
            {
               _loc7_ += "*";
               _loc12_++;
            }
            _loc11_ = new RegExp(_loc10_, "gi");
            param2 = param2.replace(_loc11_, _loc7_);
         }
         var _loc14_:String = colorCoding("[" + param1 + "]");
         var _loc8_:* = param2;
         if (param4)
         {
            _loc8_ = param4 + ": " + _loc8_;
         }
         if (param6)
         {
            _loc8_ = "<font color='#ffff66'>&#9733;</font>" + _loc8_;
         }
         _loc8_ = colorRights(param5, _loc8_);
         var _loc15_:Object = {};
         _loc15_.type = param1;
         _loc15_.text = StringUtil.trim(_loc14_ + " " + _loc8_);
         _loc15_.timeout = g.time + 60000;
         _loc15_.playerKey = param3;
         _loc15_.playerName = param4;
         _loc15_.supporter = param6;
         textQueue.push(_loc15_);
         if (textQueue.length > extendedMaxLines)
         {
            textQueue.splice(0, 1);
         }
         g.messageLog.updateTexts(_loc15_);
      }

      public static function write(param1:String, param2:String = "system"):void
      {
         var _loc3_:Object = null;
         param1 = colorCoding(param1);
         if (g != null)
         {
            _loc3_ = {};
            _loc3_.text = param1;
            _loc3_.type = param2;
            _loc3_.timeout = g.time + 60000;
            textQueue.push(_loc3_);
            if (textQueue.length > extendedMaxLines)
            {
               textQueue.splice(0, 1);
            }
            g.messageLog.updateTexts(_loc3_);
         }
      }

      public static function colorCoding(param1:String):String
      {
         param1 = param1.replace("[private]", "<FONT COLOR='#9a9a9a'>[private]</FONT>");
         param1 = param1.replace("[global]", "<FONT COLOR='#cccc44'>[global]</FONT>");
         param1 = param1.replace("[local]", "<FONT COLOR='#8888cc'>[local]</FONT>");
         param1 = param1.replace("[team]", "<FONT COLOR='#6666ff'>[team]</FONT>");
         param1 = param1.replace("[clan]", "<FONT COLOR='#88cc88'>[clan]</FONT>");
         param1 = param1.replace("[group]", "<FONT COLOR='#20ecea'>[group]</FONT>");
         param1 = param1.replace("[mod]", "<FONT COLOR='#ff3daf'>[mod]</FONT>");
         param1 = param1.replace("[modchat]", "<FONT COLOR='#ff6daf'>[modchat]</FONT>");
         param1 = param1.replace("[planet wars]", "<FONT COLOR='#ff44ff'>[planet wars]</FONT>");
         param1 = param1.replace("[error]", "<FONT COLOR='#C5403A'>[error]</FONT>");
         param1 = param1.replace("[death]", "");
         param1 = param1.replace("[loot]", "");
         return param1.replace("[join_leave]", "");
      }

      public static function colorRights(param1:String, param2:String):String
      {
         if (param1 == "mod")
         {
            return "<FONT COLOR='#ffaa44'>[mod]</FONT> " + param2;
         }
         if (param1 == "dev")
         {
            return "<FONT COLOR='#ff86fb'>[dev]</FONT> " + param2;
         }
         return param2;
      }

      public static function writeDeathNote(param1:Player, param2:String, param3:String):void
      {
         var _loc4_:String = "<FONT COLOR='#ff4444'>";
         if (param2 != "")
         {
            switch (param3)
            {
               case "sun":
                  _loc4_ += param1.name + " flew into the sun.";
                  break;
               case "comet":
                  _loc4_ += param1.name + " was crushed by a comet.";
                  break;
               case "suicide":
                  _loc4_ += param1.name + " commited suicide.";
                  break;
               case "Kamikaze":
                  _loc4_ += param2 + " took " + param1.name + " down with it.";
                  break;
               case "Missile Launcher":
                  _loc4_ += param1.name + " was hunted down by " + param2 + "s missiles.";
                  break;
               case "Mine Launcher":
                  _loc4_ += param1.name + " didn't see " + param2 + "s mines.";
                  break;
               case "Plasma Gun":
                  _loc4_ += param1.name + " was melted by " + param2 + "s plasma.";
                  break;
               case "Lightning Gun":
                  _loc4_ += param1.name + " was electrocuted by " + param2 + "s lightning.";
                  break;
               case "Blaster":
                  _loc4_ += param1.name + " was blasted by " + param2 + ".";
                  break;
               case "Piercing Gun":
                  _loc4_ += param1.name + " was perforated by " + param2 + ".";
                  break;
               case "Gatling Gun":
                  _loc4_ += param1.name + " was perforated by " + param2 + "'s gatling gun.";
                  break;
               case "Acid Spray":
                  _loc4_ += param1.name + " was liquefied by " + param2 + "s acid.";
                  break;
               case "Acid Blaster":
                  _loc4_ += param1.name + " was melted by " + param2 + "s acid.";
                  break;
               case "Energy Nova":
                  _loc4_ += param1.name + " was shocked by " + param2 + ".";
                  break;
               case "Nuke Launcher":
                  _loc4_ += param1.name + " was annihilated by " + param2 + "s nuke.";
                  break;
               case "Heavy Cannon":
                  _loc4_ += param1.name + " was crushed by " + param2 + "s slugs.";
                  break;
               case "Flamethrower":
                  _loc4_ += param1.name + " was burned alive by " + param2 + "s fire.";
                  break;
               case "Broadside":
                  _loc4_ += param1.name + " received a broadside from " + param2 + ".";
                  break;
               case "Moth Queen Spit Gland":
                  _loc4_ += param1.name + " was liquefied by " + param2 + "s acid.";
                  break;
               case "Plankton Siphon Gland":
                  _loc4_ += param1.name + " was drained dry by " + param2 + ".";
                  break;
               case "Cluster Missiles":
                  _loc4_ += param1.name + " was blown up by " + param2 + "s missiles.";
                  break;
               case "Chrono Beam":
                  _loc4_ += param1.name + " was annihilated by " + param2 + "s Chrono Beam.";
                  break;
               case "Moth Zero Gland":
                  _loc4_ += param1.name + " was disintegrated by " + param2 + "s Zero.";
                  break;
               case "Particle Gun":
                  _loc4_ += param1.name + " was vaporized by " + param2 + "s neutron stream.";
                  break;
               case "Piraya":
                  _loc4_ += param1.name + " was eaten alive by " + param2 + "s space fishes.";
                  break;
               case "Prismatic Crystal":
                  _loc4_ += param1.name + " was disintegrated by " + param2 + "s prismatic crystals.";
                  break;
               case "Razor":
                  _loc4_ += param1.name + " was sliced up by " + param2 + "s razors.";
                  break;
               case "X27-S Smart Gun":
                  _loc4_ += param1.name + " couldn't dodge " + param2 + "s smart gun.";
                  break;
               case "Blood-Claw S28 Smart Gun":
                  _loc4_ += param1.name + " couldn't dodge " + param2 + "s smart gun.";
                  break;
               case "C-4":
                  _loc4_ += param1.name + " was blown up by " + param2 + "s C-4.";
                  break;
               case "Concussion Sphere":
                  _loc4_ += param1.name + " was shocked to death by " + param2 + "s spheres.";
                  break;
               case "Acid Spore":
                  _loc4_ += param1.name + " was infected by " + param2 + "s acid spores.";
                  break;
               case "Eagle Needle":
                  _loc4_ += param1.name + " was perforated by " + param2 + "s needles.";
                  break;
               case "Flame Trail":
                  _loc4_ += param1.name + " didn't see " + param2 + "s fiery trail.";
                  break;
               case "Gatling Laser":
                  _loc4_ += param1.name + " was perforated by " + param2 + "s Gatling Laser.";
                  break;
               case "Golden Gun":
                  _loc4_ += param1.name + " was shot by " + param2 + "s golden bullet.";
                  break;
               case "Hell Fire":
                  _loc4_ += param1.name + " was burned to a crisp by " + param2 + "s Hellfire.";
                  break;
               case "Infested Missiles":
                  _loc4_ += param1.name + " was liquified by " + param2 + "s infested missiles.";
                  break;
               case "M2 Launcher":
                  _loc4_ += param1.name + " was hunted down by " + param2 + "s missiles.";
                  break;
               case "Skeletor Lightning":
                  _loc4_ += param1.name + " was liquified by " + param2 + "s corrosive lightning.";
                  break;
               case "Sticky Bombs":
                  _loc4_ += param1.name + " was blown up by " + param2 + "s bombs.";
                  break;
               case "Astro Lance":
                  _loc4_ += param1.name + " was bludgeoned by " + param2 + "s lance.";
                  break;
               case "Railgun":
                  _loc4_ += param1.name + " was eradicated by " + param2 + "s railgun";
                  break;
               case "Nexar Projector":
                  _loc4_ += param1.name + " was scoped by " + param2 + "s projection";
                  break;
               case "Vindicator Projector":
                  _loc4_ += param1.name + " was scoped by " + param2 + "s projection";
                  break;
               case "Shadow Projector":
                  _loc4_ += param1.name + " was scoped by " + param2 + "s projection";
                  break;
               case "Cruise Missiles VX-23":
                  _loc4_ += param1.name + " couldn’t escape  " + param2 + "s cruise missiles";
                  break;
               case "Plasma Flares HG-168":
                  _loc4_ += param1.name + " was disintegrated by " + param2 + "s flares";
                  break;
               case "Gatling Cannon GAU-186":
                  _loc4_ += param1.name + " was shattered by " + param2 + "s gatling cannon";
                  break;
               case "Golden Gun :Scatter Shell":
                  _loc4_ += param1.name + " was pulverised by " + param2 + "s scattergun";
                  break;
               case "Golden Gun :Flak Shell":
                  _loc4_ += param1.name + " was discombobulated by " + param2 + "s golden fireworks";
                  break;
               case "Shadowflames":
                  _loc4_ += param1.name + " was scorched by " + param2 + "s flames";
                  break;
               case "Death Cloud":
                  _loc4_ += param1.name + " was asphyxiated by " + param2 + "s cloud of death";
                  break;
               case "Nexar Blaster":
                  _loc4_ += param2 + " put an end to " + param1.name;
                  break;
               case "Corrosive Teeth":
                  _loc4_ += param1.name + " was torn apart by " + param2 + "s corrosive teeth";
                  break;
               case "Viper Fangs":
                  _loc4_ += param1.name + " was torn apart by " + param2 + "s viperfangs";
                  break;
               case "Poison Arrow":
                  _loc4_ += param1.name + " was shot down by " + param2 + "s poisoned arrow";
                  break;
               case "Target Painter":
                  _loc4_ += param1.name + " was somehow killed by " + param2 + "s painter";
                  break;
               case "Snow cannon":
                  _loc4_ += param1.name + " was frozen to death by " + param2 + "s snowball";
                  break;
               case "Spore 83-X Smart Gun":
                  _loc4_ += param1.name + " couldn't dodge " + param2 + "s smart gun";
                  break;
               case "Beamer":
                  _loc4_ += param1.name + " was fried by " + param2 + "s beamer";
                  break;
               case "Larva lightning":
                  _loc4_ += param1.name + " was frazzled by " + param2 + "s larva";
                  break;
               case "Boomerang":
                  _loc4_ += param1.name + " made mincemeat out of " + param2 + "s ship";
                  break;
               case "Locust Hatchery":
                  _loc4_ += param1.name + " was tickled to death by " + param2 + "s locust swarm";
                  break;
               case "Jaws":
                  _loc4_ += param1.name + " was eaten alive by " + param2;
                  break;
               case "Noxium Spray":
                  _loc4_ += param1.name + " was liquefied by " + param2 + "s noxium spray";
                  break;
               case "Noxium BFG":
                  _loc4_ += param1.name + " was whomped by " + param2 + "s BFG";
                  break;
               case "Aureus beam":
                  _loc4_ += param1.name + " was sentenced to death by " + param2 + "s Judibeam";
                  break;
               case "Prismatic Easter Egg":
                  _loc4_ += param1.name + " received a colourful surprise from " + param2 + "s prismatic eggs";
                  break;
               case "Algae Nova Gland":
                  _loc4_ += param1.name + " was crystallised by " + param2 + "s algae nova";
                  break;
               case "Aureus lightning":
                  _loc4_ += param1.name + " was mercilessly executed by " + param2 + "s Aureus lightning";
                  break;
               case "Fireworks":
                  _loc4_ += param2 + " celebrated the death of " + param1.name;
                  break;
               case "Nexar Bomb":
                  _loc4_ += param1.name + " was wiped out by " + param2 + "s nexar bomb";
                  break;
               case "Shadow Bomb":
                  _loc4_ += param1.name + " was wiped out by " + param2 + "s shadowbombs";
                  break;
               case "Pixi Launcher":
                  _loc4_ += param1.name + " was pixelated by + killerName";
                  break;
               case "Photonic Blaster":
                  _loc4_ += param1.name + " was illuminated to death by " + param2 + "s photon stream";
                  break;
               case "Sonic Missiles":
                  _loc4_ += param1.name + " couldn’t survive the shockwave from " + param2 + "s sonic missiles";
                  break;
               case "Shadow Blaster":
                  _loc4_ += param1.name + " was assassinated from the shadows by " + param2;
                  break;
               case "Plasma Blaster":
                  _loc4_ += param1.name + " was melted by the blue fireballs of " + param2;
                  break;
               case "Plasma Torpedoes":
                  _loc4_ += param1.name + " was eviscerated by " + param2 + "s torpedoes";
                  break;
               case "Kinetic Phase Cutter":
                  _loc4_ += param1.name + " was phased out of existence by " + param2;
                  break;
               case "Ram Missiles":
                  _loc4_ += param1.name + " was battered by " + param2 + "s ram missiles";
                  break;
               case "Flak Cannon":
                  _loc4_ += param1.name + " was decimated by " + param2 + "s big metal scrap launcher";
                  break;
               case "Golden Flak Cannon":
                  _loc4_ += param2 + " unleashed a horde of shuriken upon " + param1.name;
                  break;
               case "Golden Ram Missiles":
                  _loc4_ += param1.name + " was shredded by " + param2 + "s golden ram";
                  break;
               case "Vindicator Advanced Blaster":
                  _loc4_ += param1.name + " was demolished by " + param2 + "s advanced blaster";
                  break;
               case "Vindicator Cluster Missiles":
                  _loc4_ += param1.name + " was ruptured by " + param2 + "s advanced blaster";
                  break;
               case "X-73 Constructur":
                  _loc4_ += param2 + "s guardian defended against " + param1.name + "s ambush";
                  break;
               case "Wasp Bait":
                  _loc4_ += param1.name + " was bitten by " + param2 + "s wasp";
                  break;
               case "X-32 Constructor":
                  _loc4_ += param1.name + " was peppered by " + param2 + "s zlattes";
                  break;
               case "Monachus":
                  _loc4_ += param1.name + " was annoyed to death by " + param2 + "s monachus";
                  break;
               case "Aureus Energy Manipulator":
                  _loc4_ += param1.name + " couldn’t evade " + param2 + "s sentry energy orb";
                  break;
               case "Aureus Kinetic Manipulator":
                  _loc4_ += param1.name + " couldn’t evade " + param2 + "s sentry kinetic orb";
                  break;
               case "Aureus Corrosive Manipulator":
                  _loc4_ += param1.name + " couldn’t evade " + param2 + "s sentry corrosive orb";
                  break;
               case "X-42 Constructor":
                  _loc4_ += param1.name + " was eliminated by " + param2 + "s army of triads";
                  break;
               default:
                  _loc4_ += param1.name + " was killed by " + param2;
            }
         }
         else
         {
            _loc4_ += param1.name + " has died.";
         }
         var _loc5_:Object = {};
         _loc5_.type = "death";
         _loc4_ += "</FONT>";
         MessageLog.writeChatMsg("death", _loc4_);
      }

      private function get muted():Array
      {
         return SceneBase.settings.chatMuted;
      }

      private function toggleView(param1:String):void
      {
         removeChild(simple);
         removeChild(advanced);
         activeView = activeView == param1 ? "" : param1;
         if (activeView == "advanced")
         {
            addChild(advanced);
         }
         else
         {
            addChild(simple);
         }
      }

      public function toggleMuted(param1:String, param2:Boolean):void
      {
         var _loc3_:Array = muted;
         var _loc4_:int = int(_loc3_.indexOf(param1));
         if (param2 && _loc4_ == -1)
         {
            _loc3_.push(param1);
         }
         else if (_loc4_ != -1)
         {
            _loc3_.splice(_loc4_, 1);
         }
         SceneBase.settings.chatMuted = _loc3_;
         SceneBase.settings.save();
      }

      public function isMuted(param1:String):Boolean
      {
         return muted.indexOf(param1) != -1;
      }

      public function removePlayerMessages(param1:String):void
      {
         var key:String = param1;
         textQueue = textQueue.filter(function(param1:Object, param2:int, param3:Vector.<Object>):Boolean
            {
               return (param1.playerKey || "") != key;
            });
      }

      public function getQueue():Vector.<Object>
      {
         var queue:Vector.<Object> = textQueue.filter(function(param1:Object, param2:int, param3:Vector.<Object>):Boolean
            {
               var _loc4_:String = param1.type || "system";
               return muted.indexOf(_loc4_) == -1;
            });
         return queue;
      }

      private function update(param1:Event = null):void
      {
         if (contains(simple))
         {
            simple.update();
         }
      }

      public function updateTexts(param1:Object):void
      {
         if (contains(advanced))
         {
            advanced.updateText(param1);
         }
         else if (contains(simple))
         {
            simple.updateTexts();
         }
      }

      override public function dispose():void
      {
         removeEventListeners();
         g = null;
         super.dispose();
      }
   }
}
