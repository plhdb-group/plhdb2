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
<table cellspacing="0">
   <tr><th><?php echo lang('Username'); ?></th><td><input name="auth[username]" id="username" value="<?php echo in_array("username",$_GET)?h($_GET["username"]):""; ?>" autocapitalize="off"></td></tr>
   <tr><th><?php echo lang('Password'); ?></th><td><input type="password" name="auth[password]"></td></tr>
   <tr><th><?php echo lang('Database'); ?></th><td><input name="auth[db]" value="<?php echo in_array("db",$_GET)&&h($_GET["db"])!=''?h($_GET["db"]):'plhdb'; ?>" placeholder="plhdb" autocapitalize="off"></td></tr>
</table>
<script type="text/javascript">
 focus(document.getElementById('username'));
</script>
<?php
    echo "<p><input type='submit' value='" . lang('Login') . "'>\n";
    }

    function name() {
      # Supply custom title
      return 'PLHDB via Adminer';
    }

    function credentials() {
      # Prevent user from supplying a different server.
      return array('localhost', $_GET["username"], get_password());
    }

    function navigation($missing) {
      # Add "back" link
      echo '<h1><a href="/">PLHDB Home</a></h1>';
      parent::navigation($missing);
    }

    function selectLimitProcess() {
      # Default to no limit on query results.
      return (isset($_GET["limit"]) ? $_GET["limit"] : "");
    }

  }
  
  return new AdminerSoftware;
}

require $_SERVER['DOCUMENT_ROOT'] . "/../includes/adminer-current";