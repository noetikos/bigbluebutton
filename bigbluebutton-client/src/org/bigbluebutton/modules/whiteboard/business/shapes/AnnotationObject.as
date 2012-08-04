package org.bigbluebutton.modules.whiteboard.business.shapes
{
	import flash.display.Sprite;
	
	import org.bigbluebutton.modules.whiteboard.models.Annotation;

	public class AnnotationObject extends Sprite
	{
		private var _id:String;
		private var _type:String;
		
		protected var _status:String;
		
		public function AnnotationObject(id:String, type:String, status:String)
		{
			_id = id;
			_type = type;
			_status = status;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function get status():String {
			return _status;
		}
		
		public function set status(s:String):void {
			_status = s;
		}
		
		public function denormalize(val:Number, side:Number):Number {
			return (val*side)/100.0;
		}
		
		public function normalize(val:Number, side:Number):Number {
			return (val*100.0)/side;
		}
		
		public function draw(a:Annotation, parentWidth:Number, parentHeight:Number):void {
			
		}
		
		public function redraw(a:Annotation, parentWidth:Number, parentHeight:Number):void {
			
		}
	}
}