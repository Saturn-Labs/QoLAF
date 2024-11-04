package qolaf.target {
	import core.GameObject;
	import core.boss.Boss;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import starling.textures.Texture;
	
	/**
	 * @author rydev
	 */
	public interface ITarget extends IEventDispatcher {
		function getName():String;
		function getTrueName():String;
		function getLevel():int;
		function getParent():GameObject;
		function isBoss():Boolean;
		function getBoss():Boss;
		function isAlive():Boolean;
		function getPosition():Point;
		function getTexture():Texture;
		function getMaxHealth():int;
		function getHealth():int;
		function getMaxShield():int;
		function getShield():int;
		function hasAura():Boolean;
		function getAuraColor():uint;
	}
}