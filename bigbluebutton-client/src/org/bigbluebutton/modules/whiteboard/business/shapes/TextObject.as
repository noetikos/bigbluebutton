/**
 * BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
 *
 * Copyright (c) 2012 BigBlueButton Inc. and by respective authors (see below).
 *
 * This program is free software; you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 2.1 of the License, or (at your option) any later
 * version.
 *
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
 * 
 * Author: Ajay Gopinath <ajgopi124(at)gmail(dot)com>
 */
package org.bigbluebutton.modules.whiteboard.business.shapes
{
	import com.asfusion.mate.core.GlobalDispatcher;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import flashx.textLayout.edit.SelectionManager;
	
	import flexlib.scheduling.scheduleClasses.utils.Selection;
	
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.modules.whiteboard.WhiteboardCanvasModel;

	public class TextObject extends UIComponent implements IAnnotationDisplay {
		public static const TYPE_NOT_EDITABLE:String = "dynamic";
		public static const TYPE_EDITABLE:String = "editable";
		
		public static const TEXT_CREATED:String = "textCreated";
		public static const TEXT_UPDATED:String = "textEdited";
		public static const TEXT_PUBLISHED:String = "textPublished";
		
		public static const TEXT_TOOL:String = "textTool";
		
		/**
		 * Status = [CREATED, UPDATED, PUBLISHED]
		 */
		public var status:String = TEXT_CREATED;

		private var _editable:Boolean;
		
		/**
		 * ID we can use to match the shape in the client's view
		 * so we can use modify it; a unique identifier of each GraphicObject
		 */
		private var ID:String = WhiteboardConstants.ID_UNASSIGNED;
		public var textSize:Number;
		
        private var _textBoxWidth:Number = 0;
        private var _textBoxHeight:Number = 0;
        private var origX:Number;
        private var origY:Number;
        private var _origParentWidth:Number = 0;
        private var _origParentHeight:Number = 0;
        public var fontStyle:String = "arial";
        
        private var tf:TextField = new TextField();
        
		public function TextObject(text:String, textColor:uint, bgColor:uint, bgColorVisible:Boolean, x:Number, y:Number, boxWidth:Number, boxHeight:Number, textSize:Number) {
			tf.text = text;
			tf.textColor = textColor;
			tf.backgroundColor = bgColor;
			tf.background = bgColorVisible;
            origX = x;
            origY = y;
            this.x = x;
            this.y = y;
            _textBoxWidth = boxWidth;
            _textBoxHeight = boxHeight;
			this.textSize = textSize;
            
            addChild(tf);
		}	
		
        public function getOrigX():Number {
            return origX;
        }
        
        public function getOrigY():Number {
            return origY;
        }
        
		public function getGraphicType():String {
			return WhiteboardConstants.TYPE_TEXT;
		}
		
		public function getGraphicID():String {
			return ID;
		}
		
		public function setGraphicID(id:String):void {
			this.ID = id;
		}
        
        public function get background():Boolean {
            return tf.background;
        }
        
        public function set background(b:Boolean):void {
            tf.background = b;
        }
        
        public function get backgroundColor():uint {
            return tf.backgroundColor;
        }
        
        public function set backgroundColor(c:uint):void {
            tf.backgroundColor = c;
        }
        
        public function get textColor():uint {
            return tf.textColor;
        }
        
        public function get text():String {
            return tf.text;
        }
        
        public function set border(b:Boolean):void {
            tf.border = b;
        }
        
        public function set wordWrap(w:Boolean):void {
            tf.wordWrap = w;
        }
        
        public function set multiline(m:Boolean):void {
            tf.multiline = m;
        }
        
        public function set autoSize(size:String):void {
            tf.autoSize = size;
        }
		
		public function denormalize(val:Number, side:Number):Number {
			return (val*side)/100.0;
		}
		
		public function normalize(val:Number, side:Number):Number {
			return (val*100.0)/side;
		}
		
		private function applyTextFormat(size:Number):void {
//            LogUtil.debug(" *** Font text size [" + textSize + "," + size + "]");
			var format:TextFormat = new TextFormat();
            format.size = size;
            format.font = "arial";
			tf.defaultTextFormat = format;
			tf.setTextFormat(format);
		}
		
		public function makeGraphic(parentWidth:Number, parentHeight:Number):void {
            this.x = denormalize(origX, parentWidth);
            this.y = denormalize(origY, parentHeight);

            
            var newFontSize:Number = textSize;
            
            if (_origParentHeight == 0 && _origParentWidth == 0) {
//                LogUtil.debug("Old parent dim [" + _origParentWidth + "," + _origParentHeight + "]");
                newFontSize = textSize;
                _origParentHeight = parentHeight;
                _origParentWidth = parentWidth;               
            } else {
                newFontSize = (parentHeight/_origParentHeight) * textSize;
//                LogUtil.debug("2 Old parent dim [" + _origParentWidth + "," + _origParentHeight + "] newFontSize=" + newFontSize);
            }            
			tf.antiAliasType = AntiAliasType.ADVANCED;
            applyTextFormat(newFontSize);
//            setTextFormat(new TextFormat(fontStyle, newFontSize, textColor));
 
            this.width = denormalize(_textBoxWidth, parentWidth);
            this.height = denormalize(_textBoxHeight, parentHeight);
            tf.width = this.width;
            tf.height = this.height;
            
            LogUtil.debug("2 Old parent dim [" + _origParentWidth + "," + _origParentHeight + "][" + width + "," + height + "] newFontSize=" + newFontSize);
		}	

        public function get textBoxWidth():Number {
            return _textBoxWidth;
        }
        
        public function get textBoxHeight():Number {
            return _textBoxHeight;
        }
        
        public function get oldParentWidth():Number {
            return _origParentWidth;
        }
        
        public function get oldParentHeight():Number {
            return _origParentHeight;
        }
        
        public function redrawText(origParentWidth:Number, origParentHeight:Number, parentWidth:Number, parentHeight:Number):void {
            this.x = denormalize(origX, parentWidth);
            this.y = denormalize(origY, parentHeight);

            
            var newFontSize:Number = textSize;
            newFontSize = (parentHeight/origParentHeight) * textSize;
			
			/** Pass around the original parent width and height when this text was drawn. 
			 * We need this to redraw the the text to the proper size properly.
			 * **/
            _origParentHeight = origParentHeight;
            _origParentWidth = origParentWidth;               
                
//            LogUtil.debug("Redraw 2 Old parent dim [" + origParentWidth + "," + origParentHeight + "] newFontSize=" + newFontSize);
     
            tf.antiAliasType = AntiAliasType.ADVANCED;
            applyTextFormat(newFontSize);
            //            setTextFormat(new TextFormat(fontStyle, newFontSize, textColor));

            this.width = denormalize(_textBoxWidth, parentWidth);
            this.height = denormalize(_textBoxHeight, parentHeight);
            tf.width = this.width;
            tf.height = this.height;            
            LogUtil.debug("Redraw dim [" + _origParentWidth + "," + _origParentHeight + "][" + width + "," + height + "] newFontSize=" + newFontSize);
            
 //           LogUtil.debug("Redraw 2 Old parent dim [" + this.width + "," + this.height + "] newFontSize=" + newFontSize);
        }
        
        public function focus():InteractiveObject {
            return tf;
        }
        
		public function getProperties():Array {
			var props:Array = new Array();
			props.push(tf.text);
			props.push(tf.textColor);
			props.push(tf.backgroundColor);
			props.push(tf.background);
			props.push(tf.x);
			props.push(tf.y);
			return props;
		}
		
		public function makeEditable(editable:Boolean):void {
			if(editable) {
				tf.type = TextFieldType.INPUT;
			} else {
				tf.type = TextFieldType.DYNAMIC;
			}
			this._editable = editable;
		}
		
		public function registerListeners(textObjGainedFocus:Function, textObjLostFocus:Function, textObjTextListener:Function, textObjDeleteListener:Function):void {											  
			tf.addEventListener(FocusEvent.FOCUS_IN, textObjGainedFocus);
			tf.addEventListener(FocusEvent.FOCUS_OUT, textObjLostFocus);
			tf.addEventListener(TextEvent.TEXT_INPUT, textObjTextListener);
			tf.addEventListener(KeyboardEvent.KEY_DOWN, textObjDeleteListener);
		}		
		
		public function deregisterListeners(textObjGainedFocus:Function, textObjLostFocus:Function, textObjTextListener:Function, textObjDeleteListener:Function):void {			
			tf.removeEventListener(FocusEvent.FOCUS_IN, textObjGainedFocus);
			tf.removeEventListener(FocusEvent.FOCUS_OUT, textObjLostFocus);
			tf.removeEventListener(TextEvent.TEXT_INPUT, textObjTextListener);
			tf.removeEventListener(KeyboardEvent.KEY_DOWN, textObjDeleteListener);
		}
	}
}