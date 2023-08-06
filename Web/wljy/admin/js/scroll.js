// JavaScript Document
$(function() {
var width=197;//每个图片宽度
var Movement_speed=500;//滚动速度
var Movement_time=3000;//滚动间隔时间

var slideX = {
	thisUl: $('.mid ul'),
	btnLeft: $('.left'),
	btnRight: $('.right'),
	thisLi: $('.mid ul li'),
	init: function () {
		slideX.thisUl.width(slideX.thisLi.length * width);
		slideX.slideAuto();
		slideX.btnLeft.click(slideX.slideLeft).hover(slideX.slideStop, slideX.slideAuto);
		slideX.btnRight.click(slideX.slideRight).hover(slideX.slideStop, slideX.slideAuto);
		slideX.thisUl.hover(slideX.slideStop, slideX.slideAuto);
	},
	slideLeft: function () {
		slideX.btnLeft.unbind('click', slideX.slideLeft);
		slideX.thisUl.find('li:last').prependTo(slideX.thisUl);
		slideX.thisUl.css('marginLeft', 0-width);
		slideX.thisUl.animate({ 'marginLeft': 0 }, Movement_speed, function () {
			slideX.btnLeft.bind('click', slideX.slideLeft);
		});
		return false;
	},
	slideRight: function () {
		slideX.btnRight.unbind('click', slideX.slideRight);
		slideX.thisUl.animate({ 'marginLeft': 0-width}, Movement_speed, function () {
			slideX.thisUl.css('marginLeft', '0');
			slideX.thisUl.find('li:first').appendTo(slideX.thisUl);
			slideX.btnRight.bind('click', slideX.slideRight);
		});
		return false;
	},
	slideAuto: function () {
		slideX.intervalId = window.setInterval(slideX.slideRight, Movement_time);
	},
	slideStop: function () {
		window.clearInterval(slideX.intervalId);
	}
}
$(document).ready(function () {
	slideX.init();
})
})