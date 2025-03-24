package core.states.gameStates {
	import com.greensock.TweenMax;
	import core.hud.components.Button;
	import core.hud.components.ButtonCargo;
	import core.hud.components.ImageButton;
	import core.hud.components.Text;
	import core.hud.components.cargo.Cargo;
	import core.hud.components.cargo.CargoItem;
	import core.scene.Game;
	import core.solarSystem.Body;
	import feathers.controls.ScrollContainer;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import generics.Localize;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import textures.TextureManager;
	
	public class LandedRecycle extends LandedState {
		private var junkTextItems:Array;
		
		private var mineralTextItems:Array;
		
		private var recycleButton:ImageButton;
		
		private var myCargo:Cargo;
		
		private var recycling:Boolean = false;
		
		private var recycledItems:int = 0;
		
		private var takeButton:Button;
		
		private var selectAllButton:Button;
		
		private var scrollContainer:ScrollContainer = new ScrollContainer();
		
		private var scrollContainer2:ScrollContainer = new ScrollContainer();
		
		public function LandedRecycle(g:Game, body:Body) {
			super(g,body,body.name);
			myCargo = g.myCargo;
			junkTextItems = [];
			mineralTextItems = [];
		}
		
		override public function enter() : void {
			super.enter();
			var _local11:Text = new Text();
			_local11.text = body.name;
			_local11.size = 26;
			_local11.x = 80;
			_local11.y = 60;
			addChild(_local11);
			var _local7:Text = new Text();
			_local7.text = Localize.t("Select space junk");
			_local7.color = 0x666666;
			_local7.x = 80;
			_local7.y = 100;
			addChild(_local7);
			var _local9:Text = new Text();
			_local9.text = Localize.t("Your Refined minerals");
			_local9.color = 0x666666;
			_local9.x = 440;
			_local9.y = 100;
			addChild(_local9);
			var _local8:Vector.<int> = new Vector.<int>();
			_local8.push(1,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,2,2,1,2,2,2,2,1,2,2,2,2);
			var _local1:Number = 400;
			var _local2:Number = 260;
			var _local3:Number = 80;
			var _local4:Number = 40;
			var _local5:Number = 10;
			var _local10:Vector.<Number> = new Vector.<Number>();
			_local10.push(0,0);
			_local10.push(_local2,0);
			_local10.push(_local2,_local4);
			_local10.push(_local2 + _local3,_local4);
			_local10.push(_local2 + _local3,0);
			_local10.push(_local2 * 2 + _local3,0);
			_local10.push(_local2 * 2 + _local3,_local1);
			_local10.push(_local2 + _local3,_local1);
			_local10.push(_local2 + _local3,_local1 - _local4);
			_local10.push(_local2,_local1 - _local4);
			_local10.push(_local2,_local1 - _local4 / 2);
			_local10.push(0,_local1 - _local4 / 2);
			_local10.push(0,0);
			_local10.push(_local2,_local4 + _local5);
			_local10.push(_local2 + _local3,_local4 + _local5);
			_local10.push(_local2 + _local3,_local4 * 2 + _local5);
			_local10.push(_local2,_local4 * 2 + _local5);
			_local10.push(_local2,_local4 + _local5);
			_local10.push(_local2,_local4 * 2 + _local5 * 2);
			_local10.push(_local2 + _local3,_local4 * 2 + _local5 * 2);
			_local10.push(_local2 + _local3,_local1 - _local4 * 2 - _local5 * 2);
			_local10.push(_local2,_local1 - _local4 * 2 - _local5 * 2);
			_local10.push(_local2,_local4 * 2 + _local5 * 2);
			_local10.push(_local2,_local1 - _local4 - _local5);
			_local10.push(_local2,_local1 - _local4 * 2 - _local5);
			_local10.push(_local2 + _local3,_local1 - _local4 * 2 - _local5);
			_local10.push(_local2 + _local3,_local1 - _local4 - _local5);
			_local10.push(_local2,_local1 - _local4 - _local5);
			var _local12:flash.display.Sprite = new flash.display.Sprite();
			_local12.graphics.lineStyle(1,6356795,1);
			_local12.graphics.beginFill(0,1);
			_local12.graphics.drawPath(_local8,_local10);
			_local12.graphics.endFill();
			_local12.filters = [new GlowFilter(6356795,0.4,15,15,2,2)];
			var _local6:Image = TextureManager.imageFromSprite(_local12,"recycleLines");
			_local6.x = 80;
			_local6.y = 130;
			addChild(_local6);
			takeButton = new Button(removeMinerals,Localize.t("Take Minerals"),"positive");
			takeButton.x = 475;
			takeButton.y = 490;
			takeButton.enabled = false;
			addChild(takeButton);
			selectAllButton = new Button(selectAllJunk,Localize.t("Select All"),"normal");
			selectAllButton.x = 125;
			selectAllButton.y = 525;
			selectAllButton.enabled = false;
			selectAllButton.autoEnableAfterClick = true;
			addChild(selectAllButton);
			g.tutorial.showRecycleAdvice();
			recycleButton = new ImageButton(recycle,textureManager.getTextureGUIByTextureName("recycle_button.png"),textureManager.getTextureGUIByTextureName("recycle_button_hover.png"),textureManager.getTextureGUIByTextureName("recycle_button_disabled.png"));
			recycleButton.y = 320;
			recycleButton.x = 760 / 2;
			recycleButton.pivotX = recycleButton.width / 2;
			recycleButton.pivotY = recycleButton.height / 2;
			scrollContainer.x = 95;
			scrollContainer.y = 145;
			scrollContainer.height = 345;
			scrollContainer.width = 245;
			scrollContainer2.x = 435;
			scrollContainer2.y = 145;
			scrollContainer2.height = 345;
			scrollContainer2.width = 245;
			addChild(scrollContainer);
			addChild(scrollContainer2);
			junkReceived();
		}
		
		override public function execute() : void {
			if(recycling) {
				recycleButton.rotation += 0.017453292519943295;
			}
			super.execute();
		}
		
		private function junkReceived() : void {
			var _local3:Object = null;
			var _local5:Vector.<CargoItem> = myCargo.spaceJunk;
			var _local1:int = 0;
			var _local4:int = 0;
			for each(var _local2 in _local5) {
				if(_local2.amount != 0) {
					_local1 += _local2.amount;
					_local3 = dataManager.loadKey(_local2.table,_local2.item);
					scrollContainer.addChild(createItem(_local3,"spaceJunk",_local2.amount,_local4));
					_local4++;
				}
			}
			recycleButton.enabled = false;
			if(_local1 > 0) {
				selectAllButton.enabled = true;
			}
			loadCompleted();
			addChild(recycleButton);
		}
		
		private function createItem(obj:Object, type:String, quantity:int, i:int, useTween:Boolean = false) : starling.display.Sprite {
			var bgr:Quad;
			var textName:Text;
			var textQuantity:Text;
			var obj2:Object;
			var itemBmp:Image;
			var itemContainer:starling.display.Sprite = new starling.display.Sprite();
			itemContainer.y = i * 40;
			bgr = new Quad(230,32,1450513);
			bgr.x = 0;
			bgr.y = 0;
			textName = new Text(35,8);
			textName.text = Localize.t(obj.name);
			textName.color = 0x666666;
			textName.size = 12;
			textQuantity = new Text(0,5);
			textQuantity.text = quantity.toString();
			textQuantity.color = 0xffffff;
			textQuantity.size = 16;
			textQuantity.alignRight();
			textQuantity.x = 220;
			obj2 = {};
			obj2 = {
				"obj":obj,
				"itemContainer":itemContainer,
				"bgr":bgr,
				"textName":textName,
				"textQuantity":textQuantity,
				"quantity":quantity,
				"selected":false
			};
			if(useTween) {
				obj2.quantity = 0;
				TweenMax.to(obj2,1 + 8 * (1 - 1000 / (1000 + quantity)),{
					"quantity":quantity,
					"onUpdate":function():void {
						textQuantity.text = int(obj2.quantity).toString();
					},
					"onComplete":function():void {
						recycledItems++;
						if(recycledItems == mineralTextItems.length) {
							recycling = false;
							takeButton.enabled = true;
							if(myCargo.spaceJunkCount > 0) {
								selectAllButton.enabled = true;
							}
						}
					}
				});
			}
			if(type == "mineral") {
				mineralTextItems.push(obj2);
			} else {
				junkTextItems.push(obj2);
				if(quantity > 0) {
					itemContainer.useHandCursor = true;
					itemContainer.addEventListener("touch",createTouch(obj2));
				} else {
					textName.color = 0x444444;
					textQuantity.color = 0x444444;
				}
			}
			itemBmp = new Image(textureManager.getTextureGUIByKey(obj.bitmap));
			itemBmp.x = 10;
			itemBmp.y = 15 - itemBmp.height / 2;
			itemContainer.addChild(bgr);
			itemContainer.addChild(itemBmp);
			itemContainer.addChild(textName);
			itemContainer.addChild(textQuantity);
			return itemContainer;
		}
		
		private function playRecycleLoop() : void {
			if(!recycling) {
				return;
			}
			soundManager.play("akOV-VmtrUK-k5pYruy76g",null,function():void {
				playRecycleLoop();
			});
		}
		
		private function createTouch(obj2:Object) : Function {
			return function(param1:TouchEvent):void {
				var _local3:ColorMatrixFilter = null;
				var _local2:ColorMatrixFilter = null;
				if(recycling) {
					return;
				}
				if(param1.getTouch(obj2.itemContainer,"ended")) {
					obj2.selected = !!obj2.selected ? false : true;
					if(obj2.selected) {
						recycleButton.enabled = true;
						_local3 = new ColorMatrixFilter();
						_local3.adjustBrightness(0.2);
						obj2.itemContainer.filter = _local3;
					} else {
						recycleButton.enabled = false;
						for each(var _local4 in junkTextItems) {
							if(_local4.selected) {
								recycleButton.enabled = true;
							}
						}
						if(obj2.itemContainer.filter) {
							obj2.itemContainer.filter.dispose();
							obj2.itemContainer.filter = null;
						}
					}
				} else if(param1.interactsWith(obj2.itemContainer)) {
					if(obj2.itemContainer.filter == null) {
						_local2 = new ColorMatrixFilter();
						_local2.adjustBrightness(0.1);
						obj2.itemContainer.filter = _local2;
					}
				} else if(!obj2.selected && obj2.itemContainer.filter) {
					obj2.itemContainer.filter.dispose();
					obj2.itemContainer.filter = null;
				}
			};
		}
		
		private function recycle(e:ImageButton) : void {
			var _local2:ISound = SoundLocator.getService();
			_local2.play("BWHiEHVtwkC56EUUiGainw");
			recycling = true;
			recycledItems = 0;
			playRecycleLoop();
			selectAllButton.enabled = false;
			recycleButton.enabled = false;
			removeMinerals();
			var _local4:Message = g.createMessage("recycleJunk");
			for each(var _local3 in junkTextItems) {
				if(_local3.selected) {
					_local4.add(_local3.obj.key);
				}
			}
			ButtonCargo.serverSaysCargoIsFull = false;
			g.rpcMessage(_local4,junkRecycled);
		}
		
		private function junkRecycled(m:Message) : void {
			var _local3:int = 0;
			var _local6:int = 0;
			var _local2:String = null;
			var _local4:int = 0;
			var _local7:Object = null;
			for each(var _local5 in junkTextItems) {
				if(_local5.selected) {
					tweenReduceJunk(_local5);
					myCargo.removeJunk(_local5.obj.key,_local5.quantity);
				}
			}
			_local6 = 0;
			while(_local6 < m.length) {
				_local2 = m.getString(_local6);
				_local4 = m.getInt(_local6 + 1);
				_local7 = dataManager.loadKey("Commodities",_local2);
				scrollContainer2.addChild(createItem(_local7,"mineral",_local4,_local3,true));
				myCargo.addItem("Commodities",_local2,_local4);
				_local6 += 2;
				_local3++;
			}
		}
		
		private function tweenReduceJunk(obj:Object) : void {
			var textName:Text = obj.textName;
			var textQuantity:Text = obj.textQuantity;
			var itemObj:Object = obj.obj;
			TweenMax.to(obj,1 + 8 * (1 - 1000 / (1000 + obj.quantity)),{
				"quantity":0,
				"onUpdate":function():void {
					textQuantity.text = int(obj.quantity).toString();
				}
			});
			textName.color = 0x444444;
			textQuantity.color = 0x444444;
			obj.selected = false;
			if(obj.itemContainer.filter) {
				obj.itemContainer.filter.dispose();
				obj.itemContainer.filter = null;
			}
			obj.itemContainer.useHandCursor = false;
			obj.itemContainer.removeEventListeners();
		}
		
		private function removeMinerals(e:Event = null) : void {
			var mineralObj:Object;
			for each(mineralObj in mineralTextItems) {
				TweenMax.fromTo(mineralObj.itemContainer,1,{
					"alpha":1,
					"y":mineralObj.itemContainer.y
				},{
					"alpha":0,
					"y":mineralObj.itemContainer.y + 200,
					"onComplete":function():void {
						removeChild(mineralObj.itemContainer);
					}
				});
			}
			if(mineralTextItems.length > 0) {
				SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			}
			mineralTextItems.splice(0,mineralTextItems.length);
		}
		
		private function selectAllJunk(e:Event = null) : void {
			var _local3:ColorMatrixFilter = null;
			for each(var _local2 in junkTextItems) {
				if(_local2.quantity > 0) {
					soundManager.play("BWHiEHVtwkC56EUUiGainw");
					_local2.selected = true;
					_local3 = new ColorMatrixFilter();
					_local3.adjustBrightness(0.2);
					_local2.itemContainer.filter = _local3;
					recycleButton.enabled = true;
				}
			}
		}
	}
}

