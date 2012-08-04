package org.bigbluebutton.modules.whiteboard.business.shapes
{
	import com.asfusion.mate.events.Dispatcher;
	
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.modules.whiteboard.events.WhiteboardDrawEvent;
	import org.bigbluebutton.modules.whiteboard.models.Annotation;
	import org.bigbluebutton.modules.whiteboard.models.WhiteboardModel;

	public class TextAnnotation extends AnnotationObject
	{
		private var _origParentWidth:Number = 0;
		private var _origParentHeight:Number = 0;
		private var _tf:TextField = new TextField();
		private var _wbModel:WhiteboardModel;
		
		public function TextAnnotation(id:String, type:String, status:String, whiteboardModel:WhiteboardModel)
		{
			super(id, type, status);
			_wbModel = whiteboardModel;
			this.addChild(_tf);
		}
		
		public function get origParentWidth():Number {
			return _origParentWidth;
		}
		
		public function get origParentHeight():Number {
			return _origParentHeight;
		}
		
		// t.annotation.text, t.annotation.fontColor, t.annotation.backgroundColor, t.annotation.background, 
		// t.annotation.x, t.annotation.y, t.annotation.textBoxWidth, t.annotation.textBoxHeight, t.annotation.fontSize
			
		override public function draw(a:Annotation, parentWidth:Number, parentHeight:Number):void {
			LogUtil.debug("Drawing TEXT");
			_status = TextObject.TEXT_CREATED
				
			this.x = denormalize(a.annotation.x, parentWidth);
			this.y = denormalize(a.annotation.y, parentHeight);
			
			var newFontSize:Number = a.annotation.fontSize;
			
			if (_origParentHeight == 0 && _origParentWidth == 0) {
				// LogUtil.debug("Old parent dim [" + _origParentWidth + "," + _origParentHeight + "]");
				newFontSize = a.annotation.fontSize;
				_origParentHeight = parentHeight;
				_origParentWidth = parentWidth;               
			} else {
				newFontSize = (parentHeight/_origParentHeight) * a.annotation.fontSize;
				// LogUtil.debug("2 Old parent dim [" + _origParentWidth + "," + _origParentHeight + "] newFontSize=" + newFontSize);
			}     
			
			_tf.text = a.annotation.text;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			var format:TextFormat = new TextFormat();
			format.size = newFontSize;
			format.font = "arial";
			_tf.defaultTextFormat = format;
			_tf.setTextFormat(format);
			
			this.width = denormalize(a.annotation.textBoxWidth, parentWidth);
			this.height = denormalize(a.annotation.textBoxHeight, parentHeight);
			
			LogUtil.debug("2 Old parent dim [" + _origParentWidth + "," + _origParentHeight + "][" + width + "," + height + "] newFontSize=" + newFontSize);
		}
		
		public function redrawText(a:Annotation, origParentWidth:Number, origParentHeight:Number, parentWidth:Number, parentHeight:Number):void {
			this.x = denormalize(a.annotation.x, parentWidth);
			this.y = denormalize(a.annotation.y, parentHeight);
						
			var newFontSize:Number = a.annotation.fontSize;
			newFontSize = (parentHeight/origParentHeight) * a.annotation.fontSize;
			
			/** Pass around the original parent width and height when this text was drawn. 
			 * We need this to redraw the the text to the proper size properly.
			 * **/
			_origParentHeight = origParentHeight;
			_origParentWidth = origParentWidth;               
			
			_tf.text = a.annotation.text;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			var format:TextFormat = new TextFormat();
			format.size = newFontSize;
			format.font = "arial";
			_tf.defaultTextFormat = format;
			_tf.setTextFormat(format);
			
			this.width = denormalize(a.annotation.textBoxWidth, parentWidth);
			this.height = denormalize(a.annotation.textBoxHeight, parentHeight);
			
			LogUtil.debug("Redraw dim [" + _origParentWidth + "," + _origParentHeight + "][" + width + "," + height + "] newFontSize=" + newFontSize);
			
			//           LogUtil.debug("Redraw 2 Old parent dim [" + this.width + "," + this.height + "] newFontSize=" + newFontSize);
		}
		
		public function displayForPresenter():void {
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.type = TextFieldType.INPUT;
			_tf.border = true;
			_tf.background = true;
			_tf.backgroundColor = 0xFFFFFF;
		}

		public function displayNormally():void {
			_tf.multiline = true;
			_tf.wordWrap = true;
		}
		
		public function setFocus():InteractiveObject {
			registerListeners();
			return _tf;
		}
				
		private function registerListeners():void {
			_tf.addEventListener(FocusEvent.FOCUS_IN, textObjLostFocusListener);
			_tf.addEventListener(FocusEvent.FOCUS_OUT, textObjLostFocusListener);
			_tf.addEventListener(TextEvent.TEXT_INPUT, textObjTextListener);
			_tf.addEventListener(KeyboardEvent.KEY_DOWN, textObjSpecialListener);
		}
		
		/* the following four methods  are listeners that handle events that occur on TextObjects, such as text being typed, which causes the textObjTextListener
		to send text to the server. */
		public function textObjSpecialListener(event:KeyboardEvent):void {
			LogUtil.debug("### textObjSpecialListener ");
			// check for special conditions
			if (event.charCode == 127 || // 'delete' key
				event.charCode == 8 || // 'bkspace' key
				event.charCode == 13) { // 'enter' key
				_status = TextObject.TEXT_UPDATED;
				
				// if the enter key is pressed, remove focus from the TextObject so that it is sent to the server.
//				if(event.charCode == 13) {
//					wbCanvas.stage.focus = null;
//					tobj.stage.focus = null;
//					return;
//				}
				sendTextToServer(_status, _tf.text);	
			} 				
		}
		
		public function textObjTextListener(event:TextEvent):void {
			_status = TextObject.TEXT_UPDATED;
			LogUtil.debug("ID " + id + " modified to " + _tf.text);
			sendTextToServer(_status, _tf.text);	
		}
		
		public function textObjGainedFocusListener(event:FocusEvent):void {
            LogUtil.debug("### GAINED FOCUS ");

		}
		
		public function textObjLostFocusListener(event:FocusEvent):void {
			LogUtil.debug("### LOST FOCUS ");
			_status = TextObject.TEXT_PUBLISHED
			sendTextToServer(TextObject.TEXT_PUBLISHED, _tf.text);	
		}
		
		private function sendTextToServer(status:String, text:String):void {			
			//            LogUtil.debug("SENDING TEXT: [" + tobj.text + "]");
			
			var an:Annotation = _wbModel.getAnnotation(id);
			
			var annotation:Object = new Object();
			annotation["type"] = "text";
			annotation["id"] = id;
			annotation["status"] = _status;  
			annotation["text"] = _tf.text;
			annotation["fontColor"] = _tf.textColor;
			annotation["backgroundColor"] = _tf.backgroundColor;
			annotation["background"] = _tf.background;
			annotation["x"] = an.annotation.x;
			annotation["y"] = an.annotation.y;
			annotation["fontSize"] = an.annotation.fontSize;
			var msg:Annotation = new Annotation(id, "text", annotation);
			sendGraphicToServer(msg, WhiteboardDrawEvent.SEND_TEXT);			
		}
		
		private function sendGraphicToServer(gobj:Annotation, type:String):void {
			// LogUtil.debug("DISPATCHING SEND sendGraphicToServer [" + type + "]");
			var event:WhiteboardDrawEvent = new WhiteboardDrawEvent(type);
			event.annotation = gobj;
			var dispatcher:Dispatcher = new Dispatcher();
			dispatcher.dispatchEvent(event);					
		}
	}
}