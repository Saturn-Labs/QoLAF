package qolaf.ui.elements 
{
	import feathers.controls.Label;
	import core.scene.Game;
	import generics.Util;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.rendering.Painter;
	import starling.text.TextFormat;
	import starling.utils.Align;
	import starling.filters.GlowFilter;
	import starling.display.BlendMode;
	
	/**
	 * @author rydev
	 */
	public class ValueTrailAnimatedSlider extends DisplayObjectContainer 
	{	
		private var mainSlider:Quad;
		private var mainSliderCover:Quad;
		private var trailSlider:Quad;
		private var sliderTip:Quad;
		private var valueText:Label;
		
		private var tipGlowFilter:GlowFilter;
		
		private var barWidth:Number = 0.0;
		private var barHeight:Number = 0.0;
		private var lerpSpeed:Number = 1.0;
		private var currentValue:Number = 0.0;
		private var lerpValue:Number = 0.0;
		private var rawMaxValue:Number = 0.0;
		private var rawValue:Number = 0.0;
		
		public function ValueTrailAnimatedSlider(width:Number, height:Number, color:Number = 0xFFFFFF, trailAlpha:Number = 0.45, lerpSpeed:Number = 2.5, showValueText:Boolean = true) 
		{
			barWidth = width;
			barHeight = height;
			this.lerpSpeed = lerpSpeed;
			
			mainSlider = new Quad(width, height, color);
			mainSlider.x = -(width / 2);
			mainSlider.alignPivot(Align.LEFT, Align.CENTER);
			
			trailSlider = new Quad(width, height, color);
			trailSlider.x = -(width / 2);
			trailSlider.alignPivot(Align.LEFT, Align.CENTER);
			trailSlider.alpha = trailAlpha;
			
			valueText = new Label();
			valueText.width = barWidth;
			valueText.height = barHeight;
			valueText.styleName = "target_info";
			valueText.alignPivot();
			valueText.x = 0;
			valueText.y = 0;
			valueText.visible = showValueText;
			
			sliderTip = new Quad(1, height, color);
			sliderTip.alpha = 1;
			sliderTip.alignPivot(Align.LEFT, Align.CENTER);
			sliderTip.blendMode = BlendMode.ADD;
			tipGlowFilter = new GlowFilter(0xffffff, 10, 10, 1);
			
			addChild(trailSlider);
			addChild(mainSlider);
			addChild(valueText);
			addChild(sliderTip);
			
			sliderTip.filter = tipGlowFilter;
		}
		
		public function setValue(value:Number, maxValue:Number): void {
			rawMaxValue = maxValue;
			rawValue = value;
			currentValue = Math.min(value / maxValue, 1.0);
			if (lerpValue < currentValue)
				lerpValue = currentValue;
		}
		
		public function update(): void 
		{
			lerpValue = Util.lerp(lerpValue, currentValue, Game.instance.deltaTime * lerpSpeed);
			
			var newWidthMain:Number = (barWidth * currentValue);
			var newWidthTrail:Number = (barWidth * lerpValue);
			var lerpDistance:Number = Util.clamp(Math.abs(lerpValue - currentValue), 0.0, 1.0);
			tipGlowFilter.alpha = Util.clamp(lerpDistance * 215, 0, 10.5);
			
			mainSlider.width = newWidthMain;
			trailSlider.width = newWidthTrail;
			sliderTip.x = mainSlider.width - (barWidth / 2);
			
			valueText.text = "<font face='Verdana' size='" + barHeight / 1.15 + "px'>" + Math.floor(rawValue) + " ⁄ " + Math.floor(rawMaxValue) + "</font>";
		}
	}

}