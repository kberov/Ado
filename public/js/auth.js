/* auth.js */

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
    $( "#login_form" ).submit(function( event ) {
      generate_digest();
      return true;
    });
});