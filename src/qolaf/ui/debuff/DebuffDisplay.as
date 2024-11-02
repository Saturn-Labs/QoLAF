package qolaf.ui.debuff {
	import core.scene.Game;
	import core.unit.Unit;
	import feathers.controls.LayoutGroup;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	import qolaf.data.DebuffInfo;
	import qolaf.ui.TargetInfoElement;
	import qolaf.ui.elements.DebuffInfoTooltip;
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
		private var _matrixFilterPool:ObjectPool;
		private var _debuffIconBack:Texture;
		private var _debuffInfoTooltip:DebuffInfoTooltip;
		private var _currentDebuffs:Vector.<DebuffEffect>;
		private var _currentUnit:Unit;
		private var _selectedDebuff:DebuffEffect = null;
		private var _textureManager:ITextureManager;
		
		public function DebuffDisplay() {
			_matrixFilterPool = new ObjectPool(function():ColorMatrixFilter {
				var filter:ColorMatrixFilter = new ColorMatrixFilter();
				filter.adjustSaturation( -1);
				return filter;
			}, function(obj:Object):void {
				if (!(obj is ColorMatrixFilter))
					return;
				
				var filter:ColorMatrixFilter = obj as ColorMatrixFilter;
				filter.matrix = [
					1, 0, 0, 0, 0,
					0, 1, 0, 0, 0,
					0, 0, 1, 0, 0,
					0, 0, 0, 1, 0
				];
			});
			
			_imagePool = new ObjectPool(function():Image {
				var image:Image = new Image(_debuffIconBack);
				image.width = image.height = 21.2;
				return image;
			}, function(obj:Object):void {
				if (!(obj is Image))
					return;
				var image:Image = obj as Image;
				if (image.filter is ColorMatrixFilter)
					_matrixFilterPool.recycleOne(image.filter);
				image.filter = null;
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
			
			_debuffInfoTooltip.description.text = StringUtils.substitute(description, {
				"[enemy]": TargetInfoElement.getUnitTrueName(_currentUnit)
			});
		}
		
		public function get debuffInfoTooltip():DebuffInfoTooltip {
			return _debuffInfoTooltip;
		}
		
		// 100000% optimal code
		public function updateDebuffs(debuffs:Vector.<DebuffEffect>, target:Unit):void {
			_currentDebuffs = debuffs;
			_currentUnit = target;
			var image:Image = null;
			for (var i:int = 0; i < numChildren; i++) {
				var child:DisplayObject = getChildAt(i);
				if (child is Image) {
					image = child as Image;
					_imagePool.recycleOne(image);
				}
			}
			removeChildren();
			
			for (var b:int = 0; b < debuffs.length; b++) {
				image = _imagePool.getOne() as Image;
				var debuffInfo:Object = DebuffInfo.getDebuff(debuffs[b].debuff);
				if (debuffInfo != null) {
					image.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
						var matrixFilter:ColorMatrixFilter = _matrixFilterPool.getOne() as ColorMatrixFilter;
						var r:Number = debuffInfo.color[0];
						var g:Number = debuffInfo.color[1];
						var b:Number = debuffInfo.color[2];
						var a:Number = debuffInfo.color[3];
						
						var vec:Vector.<Number> = new Vector.<Number>();
						vec.push(
							r, 0, 0, 0, 0,
							0, g, 0, 0, 0,
							0, 0, b, 0, 0,
							0, 0, 0, a, 0
						);
						
						matrixFilter.matrix = vec;
					});
					image.texture = _textureManager.getTextureByTextureName(debuffInfo.icon, "texture_gui1_test.png");
				}
				
				image.addEventListener(TouchEvent.TOUCH, function(e:TouchEvent):void {
					var touch:Touch = e.getTouch(e.currentTarget as Image);
					if (touch != null && touch.phase == TouchPhase.BEGAN && _selectedDebuff == null) {
						_selectedDebuff = _currentDebuffs[b - 1];
					}
					else if (touch != null && touch.phase == TouchPhase.ENDED && _selectedDebuff == _currentDebuffs[b - 1]) {
						_selectedDebuff = null;
					}
				});
				addChild(image);
			}
		}
	}
}