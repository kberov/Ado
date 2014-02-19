/* help_toc.js */
var toc_links_selector  = '#toc li a';
$(document).ready(function () {
  //create nice iconized tree
  //first item is the home page(cover.md)
  $('#toc ul:first').addClass('ui');
  $('#toc ul:first>li:first').prepend('<i class="home icon"></i>');
  //Each li is an "item" in the base list
  $('#toc li').addClass('item');
  $(toc_links_selector).addClass('ui link');
  //Each li that contains a ul is a "folder"
  $('#toc li ul').parent().prepend('<i class="folder outline purple icon"></i>');
  //all the rest are documents
  $('#toc li').each(function (i) {
    if($(this).children('i.icon').length) return;
    $(this).prepend('<i class="file outline blue  icon"></i>');
    //console.log( i + ": " + $( this ).text() );    
  });

  //Initialize the left menu
  $('#toc').sidebar();
  $('.attached.button').on('click',function (){
    $('#toc').sidebar('toggle','slow');
  });

  //Set onclick behavior for all #toc and prev,next links  
  $(toc_links_selector+',.right.menu a').on('click',function(){
    $.get(this.href)
    .done(function( data ) {
      $('article.main').remove();
      $('main').append(data);
    });
    set_right_menu_arrows($(this))
    return false;
  });

  //Get and append the main.container with the cover page
  if(!$('article').length){
    //show the sidebar
    $('.attached.button').click();
    //load the first page: cover
    $(toc_links_selector+':first').click();
    set_right_menu_arrows($(toc_links_selector+':first'))
  }
  else {
    set_right_menu_arrows(
      $(toc_links_selector+':contains("'+$('article.main.container h1').text()+'")')
    );
  }
});//end $(document).ready

function set_right_menu_arrows(link){
  var sel = toc_links_selector;
  var prev, next, index;
  //find the indexes of the selected link and links around it
  $(sel).each(function (i) {
    if($(this).text() == link.text()
      //the arrow links
      ||$(this).text() == link.attr('title')){
      prev = $(sel).get((i-1));
      next = $(sel).get((i+1));
      index = i;
      return false;
    }
  })
  //previous
  var left_arrow = $('.left.arrow');
  if( index != 0 && prev){
    left_arrow.parent().attr('href',prev.href);
    left_arrow.parent().attr('title',$(prev).text());
    left_arrow.parent().removeClass('disabled');
  }
  else {
   left_arrow.parent().addClass('disabled') 
  }
  //next
  var right_arrow = $('.right.arrow'); 
  if( next ){
    right_arrow.parent().attr('href',next.href);
    right_arrow.parent().attr('title',$(next).text());
    right_arrow.parent().removeClass('disabled');
  }
  else {
   right_arrow.parent().addClass('disabled') 
  }
  /* 
  console.log(link.text()+'loaded')
  console.log('next page is:'+ $(next).text())
  console.log('prev page is:'+ $(prev).text())
  */
}
