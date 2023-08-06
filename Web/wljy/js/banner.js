$(function(){
	//IndexNews
	var listN = $(".box1lcon li").size();
	$(".box1lcon ul").width(listN*384);
	for(i=0;i<listN;i++){
		$(".box1btn").append('<span class="png span'+i+'"></span>');
	}
	$(".box1btn span").eq(0).addClass("on")
	var sw = 1;
	$(".box1btn span").mouseover(function(){
		sw = $(".box1btn span").index(this);
		newsChange(sw);
	});
	function newsChange(i){
		$(".box1lcon ul").stop().animate({left:-384*i},500);
		$(".box1btn span").eq(i).addClass("on").siblings("span").removeClass("on");
	}

})