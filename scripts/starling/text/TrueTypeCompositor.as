package starling.text {
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import starling.display.MeshBatch;
	import starling.display.Quad;
	import starling.textures.Texture;
	import starling.utils.SystemUtil;
	
	public class TrueTypeCompositor implements ITextCompositor {
		private static var sHelperMatrix:Matrix = new Matrix();
		
		private static var sHelperQuad:Quad = new Quad(100,100);
		
		private static var sNativeTextField:flash.text.TextField = new flash.text.TextField();
		
		private static var sNativeFormat:flash.text.TextFormat = new flash.text.TextFormat();
		
		public function TrueTypeCompositor() {
			super();
		}
		
		public function dispose() : void {
		}
		
		public function fillMeshBatch(meshBatch:MeshBatch, width:Number, height:Number, text:String, format:starling.text.TextFormat, options:TextOptions = null) : void {
			var texture:Texture;
			var textureFormat:String;
			var bitmapData:BitmapDataEx;
			if(text == null || text == "") {
				return;
			}
			textureFormat = options.textureFormat;
			bitmapData = renderText(width,height,text,format,options);
			texture = Texture.fromBitmapData(bitmapData,false,false,bitmapData.scale,textureFormat);
			texture.root.onRestore = function():void {
				bitmapData = renderText(width,height,text,format,options);
				texture.root.uploadBitmapData(bitmapData);
				bitmapData.dispose();
				bitmapData = null;
			};
			bitmapData.dispose();
			bitmapData = null;
			sHelperQuad.texture = texture;
			sHelperQuad.readjustSize();
			if(format.horizontalAlign == "left") {
				sHelperQuad.x = 0;
			} else if(format.horizontalAlign == "center") {
				sHelperQuad.x = int((width - texture.width) / 2);
			} else {
				sHelperQuad.x = width - texture.width;
			}
			if(format.verticalAlign == "top") {
				sHelperQuad.y = 0;
			} else if(format.verticalAlign == "center") {
				sHelperQuad.y = int((height - texture.height) / 2);
			} else {
				sHelperQuad.y = height - texture.height;
			}
			meshBatch.addMesh(sHelperQuad);
			sHelperQuad.texture = null;
		}
		
		public function clearMeshBatch(meshBatch:MeshBatch) : void {
			meshBatch.clear();
			if(meshBatch.texture) {
				meshBatch.texture.dispose();
			}
		}
		
		private function renderText(width:Number, height:Number, text:String, format:starling.text.TextFormat, options:TextOptions) : BitmapDataEx {
			var _local16:BitmapDataEx = null;
			var _local7:Number = width * options.textureScale;
			var _local15:Number = height * options.textureScale;
			var _local6:String = format.horizontalAlign;
			format.toNativeFormat(sNativeFormat);
			sNativeFormat.size = Number(sNativeFormat.size) * options.textureScale;
			sNativeTextField.embedFonts = SystemUtil.isEmbeddedFont(format.font,format.bold,format.italic);
			sNativeTextField.styleSheet = null;
			sNativeTextField.defaultTextFormat = sNativeFormat;
			sNativeTextField.styleSheet = options.styleSheet;
			sNativeTextField.width = _local7;
			sNativeTextField.height = _local15;
			sNativeTextField.antiAliasType = "advanced";
			sNativeTextField.selectable = false;
			sNativeTextField.multiline = true;
			sNativeTextField.wordWrap = options.wordWrap;
			if(options.isHtmlText) {
				sNativeTextField.htmlText = text;
			} else {
				sNativeTextField.text = text;
			}
			if(options.autoScale) {
				autoScaleNativeTextField(sNativeTextField,text,options.isHtmlText);
			}
			var _local9:Number = sNativeTextField.textWidth;
			var _local10:Number = sNativeTextField.textHeight;
			var _local13:int = Math.ceil(_local9) + 4;
			var _local14:int = Math.ceil(_local10) + 4;
			var _local8:int = Texture.maxSize;
			var _local11:int = 1;
			var _local12:Number = 0;
			if(options.isHtmlText) {
				_local9 = _local13 = _local7;
			}
			if(_local13 < _local11) {
				_local13 = 1;
			}
			if(_local14 < _local11) {
				_local14 = 1;
			}
			if(_local14 > _local8 || _local13 > _local8) {
				options.textureScale *= _local8 / Math.max(_local13,_local14);
				return renderText(width,height,text,format,options);
			}
			if(!options.isHtmlText) {
				if(_local6 == "right") {
					_local12 = _local7 - _local9 - 4;
				} else if(_local6 == "center") {
					_local12 = (_local7 - _local9 - 4) / 2;
				}
			}
			_local16 = new BitmapDataEx(_local13,_local14);
			sHelperMatrix.setTo(1,0,0,1,-_local12,0);
			_local16.draw(sNativeTextField,sHelperMatrix);
			_local16.scale = options.textureScale;
			sNativeTextField.text = "";
			return _local16;
		}
		
		private function autoScaleNativeTextField(textField:flash.text.TextField, text:String, isHtmlText:Boolean) : void {
			var _local7:flash.text.TextFormat = textField.defaultTextFormat;
			var _local5:int = textField.width - 4;
			var _local6:int = textField.height - 4;
			var _local4:Number = Number(_local7.size);
			while(textField.textWidth > _local5 || textField.textHeight > _local6) {
				if(_local4 <= 4) {
					break;
				}
				_local7.size = _local4--;
				textField.defaultTextFormat = _local7;
				if(isHtmlText) {
					textField.htmlText = text;
				} else {
					textField.text = text;
				}
			}
		}
	}
}

import flash.display.BitmapData;

class BitmapDataEx extends BitmapData {
	private var _scale:Number = 1;
	
	public function BitmapDataEx(width:int, height:int, transparent:Boolean = true, fillColor:uint = 0) {
		super(width,height,transparent,fillColor);
	}
	
	public function get scale() : Number {
		return _scale;
	}
	
	public function set scale(value:Number) : void {
		_scale = value;
	}
}
