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
/**
 * Generates digest value and adds it to digest field in the login form.
 * Removes the password field. It is not sent over HTTP.
 * See https://developer.mozilla.org/en-US/docs/Security/InsecurePasswords
 */
function generate_digest () {
  var digest = $('#login_form [name="digest"]');
  var login_name = $('#login_form [name="login_name"]');
  var login_password = $('#login_form [name="login_password"]');
  var csrf_token = $('#login_form [name="csrf_token"]');
  login_password_sha1 = CryptoJS.SHA1(login_name.val() + login_password.val());
  //set digest
  digest.val(CryptoJS.SHA1(csrf_token.val() + login_password_sha1));
  login_password.remove();

}

jQuery( document ).ready(function( $ ) {
  $('#authbar .dropdown ado.ado, #login_form .checkbox [type="radio"]').click(switch_login_method);
  $('#login_form .header')
    .text('Login using ' + 
      $.trim($('#login_form .checkbox>:checked').parent().text())
    );

    $( "#login_form" ).submit(function( event ) {
      generate_digest();
      return true;
    });
});