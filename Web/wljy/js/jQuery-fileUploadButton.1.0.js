/*
To-do:
- Add debug statements
- Add option to toggle debug statements
*/

(function( $ ) {
	$.fn.fileUploadButton = function(options) {
		var settings = {
			height: '16px',
			width: '32px',
			image: '',
			clickedImage: '',
			hoverImage: ''
		};

		return this.each(function() {
			if (options) { $.extend(settings, options); }

			var fileInput = $(this);
			var wrapper = $(document.createElement('div'));

			/* Apply required CSS to create the div window */
			wrapper.css({
				'cursor':'pointer',
				'position':'relative',
				'overflow':'hidden'
			});

			/* Apply user-provided settings to customize the div window */
			wrapper.css({
				'height':settings.height,
				'width':settings.width,
				'background-image':'url('+settings.image+')'
			});

			if (settings.hoverImage) {
				wrapper.hover( function() {
					$(this).css('background-image','url('+settings.hoverImage+')');
				}, function() {
					$(this).css('background-image','url('+settings.image+')');
				});
			}

			if (settings.clickedImage) {
				wrapper.mousedown( function() {
					$(this).css('background-image','url('+settings.clickedImage+')');
				}).mouseup(function() {
					$(this).css('background-image','url('+settings.image+')');
				});
			}

			/* Apply required CSS to position the file input */
			fileInput.css({
				'height':'100%',
				'cursor':'pointer',
				'position':'absolute',
				'top':'0',
				'right':'0',
				'z-index':'99',
				'opacity':'0',
				'-moz-opacity':'0',
				'filter':'progid:DXImageTransform.Microsoft.Alpha(opacity=0)'
			});

			/* Apply user-provided settings to customize the file input */
			fileInput.css({
				'font-size':settings.height
			});

			/* Place the fileInput inside the div window */
			fileInput.wrap(wrapper);
		});
	};
})( jQuery );
