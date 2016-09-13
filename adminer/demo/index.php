<?php
# Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
#
# Licensed under the same terms as the Adminer software itself.
# See the adminer/LICENSE file included with PLHDBv2 for more details.

function adminer_object() {
  
  class AdminerSoftware extends Adminer {

    function loginForm() {
      global $drivers;
      ?>
      <input type="hidden" name="auth[driver]" value="pgsql" >
      <input type="hidden" name="auth[server]" value="" >
      <input type="hidden" name="auth[permanent]" value="1" >
      <input type="hidden" name="auth[db]" value="plhdb_demo" >
<script type="text/javascript">
 focus(document.getElementById('username'));
</script>
<?php
    echo "<p><input type='submit' value='" . lang('Login') . "'>\n";
    }

    function name() {
      # Supply custom title
      return 'PLHDB Demo via Adminer';
    }

    function credentials() {
      # Prevent user from supplying a different server.
      require $_SERVER['DOCUMENT_ROOT'] . "/../includes/demopassword.php";
      return array('localhost', 'demo_user', DEMOPASSWORD);
    }

    function database() {
      # Prevent user from supplying a different db.
      return 'plhdb_demo';
    }

    function navigation($missing) {
      # Add "back" link
      echo '<h1><a href="/demopage.html">PLHDB Demo Page</a></h1>';
      parent::navigation($missing);
    }

  }
  
  return new AdminerSoftware;
}

require $_SERVER['DOCUMENT_ROOT'] . "/../includes/adminer-current";