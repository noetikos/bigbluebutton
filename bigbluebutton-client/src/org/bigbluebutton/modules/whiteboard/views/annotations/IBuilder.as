package org.bigbluebutton.modules.whiteboard.views.annotations
{
	import org.bigbluebutton.modules.whiteboard.views.models.WhiteboardTool;

	public interface IBuilder
	{
		function onMouseDown(mouseX:Number, mouseY:Number, tool:WhiteboardTool):void;
		function onMouseMove(mouseX:Number, mouseY:Number, tool:WhiteboardTool):void;
		function onMouseUp(mouseX:Number, mouseY:Number, tool:WhiteboardTool):void;
	}
}