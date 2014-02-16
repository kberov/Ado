/* help_toc.js */
$(document).ready(function () {
  //create nice iconized tree
  //first item is the home page(cover.md)
  $('#toc ul:first').addClass('ui');
  $('#toc ul:first>li:first').prepend('<i class="home icon"></i>');
  //Each li is an "item" in the base list
  $('#toc li').addClass('item');
  $('#toc li a').addClass('ui link');
  //Each li that contains a ul is a "folder"
  $('#toc li ul').parent().prepend('<i class="folder outline purple icon"></i>');
  //all the rest are documents
  $('#toc li').each(function (i) {
    if($(this).children('i.icon').get(0)) return;
    $(this).prepend('<i class="file outline blue  icon"></i>');
    //console.log( i + ": " + $( this ).text() );    
  });
  //Initialize the left menu
  $('#toc').sidebar();
  $('.attached.button').on('click',function (){
    $('#toc').sidebar('toggle','slow');
  });
  //get and append the cover container
  if(!$('article').text()){
    //show the sidebar
    $('.attached.button').click();
    $.get('/help/bg/cover.md')
      .done(function( data ) {
        $('main').append(data);
        //alert( "Data Loaded: " + data );
      });
  }
  //Set this behavior for all #toc links  
  $('#toc a').on('click',function(){
      $.get(this.href)
      .done(function( data ) {
        $('article.main').remove();
        $('main').append(data);
        //alert( "Data Loaded: " + data );
      });
      return false;
    });
});

