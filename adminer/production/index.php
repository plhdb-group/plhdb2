<?php
function adminer_object() {
  
  class AdminerSoftware extends Adminer {

    function loginForm() {
      global $drivers;
      ?>
      <input type="hidden" name="auth[driver]" value="pgsql" >
<table cellspacing="0">
   <tr><th><?php echo lang('Server'); ?><td><input name="auth[server]" value="<?php echo h(SERVER); ?>" title="hostname[:port]" placeholder="localhost" autocapitalize="off">
   <tr><th><?php echo lang('Username'); ?><td><input name="auth[username]" id="username" value="<?php echo h($_GET["username"]); ?>" autocapitalize="off">
   <tr><th><?php echo lang('Password'); ?><td><input type="password" name="auth[password]">
   <tr><th><?php echo lang('Database'); ?><td><input name="auth[db]" value="<?php echo h($_GET["db"])==''?'plhdb':h($_GET["db"]); ?>" placeholder="plhdb" autocapitalize="off">
</table>
<script type="text/javascript">
 focus(document.getElementById('username'));
</script>
<?php
    echo "<p><input type='submit' value='" . lang('Login') . "'>\n";
    echo checkbox("auth[permanent]", 1, $_COOKIE["adminer_permanent"], lang('Permanent login')) . "\n";
    }

    function name() {
      # Supply custom title
      return 'PLHDB via Adminer';
    }
  }
  
  return new AdminerSoftware;
}

include "/srv/apps/root/var/www/includes/adminer-current";