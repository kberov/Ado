/* auth.js */
/**
  Changes the action attribute of the login form to the desired 
  authentication method.
*/
function switch_login_method() {
  //clicked on a link
  if(this.href){
    $('#login_form div.auth_methods').remove();
    $('#login_form').attr('action', this.href);
    $('#login_form .header').text('Login using ' + $(this).text());
    $('#modal_login_form').modal('attach events').modal('show');
    return false;
  }
  //or on a checkbox
  else {
    $('#login_form').attr('action', this.value);
    $('#login_form .header').text('Login using ' + $(this).parent().text());
  }
}
$('#authbar .dropdown a.item, #login_form .checkbox [type="radio"]').click(switch_login_method);
$('#login_form .header')
  .text('Login using ' + 
    $.trim($('#login_form .checkbox>:checked').parent().text())
  );