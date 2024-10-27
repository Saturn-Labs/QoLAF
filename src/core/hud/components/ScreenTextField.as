package core.hud.components
{
   import com.greensock.TweenMax;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import sound.ISound;
   import sound.SoundLocator;
   import starling.events.Event;
   import starling.filters.BlurFilter;
   import starling.filters.GlowFilter;
   import starling.text.TextField;

   public class ScreenTextField extends TextField
   {
      public static const PARAGRAPH_FINISHED:String = "paragraphFinished";

      public static const PAGE_FINISHED:String = "pageFinished";

      public static const ANIMATION_FINISHED:String = "animationFinished";

      public static const BEFORE_FADE_OUT:String = "beforeFadeOut";

      private var CARET_SOUND:String = "jS2TrMck2EOVxw72l0pf9A";

      private var randomChars:String = "a b c d e f g h i j k l m n o p q r s t u v 1 2 3 4 5 6 7 8 9 0 ! @ # $ % ^ & * ( ) { } < > / ?";

      private var charArray:Array;

      private var pageText:String = "";

      private var currentParagraph:int = 0;

      private var currentPage:int = 0;

      private var _textArray:Array = null;

      private var showCaret:Boolean = true;

      public var caretDelay:Number = 30;

      public var caretIncrement:Number = 1;

      public var paragraphReadTime:Number = 1000;

      public var pageReadTime:Number = 4000;

      public var paragraphInitTime:Number = 500;

      public var randomCharAmount:Number = 0;

      public var period:Number = 33;

      public var newRowTime:Number = 720;

      public var fadeOutDelay:Number = 0;

      public var glowFilter:GlowFilter;

      public var glowColor:uint = 16777215;

      public var glowAlpha:Number = 1;

      public var glowBlurX:Number = 2;

      public var glowBlurY:Number = 2;

      public var fadeOutTime:Number = 500;

      public var fadeOutBlurX:Number = 100;

      public var fadeOutBlurStrength:int = 6;

      public var fadeOutBlurAlpha:Number = 1;

      private var soundManager:ISound;

      public var id:String = "";

      private var stopPlaying:Boolean;

      public var duration:Number = 0;

      public var fadeOut:Boolean = true;

      public function ScreenTextField(param1:int = 450, param2:int = 800, param3:Number = 6000, param4:uint = 16777215, param5:uint = 16777215, param6:Number = 0)
      {
         charArray = randomChars.split(" ");
         super(param1, param2);
         format.horizontalAlign = "left";
         format.verticalAlign = "top";
         format.font = "DAIDRR";
         wordWrap = true;
         this.duration = param3;
         this.format.color = param4;
         format.size = 16;
         this.fadeOutDelay = param6;
         textArray = [];
         soundManager = SoundLocator.getService();
         if (!RymdenRunt.isBuggedFlashVersion)
         {
            glowFilter = new GlowFilter(param5, glowAlpha, glowBlurX);
         }
         glowFilter = null;
      }

      public function start(param1:Array = null, param2:Boolean = true):void
      {
         var originalTime:Number;
         var pages:int;
         var i:int;
         var paragraphs:int;
         var j:int;
         var characters:int;
         var offsetTime:Number;
         var textArray:Array = param1;
         var adjustTime:Boolean = param2;
         if (textArray != null)
         {
            _textArray = textArray;
         }
         currentParagraph = 0;
         currentPage = 0;
         if (adjustTime)
         {
            originalTime = 0;
            pages = int(_textArray.length);
            originalTime += pages * pageReadTime + pages * fadeOutTime;
            i = 0;
            while (i < pages)
            {
               paragraphs = int(_textArray[i].length);
               originalTime += paragraphs * paragraphReadTime + paragraphs * paragraphInitTime + paragraphs * newRowTime;
               j = 0;
               while (j < paragraphs)
               {
                  characters = int(_textArray[i][j].length);
                  originalTime += characters * caretDelay;
                  j++;
               }
               i++;
            }
            offsetTime = duration / originalTime;
            pageReadTime *= offsetTime;
            fadeOutTime *= offsetTime;
            paragraphReadTime *= offsetTime;
            paragraphInitTime *= offsetTime;
            caretDelay *= offsetTime;
            newRowTime *= offsetTime;
         }
         soundManager.preCacheSound(CARET_SOUND, function():void
            {
               addEventListener("paragraphFinished", nextParagraph);
               addEventListener("pageFinished", nextParagraph);
               addEventListener("animationFinished", onAnimationFinished);
               nextParagraph();
            });
      }

      public function onAnimationFinished(param1:starling.events.Event = null):void
      {
         removeEventListener("paragraphFinished", nextParagraph);
         removeEventListener("pageFinished", nextParagraph);
         removeEventListener("animationFinished", onAnimationFinished);
      }

      public function set textArray(param1:Array):void
      {
         _textArray = param1;
      }

      private function nextParagraph(param1:starling.events.Event = null):void
      {
         var pauseTimer:Timer;
         var onPauseUpdate:Function;
         var e:starling.events.Event = param1;
         if (currentPage == _textArray.length)
         {
            dispatchEventWith("animationFinished");
            alpha = 0;
            if (filter)
            {
               filter.dispose();
            }
            filter = null;
            return;
         }
         resetStyle();
         if (currentParagraph < _textArray[currentPage].length - 1)
         {
            pauseTimer = new Timer(period, paragraphInitTime / period);
            pauseTimer.addEventListener("timer", function(param1:flash.events.Event):void
               {
                  toggleCaret(pageText);
               });
            pauseTimer.addEventListener("timerComplete", function(param1:flash.events.Event):void
               {
                  revealParagraph(_textArray[currentPage][currentParagraph]);
                  currentParagraph++;
               });
            pauseTimer.start();
         }
         else if (currentParagraph < _textArray[currentPage].length)
         {
            pauseTimer = new Timer(period, paragraphInitTime / period);
            onPauseUpdate = function(param1:flash.events.Event):void
            {
               toggleCaret(pageText);
            };
            pauseTimer.addEventListener("timer", onPauseUpdate);
            pauseTimer.addEventListener("timerComplete", (function():*
                  {
                     var onPauseComplete:Function;
                     return onPauseComplete = function(param1:flash.events.Event):void
                     {
                        var _loc3_:Array = null;
                        var _loc2_:String = null;
                        if (_textArray != null)
                        {
                           _loc3_ = _textArray[currentPage];
                           if (_loc3_ == null)
                           {
                              return;
                           }
                           _loc2_ = _loc3_[currentParagraph];
                           revealParagraph(_loc2_, true);
                        }
                        pauseTimer.removeEventListener("timer", onPauseUpdate);
                        pauseTimer.removeEventListener("timerComplete", onPauseComplete);
                        currentParagraph = 0;
                        currentPage++;
                     };
                  })());
            pauseTimer.start();
         }
      }

      private function revealParagraph(param1:String, param2:Boolean = false):void
      {
         var toReveal:String = param1;
         var lastParagraph:Boolean = param2;
         var count:int = 0;
         var curS:String = new String();
         var fadeInTimer:Timer = new Timer(caretDelay, toReveal.length);
         var onFadeInTimerUpdate:Function = function(param1:flash.events.Event):void
         {
            var _loc2_:String = toReveal.substring(count, count + caretIncrement);
            curS += _loc2_;
            count += caretIncrement;
            if (stopPlaying)
            {
               fadeInTimer.stop();
            }
            if (_loc2_ != " ")
            {
               soundManager.play(CARET_SOUND);
            }
            toggleCaret(pageText + curS + randText(randomCharAmount) + " ");
         };
         fadeInTimer.addEventListener("timer", onFadeInTimerUpdate);
         fadeInTimer.addEventListener("timerComplete", (function():*
               {
                  var onFadeInTimerComplete:Function;
                  return onFadeInTimerComplete = function(param1:flash.events.Event):void
                  {
                     var readTimeSteps:int;
                     var endAction:Function;
                     var readTimer:Timer;
                     var onReadTimerUpdate:Function;
                     var e:flash.events.Event = param1;
                     fadeInTimer.removeEventListener("timer", onFadeInTimerUpdate);
                     fadeInTimer.removeEventListener("timerComplete", onFadeInTimerComplete);
                     if (lastParagraph)
                     {
                        endAction = createFadeOutPage(toReveal);
                        readTimeSteps = pageReadTime / period;
                        dispatchEventWith("beforeFadeOut");
                     }
                     else
                     {
                        endAction = createMoveCaret(toReveal);
                        readTimeSteps = paragraphReadTime / period;
                     }
                     readTimer = new Timer(period, readTimeSteps);
                     onReadTimerUpdate = function(param1:TimerEvent):void
                     {
                        if (stopPlaying)
                        {
                           readTimer.stop();
                        }
                        toggleCaret(pageText + toReveal + " ");
                     };
                     readTimer.addEventListener("timer", onReadTimerUpdate);
                     readTimer.addEventListener("timerComplete", (function():*
                           {
                              var onReadTimerComplete:Function;
                              return onReadTimerComplete = function(param1:TimerEvent):void
                              {
                                 readTimer.removeEventListener("timer", onReadTimerUpdate);
                                 readTimer.removeEventListener("timer", onReadTimerComplete);
                                 endAction(param1);
                              };
                           })());
                     readTimer.start();
                  };
               })());
         fadeInTimer.start();
      }

      private function createMoveCaret(param1:String):Function
      {
         var toReveal:String = param1;
         return function(param1:flash.events.Event):void
         {
            var pauseTimer:Timer;
            var e:flash.events.Event = param1;
            if (stopPlaying)
            {
               return;
            }
            text = pageText + toReveal + "\n";
            soundManager.play(CARET_SOUND);
            pageText = text;
            pauseTimer = new Timer(period, newRowTime / period);
            pauseTimer.addEventListener("timer", function(param1:flash.events.Event):void
               {
                  if (stopPlaying)
                  {
                     pauseTimer.stop();
                  }
                  toggleCaret(pageText);
               });
            pauseTimer.addEventListener("timerComplete", function(param1:flash.events.Event):void
               {
                  soundManager.play(CARET_SOUND);
                  pageText += "\n";
                  text = pageText + "_";
                  dispatchEvent(new starling.events.Event("paragraphFinished"));
               });
            pauseTimer.start();
         };
      }

      public function createFadeOutPage(param1:String):Function
      {
         var toReveal:String = param1;
         return function(param1:flash.events.Event):void
         {
            var e:flash.events.Event = param1;
            TweenMax.delayedCall(fadeOutDelay, function():void
               {
                  text = pageText + toReveal;
                  doFadeOut();
               });
         };
      }

      private function resetStyle():void
      {
         alpha = 1;
         filter = glowFilter;
      }

      public function stop():void
      {
         stopPlaying = true;
      }

      public function play():void
      {
         stopPlaying = false;
      }

      public function doFadeOut():void
      {
         var blurFilter:BlurFilter;
         var fadeOutTimer:Timer;
         var fadeOutSteps:int = fadeOutTime / period;
         var currentFadeOutStep:int = 0;
         if (!RymdenRunt.isBuggedFlashVersion)
         {
            blurFilter = new BlurFilter(1, 0, 1);
         }
         else
         {
            blurFilter = null;
         }
         fadeOutTimer = new Timer(period, fadeOutSteps);
         fadeOutTimer.addEventListener("timer", function(param1:TimerEvent):void
            {
               alpha = 1 * (fadeOutSteps - currentFadeOutStep) / fadeOutSteps;
               if (blurFilter)
               {
                  blurFilter.blurX = 1 + 105 * (1 - alpha);
               }
               filter = blurFilter;
               currentFadeOutStep++;
            });
         fadeOutTimer.addEventListener("timerComplete", function(param1:TimerEvent):void
            {
               pageText = "";
               text = "";
               dispatchEventWith("pageFinished");
            });
         fadeOutTimer.start();
      }

      private function toggleCaret(param1:String):void
      {
         if (showCaret)
         {
            text = param1 + "_";
            showCaret = false;
         }
         else
         {
            text = param1;
            showCaret = true;
         }
      }

      public function getFullWidth(param1:String, param2:int = 0):Number
      {
         var _loc4_:Text = new Text();
         if (param2 > 0)
         {
            _loc4_.size = param2;
         }
         else
         {
            _loc4_.size = format.size;
         }
         _loc4_.text = param1;
         var _loc3_:Number = _loc4_.width;
         _loc4_.clean();
         _loc4_ = null;
         return _loc3_;
      }

      private function randText(param1:int = 6):String
      {
         var _loc3_:int = 0;
         var _loc2_:Array = new Array(param1);
         _loc3_ = 0;
         while (_loc3_ < param1)
         {
            _loc2_[_loc3_] = charArray[int(Math.random() * charArray.length)];
            _loc3_++;
         }
         return _loc2_.join("");
      }
   }
}
