package qolaf.ui.debuff {
	import core.scene.Game;
	import core.unit.Unit;
	import feathers.controls.LayoutGroup;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	import qolaf.data.DebuffInfo;
	import qolaf.ui.TargetInfoElement;
	import qolaf.ui.elements.DebuffInfoTooltip;
	import qolaf.utils.ColorUtils;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import qolaf.debuff.DebuffEffect;
	import qolaf.utils.ObjectPool;
	import qolaf.utils.StringUtils;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	/**
	 * @author rydev
	 */
	// I really need to rewrite this code lmao...
	public class DebuffDisplay extends LayoutGroup {
		private var _imagePool:ObjectPool;
		private var _debuffIconBack:Texture;
		private var _debuffInfoTooltip:DebuffInfoTooltip;
		private var _currentDebuffs:Vector.<DebuffEffect> = new Vector.<DebuffEffect>();
		private var _currentUnit:Unit;
		private var _selectedDebuff:DebuffEffect = null;
		private var _textureManager:ITextureManager;
		
		public function DebuffDisplay() {	
			_imagePool = new ObjectPool(function():Image {
				var image:Image = new Image(_debuffIconBack);
				image.width = image.height = 21.2;
				return image;
			}, function(obj:Object):void {
				if (!(obj is Image))
					return;
				var image:Image = obj as Image;
				image.texture = _debuffIconBack;
				image.removeEventListeners(TouchEvent.TOUCH);
				image.removeEventListeners(Event.ADDED_TO_STAGE);
			});
			_debuffInfoTooltip = new DebuffInfoTooltip();
			Game.instance.stage.addChild(_debuffInfoTooltip);
			_debuffInfoTooltip.visible = false;
			
			_textureManager = TextureLocator.getService();
			_debuffIconBack = _textureManager.getTextureByTextureName("ti_astro_lance_levels", "texture_gui1_test.png");
			
			var rowsLayout:TiledRowsLayout = new TiledRowsLayout();
			rowsLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_LEFT;
			rowsLayout.verticalAlign = TiledRowsLayout.VERTICAL_ALIGN_TOP;
			rowsLayout.paddingTop = 2;
			rowsLayout.requestedColumnCount = 13;
			rowsLayout.gap = 2;
			layout = rowsLayout;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:EnterFrameEvent):void {
			if (_selectedDebuff != null && _selectedDebuff.hasEnded)
				_selectedDebuff = null;
			
			_debuffInfoTooltip.visible = _selectedDebuff != null;
			if (_selectedDebuff == null)
				return;
				
			var debuffInfo:Object = DebuffInfo.getDebuff(_selectedDebuff.debuff);
			var name:String = debuffInfo != null ? debuffInfo.name : "Unknown Debuff";
			var description:String = debuffInfo != null ? debuffInfo["enemy_description"] : "Unknown Debuff Description";
			
			_debuffInfoTooltip.title.text = StringUtils.substitute(DebuffInfoTooltip.DEBUFF_NAME_TEMPLATE, {
				"[name]": name,
				"[stacks]": _selectedDebuff.stacks
			});
			
			_debuffInfoTooltip.time.text = StringUtils.formatTime(_selectedDebuff.currentDuration);
			_debuffInfoTooltip.time.format.color = _selectedDebuff.currentDuration <= 10000 ? 0xff0000 : 0xffffff;
			
			_debuffInfoTooltip.descriptionText = StringUtils.substitute(description, {
				"[enemy]": TargetInfoElement.getUnitTrueName(_currentUnit)
			});
		}
		
		public function get debuffInfoTooltip():DebuffInfoTooltip {
			return _debuffInfoTooltip;
		}
		
		public function clearDebuffs():void {
			_selectedDebuff = null;
			_currentDebuffs.splice(0, _currentDebuffs.length);
			removeChildren();
		}
		
		public function addDebuff(target:Unit, debuff:DebuffEffect):void {
			_currentDebuffs.push(debuff);
			_currentUnit = target;
			
			var image:Image = _imagePool.getOne() as Image;
			var debuffInfo:Object = DebuffInfo.getDebuff(debuff.debuff);
			if (debuffInfo != null) {
				image.texture = _textureManager.getTextureByTextureName(debuffInfo.icon, "texture_gui1_test.png");
			}
			
			image.addEventListener(TouchEvent.TOUCH, function(e:TouchEvent):void {
				var touch:Touch = e.getTouch(e.currentTarget as Image);
				if (touch != null && touch.phase == TouchPhase.BEGAN && _selectedDebuff == null) {
					_selectedDebuff = debuff;
				}
				else if (touch != null && touch.phase == TouchPhase.ENDED && _selectedDebuff == debuff) {
					_selectedDebuff = null;
				}
			});
			addChild(image);
		}
		
		public function removeDebuff(target:Unit, debuff:DebuffEffect):void {
			var indexOfDebuff:int = _currentDebuffs.indexOf(debuff);
			if (indexOfDebuff == -1)
				return;
			var image:Image = getChildAt(indexOfDebuff) as Image;
			if (_selectedDebuff == debuff)
				_selectedDebuff = null;
			_imagePool.recycleOne(image);
			removeChildAt(indexOfDebuff);
			_currentDebuffs.removeAt(indexOfDebuff);
		}
	}
}