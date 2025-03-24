package core.particle {
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import data.*;
	import debug.Console;
	import generics.Color;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.*;
	
	public class EmitterFactory {
		public function EmitterFactory() {
			super();
		}
		
		public static function create(key:String, g:Game, x:int = 0, y:int = 0, target:GameObject = null, play:Boolean = false, addToRenderList:Boolean = true, multipleAllowed:Boolean = true, canvasTarget:Sprite = null) : Vector.<Emitter> {
			var delay:Number;
			var emitters:Vector.<Emitter>;
			var obj:Object;
			var e:Emitter;
			var txt:Texture;
			var bitmapObj:Object;
			var dataManager:IDataManager = DataLocator.getService();
			var effectObj:Object = dataManager.loadKey("Effects",key);
			if(!g.isLeaving && effectObj != null) {
				if(effectObj.multiple && multipleAllowed) {
					delay = Number(effectObj.multipleDelay);
					TweenMax.delayedCall(delay / 1000,function():void {
						var _local3:Number = Number(effectObj.multipleRadius);
						var _local1:Number = x + (_local3 - _local3 * 2 * Math.random());
						var _local2:Number = y + (_local3 - _local3 * 2 * Math.random());
						create(key,g,_local1,_local2,target,play,addToRenderList,false);
					});
				}
				emitters = new Vector.<Emitter>();
				for each(obj in effectObj.emitters) {
					if(effectObj.singleUse && !g.camera.isOnScreen(x,y)) {
						return null;
					}
					if(addToRenderList) {
						e = g.emitterManager.getEmitter();
					} else {
						e = new Emitter(g);
					}
					if(e == null) {
						return null;
					}
					if(e.oldImageKey == obj.bitmap && e.oldImageKey != "self") {
						txt = e.txt;
					} else {
						txt = resolveTexture(obj,target);
					}
					e.oldImageKey = obj.bitmap;
					if(txt == null) {
						return null;
					}
					e.txt = txt;
					e.key = key;
					e.name = effectObj.name;
					e.alive = true;
					e.duration = obj.duration;
					e.ttl = obj.ttl;
					e.ttlVariance = obj.ttlVariance;
					e.startColor = Color.fixColorCode(obj.startColor,false);
					e.finishColor = Color.fixColorCode(obj.finishColor,false);
					e.maxParticles = obj.maxParticles;
					e.startSize = obj.startSize;
					e.finishSize = obj.finishSize;
					e.speed = obj.speed;
					e.speedVariance = obj.speedVariance;
					e.angleVariance = obj.angleVariance;
					if(obj.hasOwnProperty("uniformDistribution")) {
						e.uniformDistribution = obj.uniformDistribution;
					} else {
						e.uniformDistribution = false;
					}
					e.startAlpha = obj.startAlpha;
					e.finishAlpha = obj.finishAlpha;
					e.startBlendMode = "add";
					e.finishBlendMode = "add";
					e.global = false;
					e.forceUpdate = true;
					e.startSizeVariance = obj.startSizeVariance;
					e.finishSizeVariance = obj.finishSizeVariance;
					e.gravityY = obj.gravityY;
					e.gravityX = obj.gravityX;
					e.centralGravity = obj.centralGravity;
					if(obj.hasOwnProperty("useFriction")) {
						e.useFriction = obj.useFriction;
					}
					e.steadyStream = obj.steadyStream;
					e.sourceVarianceX = obj.sourceVarianceX;
					e.sourceVarianceY = obj.sourceVarianceY;
					e.followEmitter = obj.followEmitter;
					e.followTarget = obj.followTarget;
					e.shakeIntensity = obj.shakeIntensity / 1000;
					e.shakeDuration = obj.shakeDuration;
					e.posX = x;
					e.posY = y;
					bitmapObj = g.dataManager.loadKey("Images",obj.bitmap);
					if(obj.bitmap == "self" && target != null) {
						e.startSize *= target.movieClip.scaleX;
						e.finishSize *= target.movieClip.scaleX;
					}
					if(play) {
						e.play();
					}
					if(e.followTarget) {
						e.target = target;
					}
					if(canvasTarget != null) {
						e.canvasTarget = canvasTarget;
					}
					e.collectiveMeshBatch = CollectiveMeshBatch.Create(e);
					e.collectiveMeshBatch.blendMode = "add";
					emitters.push(e);
					if(emitters.length == effectObj.emitters.length) {
						return emitters;
					}
				}
			}
			return null;
		}
		
		private static function resolveTexture(obj:Object, target:GameObject = null) : Texture {
			var _local4:ITextureManager = null;
			var _local3:* = null;
			if(obj.bitmap == "self") {
				if(target == null) {
					Console.write("No self for effect.");
					return null;
				}
				if(target is GameObject) {
					return target.texture;
				}
				return null;
			}
			_local4 = TextureLocator.getService();
			return _local4.getTextureMainByKey(obj.bitmap);
		}
		
		public static function createRareType(g:Game, enemy:EnemyShip, rareType:int = 0) : Vector.<Emitter> {
			var _local4:* = undefined;
			var _local5:* = undefined;
			if(g.isLeaving) {
				return new Vector.<Emitter>();
			}
			if(rareType == 1) {
				return EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw",g,enemy.pos.x,enemy.pos.y,enemy,true);
			}
			if(rareType == 2) {
				return EmitterFactory.create("Go4yOCnz40u-tQvx7g9wNg",g,enemy.pos.x,enemy.pos.y,enemy,true);
			}
			if(rareType == 4) {
				_local4 = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw",g,enemy.pos.x,enemy.pos.y,enemy,true);
				for each(var _local6 in _local4) {
					_local6.finishSize = 2.5;
					_local6.startSize = 2.5;
					_local6.startColor = 0x44ff44;
					_local6.finishColor = 0x44ff44;
				}
				return _local4;
			}
			if(rareType == 5) {
				_local4 = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw",g,enemy.pos.x,enemy.pos.y,enemy,true);
				for each(_local6 in _local4) {
					_local6.finishSize = 2.5;
					_local6.startSize = 2.5;
					_local6.startColor = 0xffff22;
					_local6.finishColor = 0xffff22;
					_local6.startAlpha = 0.3;
					_local6.finishAlpha = 0;
				}
				_local5 = _local4;
				_local4 = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw",g,enemy.pos.x,enemy.pos.y,enemy,true);
				for each(_local6 in _local4) {
					_local6.finishSize = 1.4;
					_local6.startSize = 1.4;
					_local6.startColor = 0xff8822;
					_local6.finishColor = 0xff8822;
					_local6.startAlpha = 0.3;
					_local6.finishAlpha = 0;
				}
				return _local5.concat(_local4);
			}
			if(rareType == 3) {
				return EmitterFactory.create("FWSygsW1x0q2sKlULeGZMA",g,enemy.pos.x,enemy.pos.y,enemy,true);
			}
			return new Vector.<Emitter>();
		}
	}
}

