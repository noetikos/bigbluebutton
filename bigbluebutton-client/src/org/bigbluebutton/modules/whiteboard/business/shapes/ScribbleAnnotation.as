package org.bigbluebutton.modules.whiteboard.business.shapes
{
	import org.bigbluebutton.modules.whiteboard.models.Annotation;

	public class ScribbleAnnotation extends AnnotationObject
	{
		public function ScribbleAnnotation(id:String, type:String, status:String)
		{
			super(id, type, status);
		}
					
		override public function draw(a:Annotation, parentWidth:Number, parentHeight:Number):void {
			var ao:Object = a.annotation;
			
			this.graphics.lineStyle(ao.thickness, ao.color);
			
			var graphicsCommands:Vector.<int> = new Vector.<int>();
			graphicsCommands.push(1);
			var coordinates:Vector.<Number> = new Vector.<Number>();
			coordinates.push(denormalize((ao.points as Array)[0], parentWidth), denormalize((ao.points as Array)[1], parentHeight));
			
			for (var i:int = 2; i < (ao.points as Array).length; i += 2){
				graphicsCommands.push(2);
				coordinates.push(denormalize((ao.points as Array)[i], parentWidth), denormalize((ao.points as Array)[i+1], parentHeight));
			}
			
			this.graphics.drawPath(graphicsCommands, coordinates);
			this.alpha = 1;
		}
		
		override public function redraw(a:Annotation, parentWidth:Number, parentHeight:Number):void {
			draw(a, parentWidth, parentHeight);
		}
	}
}