$(document).ready(function() {
	tinyMCE.init({
        mode : "specific_textareas",
		editor_selector : "tinymce",
        theme : "advanced",
        plugins : 'style,table,advimage,advlink,inlinepopups,insertdatetime,preview,media,contextmenu,paste,directionality,xhtmlxtras,advlist',
	    theme_advanced_buttons1 : 'bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,styleselect,formatselect,fontselect,fontsizeselect',
	    theme_advanced_buttons2 : 'cut,copy,paste,pastetext,pasteword,|,bullist,numlist,|,outdent,indent,blockquote,|,link,unlink,anchor,image,media,cleanup,help,code,|,insertdate,inserttime,',
	    theme_advanced_buttons3 : 'tablecontrols,|,removeformat',
	    theme_advanced_toolbar_location : 'top',
	    theme_advanced_toolbar_align : 'left',
	    theme_advanced_statusbar_location : 'bottom',
	    theme_advanced_resizing : true,
	    relative_urls : false
	});
});
